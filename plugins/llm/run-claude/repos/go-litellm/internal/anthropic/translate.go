// Package anthropic translates Anthropic Messages ↔ OpenAI Chat for /v1/messages.
package anthropic

import (
	"encoding/json"
	"strings"

	"github.com/noizu-labs/go-litellm/internal/jsonx"
	"github.com/noizu-labs/go-litellm/internal/providers"
)

// RequestToOpenAI translates an Anthropic Messages body into an OpenAI chat body.
func RequestToOpenAI(body map[string]any) map[string]any {
	msgs := append(systemMessages(body["system"]), translateMessages(body["messages"])...)
	out := map[string]any{
		"model":    body["model"],
		"messages": msgs,
	}
	copyIf(out, body, "max_tokens", "")
	copyIf(out, body, "temperature", "")
	copyIf(out, body, "top_p", "")
	copyIf(out, body, "stream", "")
	copyIf(out, body, "stop_sequences", "stop")
	putTools(out, body["tools"])
	putToolChoice(out, jsonx.AsMap(body["tool_choice"]))
	putReasoningEffort(out, body)
	return jsonx.DropNil(out)
}

func putReasoningEffort(out, body map[string]any) {
	thinking := jsonx.AsMap(body["thinking"])
	if thinking == nil {
		return
	}
	if _, exists := out["reasoning_effort"]; exists {
		return
	}
	switch jsonx.Str(thinking, "type") {
	case "enabled", "adaptive":
		out["reasoning_effort"] = "high"
	case "disabled":
		out["reasoning_effort"] = "low"
	}
}

func systemMessages(system any) []any {
	switch s := system.(type) {
	case nil:
		return nil
	case string:
		return []any{map[string]any{"role": "system", "content": s}}
	case []any:
		var parts []string
		for _, b := range s {
			if m := jsonx.AsMap(b); m != nil && jsonx.Str(m, "type") == "text" {
				parts = append(parts, jsonx.Str(m, "text"))
			}
		}
		return []any{map[string]any{"role": "system", "content": strings.Join(parts, "\n")}}
	default:
		return nil
	}
}

func translateMessages(raw any) []any {
	list, _ := raw.([]any)
	var out []any
	for _, item := range list {
		out = append(out, translateMessage(jsonx.AsMap(item))...)
	}
	return out
}

func translateMessage(m map[string]any) []any {
	if m == nil {
		return nil
	}
	role := jsonx.Str(m, "role")
	switch c := m["content"].(type) {
	case string:
		return []any{map[string]any{"role": role, "content": c}}
	case []any:
		if role == "assistant" {
			return []any{assistantBlocks(c)}
		}
		if role == "user" {
			return userBlocks(c)
		}
	}
	return []any{m}
}

func assistantBlocks(blocks []any) map[string]any {
	var text strings.Builder
	var toolCalls []any
	for _, b := range blocks {
		m := jsonx.AsMap(b)
		if m == nil {
			continue
		}
		switch jsonx.Str(m, "type") {
		case "text":
			text.WriteString(jsonx.Str(m, "text"))
		case "tool_use":
			args, _ := json.Marshal(m["input"])
			if string(args) == "null" {
				args = []byte("{}")
			}
			toolCalls = append(toolCalls, map[string]any{
				"id":   m["id"],
				"type": "function",
				"function": map[string]any{
					"name":      m["name"],
					"arguments": string(args),
				},
			})
		}
	}
	msg := map[string]any{"role": "assistant"}
	if t := text.String(); t != "" {
		msg["content"] = t
	} else {
		msg["content"] = nil
	}
	if len(toolCalls) > 0 {
		msg["tool_calls"] = toolCalls
	}
	return msg
}

func userBlocks(blocks []any) []any {
	var toolMsgs []any
	var rest []any
	for _, b := range blocks {
		m := jsonx.AsMap(b)
		if m != nil && jsonx.Str(m, "type") == "tool_result" {
			toolMsgs = append(toolMsgs, map[string]any{
				"role":         "tool",
				"tool_call_id": m["tool_use_id"],
				"content":      toolResultContent(m["content"]),
			})
			continue
		}
		rest = append(rest, b)
	}
	userContent := userContentOf(rest)
	var out []any
	out = append(out, toolMsgs...)
	if userContent != nil && userContent != "" {
		if list, ok := userContent.([]any); ok && len(list) == 0 {
			return out
		}
		out = append(out, map[string]any{"role": "user", "content": userContent})
	}
	return out
}

func toolResultContent(c any) string {
	switch t := c.(type) {
	case string:
		return t
	case []any:
		var parts []string
		for _, b := range t {
			if m := jsonx.AsMap(b); m != nil && jsonx.Str(m, "type") == "text" {
				parts = append(parts, jsonx.Str(m, "text"))
			} else {
				raw, _ := json.Marshal(b)
				parts = append(parts, string(raw))
			}
		}
		return strings.Join(parts, "\n")
	default:
		raw, _ := json.Marshal(c)
		return string(raw)
	}
}

func userContentOf(blocks []any) any {
	allText := true
	for _, b := range blocks {
		m := jsonx.AsMap(b)
		if m == nil || jsonx.Str(m, "type") != "text" {
			allText = false
			break
		}
	}
	if allText {
		var s strings.Builder
		for _, b := range blocks {
			s.WriteString(jsonx.Str(jsonx.AsMap(b), "text"))
		}
		return s.String()
	}
	var parts []any
	for _, b := range blocks {
		m := jsonx.AsMap(b)
		if m == nil {
			continue
		}
		switch jsonx.Str(m, "type") {
		case "text":
			parts = append(parts, map[string]any{"type": "text", "text": m["text"]})
		case "image":
			src := jsonx.AsMap(m["source"])
			if jsonx.Str(src, "type") == "base64" {
				url := "data:" + jsonx.Str(src, "media_type") + ";base64," + jsonx.Str(src, "data")
				parts = append(parts, map[string]any{"type": "image_url", "image_url": map[string]any{"url": url}})
			} else {
				parts = append(parts, map[string]any{"type": "image_url", "image_url": map[string]any{"url": jsonx.Str(src, "url")}})
			}
		default:
			raw, _ := json.Marshal(m)
			parts = append(parts, map[string]any{"type": "text", "text": string(raw)})
		}
	}
	return parts
}

func putTools(body map[string]any, tools any) {
	list, ok := tools.([]any)
	if !ok {
		return
	}
	out := make([]any, 0, len(list))
	for _, t := range list {
		m := jsonx.AsMap(t)
		schema := m["input_schema"]
		if schema == nil {
			schema = map[string]any{"type": "object", "properties": map[string]any{}}
		}
		out = append(out, map[string]any{
			"type": "function",
			"function": map[string]any{
				"name":        m["name"],
				"description": m["description"],
				"parameters":  schema,
			},
		})
	}
	body["tools"] = out
}

func putToolChoice(body map[string]any, tc map[string]any) {
	if tc == nil {
		return
	}
	switch jsonx.Str(tc, "type") {
	case "auto":
		body["tool_choice"] = "auto"
	case "any":
		body["tool_choice"] = "required"
	case "tool":
		body["tool_choice"] = map[string]any{
			"type":     "function",
			"function": map[string]any{"name": tc["name"]},
		}
	}
}

func copyIf(acc, body map[string]any, key, as string) {
	if v, ok := body[key]; ok && v != nil {
		if as == "" {
			as = key
		}
		acc[as] = v
	}
}

// ResponseFromModelResponse translates OpenAI chat → Anthropic Messages.
func ResponseFromModelResponse(r *providers.ModelResponse, requestedModel string) map[string]any {
	var choice map[string]any
	if r != nil && len(r.Choices) > 0 {
		choice = jsonx.AsMap(r.Choices[0])
	}
	if choice == nil {
		choice = map[string]any{}
	}
	message := jsonx.AsMap(choice["message"])
	if message == nil {
		message = map[string]any{}
	}
	id := ""
	if r != nil {
		id = r.ID
	}
	if id == "" {
		id = providers.RandID(12)
	}
	return map[string]any{
		"id":            "msg_" + id,
		"type":          "message",
		"role":          "assistant",
		"model":         requestedModel,
		"content":       buildContentBlocks(message),
		"stop_reason":   StopReason(strField(choice, "finish_reason")),
		"stop_sequence": nil,
		"usage": Usage(jsonx.AsMap(func() any {
			if r == nil {
				return nil
			}
			return r.Usage
		}())),
	}
}

func buildContentBlocks(message map[string]any) []any {
	var blocks []any
	reasoning := jsonx.Str(message, "reasoning")
	if reasoning == "" {
		reasoning = jsonx.Str(message, "reasoning_content")
	}
	if reasoning != "" {
		blocks = append(blocks, map[string]any{"type": "thinking", "thinking": reasoning})
	}
	text := jsonx.Str(message, "content")
	if text != "" {
		blocks = append(blocks, map[string]any{"type": "text", "text": text})
	}
	var toolCalls []any
	switch t := message["tool_calls"].(type) {
	case []any:
		toolCalls = t
	}
	for _, tc := range toolCalls {
		m := jsonx.AsMap(tc)
		fun := jsonx.AsMap(m["function"])
		id := jsonx.Str(m, "id")
		if id == "" {
			id = "toolu_" + providers.RandID(12)
		}
		blocks = append(blocks, map[string]any{
			"type":  "tool_use",
			"id":    id,
			"name":  jsonx.Str(fun, "name"),
			"input": decodeArgs(fun["arguments"]),
		})
	}
	if len(blocks) == 0 {
		return []any{map[string]any{"type": "text", "text": ""}}
	}
	return blocks
}

func decodeArgs(args any) any {
	switch t := args.(type) {
	case nil:
		return map[string]any{}
	case map[string]any:
		return t
	case string:
		var m map[string]any
		if err := json.Unmarshal([]byte(t), &m); err == nil {
			return m
		}
		return map[string]any{}
	default:
		return map[string]any{}
	}
}

func strField(m map[string]any, k string) string {
	if s, ok := m[k].(string); ok {
		return s
	}
	return ""
}

// StopReason maps an OpenAI finish_reason to Anthropic stop_reason.
func StopReason(r string) string {
	switch r {
	case "stop":
		return "end_turn"
	case "length":
		return "max_tokens"
	case "tool_calls":
		return "tool_use"
	case "content_filter":
		return "refusal"
	case "":
		return "end_turn"
	default:
		return r
	}
}

// Usage maps OpenAI usage → Anthropic usage.
func Usage(u map[string]any) map[string]any {
	if u == nil {
		return map[string]any{"input_tokens": 0, "output_tokens": 0}
	}
	in, _ := jsonx.Int(u, "prompt_tokens")
	out, _ := jsonx.Int(u, "completion_tokens")
	return map[string]any{"input_tokens": in, "output_tokens": out}
}

// StreamPreamble is message_start + content_block_start.
func StreamPreamble(model string) []string {
	message := map[string]any{
		"id": "msg_" + providers.RandID(12), "type": "message", "role": "assistant",
		"model": model, "content": []any{}, "stop_reason": nil, "stop_sequence": nil,
		"usage": map[string]any{"input_tokens": 0, "output_tokens": 0},
	}
	return []string{
		SSE("message_start", map[string]any{"type": "message_start", "message": message}),
		SSE("content_block_start", map[string]any{
			"type": "content_block_start", "index": 0,
			"content_block": map[string]any{"type": "text", "text": ""},
		}),
	}
}

// StreamTextDelta is one content_block_delta.
func StreamTextDelta(text string) string {
	return SSE("content_block_delta", map[string]any{
		"type": "content_block_delta", "index": 0,
		"delta": map[string]any{"type": "text_delta", "text": text},
	})
}

// StreamClosing is content_block_stop + message_delta + message_stop.
func StreamClosing(finishReason string, usage map[string]any) []string {
	outTok, _ := jsonx.Int(usage, "completion_tokens")
	return []string{
		SSE("content_block_stop", map[string]any{"type": "content_block_stop", "index": 0}),
		SSE("message_delta", map[string]any{
			"type":  "message_delta",
			"delta": map[string]any{"stop_reason": StopReason(finishReason), "stop_sequence": nil},
			"usage": map[string]any{"output_tokens": outTok},
		}),
		SSE("message_stop", map[string]any{"type": "message_stop"}),
	}
}

// SSE formats one Anthropic SSE frame.
func SSE(event string, data any) string {
	b, _ := json.Marshal(data)
	return "event: " + event + "\ndata: " + string(b) + "\n\n"
}
