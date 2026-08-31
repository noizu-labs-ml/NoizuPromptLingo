package providers

import (
	"encoding/json"
	"os"
	"strings"

	"github.com/noizu-labs/go-litellm/internal/config"
	"github.com/noizu-labs/go-litellm/internal/errx"
	"github.com/noizu-labs/go-litellm/internal/jsonx"
)

const (
	anthropicAPIVersion    = "2023-06-01"
	anthropicDefaultBase   = "https://api.anthropic.com/v1"
	anthropicDefaultMaxTok = 4096
)

var anthropicSupported = []string{
	"model", "messages", "temperature", "top_p", "top_k", "stream", "stop", "max_tokens",
	"max_completion_tokens", "tools", "tool_choice", "user", "metadata", "reasoning_effort",
}

// AnthropicAdapter is the distinct Anthropic Messages adapter.
type AnthropicAdapter struct{}

func (AnthropicAdapter) Name() string { return "anthropic" }

func (AnthropicAdapter) SupportedParams(_ string) []string { return anthropicSupported }

func (a AnthropicAdapter) MapOpenAIParams(nonDefault, optional map[string]any, _ string, drop bool) map[string]any {
	supported := map[string]bool{}
	for _, k := range anthropicSupported {
		supported[k] = true
	}
	out := jsonx.Clone(optional)
	for k, v := range nonDefault {
		switch {
		case supported[k]:
			out[k] = v
		case drop:
		default:
			out[k] = v
		}
	}
	return out
}

func (AnthropicAdapter) ValidateEnvironment(req *Request, headers map[string]string) (map[string]string, *errx.Error) {
	if headers == nil {
		headers = map[string]string{}
	}
	key := resolveAnthropicKey(req.LiteLLMParams)
	if key == "" {
		return nil, errx.New(401, "no Anthropic API key (checked litellm_params.api_key and ANTHROPIC_API_KEY)",
			errx.WithType("authentication_error"), errx.WithProvider("anthropic"))
	}
	headers["x-api-key"] = key
	headers["anthropic-version"] = anthropicAPIVersion
	headers["content-type"] = "application/json"
	if extra := jsonx.Nested(req.LiteLLMParams, "extra_headers"); extra != nil {
		for k, v := range extra {
			headers[k] = stringify(v)
		}
	}
	return headers, nil
}

func (AnthropicAdapter) CompleteURL(req *Request) string {
	base := strings.TrimRight(jsonx.Str(req.LiteLLMParams, "api_base"), "/")
	if base == "" {
		base = anthropicDefaultBase
	}
	switch {
	case strings.HasSuffix(base, "/messages"):
		return base
	case strings.HasSuffix(base, "/v1"):
		return base + "/messages"
	default:
		return base + "/v1/messages"
	}
}

func (AnthropicAdapter) TransformRequest(req *Request) map[string]any {
	system, chat := splitSystem(req.Messages)
	msgs := make([]any, 0, len(chat))
	for _, m := range chat {
		msgs = append(msgs, translateMessage(jsonx.AsMap(m)))
	}
	maxTok := anthropicDefaultMaxTok
	if n, ok := jsonx.Int(req.Params, "max_tokens"); ok {
		maxTok = n
	} else if n, ok := jsonx.Int(req.Params, "max_completion_tokens"); ok {
		maxTok = n
	}
	body := map[string]any{
		"model":      req.Model,
		"messages":   msgs,
		"max_tokens": maxTok,
	}
	if system != "" {
		body["system"] = system
	}
	copyParam(body, req.Params, "temperature", "")
	copyParam(body, req.Params, "top_p", "")
	copyParam(body, req.Params, "top_k", "")
	copyParam(body, req.Params, "stop", "stop_sequences")
	if tools, ok := req.Params["tools"].([]any); ok {
		out := make([]any, 0, len(tools))
		for _, t := range tools {
			out = append(out, translateTool(jsonx.AsMap(t)))
		}
		body["tools"] = out
	}
	if jsonx.Bool(req.Params, "stream") {
		body["stream"] = true
	}
	return body
}

func (AnthropicAdapter) TransformResponse(raw map[string]any, req *Request) *ModelResponse {
	text, toolCalls := flattenContent(raw["content"])
	message := map[string]any{"role": "assistant", "content": text}
	if len(toolCalls) > 0 {
		message["tool_calls"] = toolCalls
	}
	model := jsonx.Str(raw, "model")
	if model == "" {
		model = req.Model
	}
	return NewModelResponse(map[string]any{
		"id":    raw["id"],
		"model": model,
		"choices": []any{
			map[string]any{
				"index":         0,
				"message":       message,
				"finish_reason": mapStopReason(jsonx.Str(raw, "stop_reason")),
			},
		},
		"usage": mapUsage(jsonx.AsMap(raw["usage"])),
	})
}

func (AnthropicAdapter) ErrorClass(status int, body any, _ map[string]string) *errx.Error {
	msg := "anthropic provider error"
	if m := jsonx.AsMap(body); m != nil {
		if errm := jsonx.AsMap(m["error"]); errm != nil {
			if s := jsonx.Str(errm, "message"); s != "" {
				msg = s
			} else if s := jsonx.Str(errm, "type"); s != "" {
				msg = s
			}
		}
	}
	return errx.New(status, msg, errx.WithProvider("anthropic"))
}

func (AnthropicAdapter) ChunkParser(event any) StreamChunk {
	if event == nil {
		return StreamChunk{Done: true}
	}
	m := jsonx.AsMap(event)
	if m == nil {
		return StreamChunk{Raw: event}
	}
	switch jsonx.Str(m, "type") {
	case "content_block_delta":
		delta := jsonx.AsMap(m["delta"])
		if delta == nil {
			delta = map[string]any{}
		}
		idx, _ := jsonx.Int(m, "index")
		return StreamChunk{
			Text:    jsonx.Str(delta, "text"),
			ToolUse: toolUseDelta(delta),
			Index:   idx,
			Raw:     event,
		}
	case "message_delta":
		delta := jsonx.AsMap(m["delta"])
		stop := ""
		if delta != nil {
			stop = jsonx.Str(delta, "stop_reason")
		}
		return StreamChunk{
			IsFinished:   true,
			FinishReason: mapStopReason(stop),
			Usage:        mapUsage(jsonx.AsMap(m["usage"])),
			Raw:          event,
		}
	case "message_stop":
		return StreamChunk{Done: true}
	default:
		return StreamChunk{Raw: event}
	}
}

func resolveAnthropicKey(lp map[string]any) string {
	if k := jsonx.Str(lp, "api_key"); k != "" {
		if s, ok := config.Resolve(k).(string); ok && s != "" {
			return s
		}
	}
	if v := os.Getenv("ANTHROPIC_API_KEY"); v != "" {
		return v
	}
	return os.Getenv("ANTHROPIC_AUTH_TOKEN")
}

func splitSystem(messages []any) (string, []any) {
	var systems []string
	var rest []any
	for _, raw := range messages {
		m := jsonx.AsMap(raw)
		if m == nil {
			continue
		}
		if jsonx.Str(m, "role") == "system" {
			if s := contentToString(m["content"]); s != "" {
				systems = append(systems, s)
			}
			continue
		}
		rest = append(rest, raw)
	}
	return strings.Join(systems, "\n\n"), rest
}

func translateMessage(m map[string]any) map[string]any {
	if m == nil {
		return map[string]any{}
	}
	return map[string]any{
		"role":    m["role"],
		"content": translateContent(m["content"]),
	}
}

func translateContent(content any) any {
	switch c := content.(type) {
	case string:
		return c
	case []any:
		out := make([]any, 0, len(c))
		for _, p := range c {
			pm := jsonx.AsMap(p)
			if pm == nil {
				out = append(out, p)
				continue
			}
			switch jsonx.Str(pm, "type") {
			case "text":
				out = append(out, map[string]any{"type": "text", "text": pm["text"]})
			case "image_url":
				url := ""
				if iu := jsonx.AsMap(pm["image_url"]); iu != nil {
					url = jsonx.Str(iu, "url")
				}
				out = append(out, imageBlock(url))
			default:
				out = append(out, p)
			}
		}
		return out
	default:
		return content
	}
}

func imageBlock(url string) map[string]any {
	if strings.HasPrefix(url, "data:") {
		parts := strings.SplitN(url, ",", 2)
		if len(parts) == 2 {
			meta := strings.TrimPrefix(parts[0], "data:")
			media := strings.SplitN(meta, ";", 2)[0]
			return map[string]any{
				"type": "image",
				"source": map[string]any{
					"type": "base64", "media_type": media, "data": parts[1],
				},
			}
		}
		return map[string]any{"type": "text", "text": url}
	}
	return map[string]any{"type": "image", "source": map[string]any{"type": "url", "url": url}}
}

func translateTool(t map[string]any) map[string]any {
	if t == nil {
		return map[string]any{}
	}
	if fun := jsonx.AsMap(t["function"]); fun != nil {
		schema := fun["parameters"]
		if schema == nil {
			schema = map[string]any{"type": "object", "properties": map[string]any{}}
		}
		return map[string]any{
			"name":         fun["name"],
			"description":  fun["description"],
			"input_schema": schema,
		}
	}
	return t
}

func flattenContent(content any) (string, []any) {
	blocks, _ := content.([]any)
	var text string
	var tools []any
	for _, b := range blocks {
		m := jsonx.AsMap(b)
		if m == nil {
			continue
		}
		switch jsonx.Str(m, "type") {
		case "text":
			text += jsonx.Str(m, "text")
		case "tool_use":
			args, _ := json.Marshal(m["input"])
			tools = append(tools, map[string]any{
				"id":   m["id"],
				"type": "function",
				"function": map[string]any{
					"name":      m["name"],
					"arguments": string(args),
				},
			})
		}
	}
	return text, tools
}

func toolUseDelta(delta map[string]any) any {
	if jsonx.Str(delta, "type") == "input_json_delta" {
		return delta["partial_json"]
	}
	return nil
}

func mapStopReason(r string) any {
	switch r {
	case "end_turn", "stop_sequence":
		return "stop"
	case "max_tokens":
		return "length"
	case "tool_use":
		return "tool_calls"
	case "":
		return nil
	default:
		return r
	}
}

func mapUsage(u map[string]any) any {
	if u == nil {
		return nil
	}
	in, _ := jsonx.Int(u, "input_tokens")
	out, _ := jsonx.Int(u, "output_tokens")
	return map[string]any{
		"prompt_tokens":     in,
		"completion_tokens": out,
		"total_tokens":      in + out,
	}
}

func contentToString(c any) string {
	switch t := c.(type) {
	case string:
		return t
	case []any:
		var b strings.Builder
		for _, p := range t {
			if m := jsonx.AsMap(p); m != nil {
				b.WriteString(jsonx.Str(m, "text"))
			}
		}
		return b.String()
	default:
		return ""
	}
}

func copyParam(body, params map[string]any, key, as string) {
	if v, ok := params[key]; ok && v != nil {
		if as == "" {
			as = key
		}
		body[as] = v
	}
}

func stringify(v any) string {
	if s, ok := v.(string); ok {
		return s
	}
	b, _ := json.Marshal(v)
	return string(b)
}

// Anthropic is the registered Anthropic adapter.
var Anthropic Adapter = AnthropicAdapter{}
