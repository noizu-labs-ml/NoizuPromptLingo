package providers

import (
	"crypto/rand"
	"encoding/base64"
	"os"
	"strings"
	"time"

	"github.com/noizu-labs/go-litellm/internal/config"
	"github.com/noizu-labs/go-litellm/internal/errx"
	"github.com/noizu-labs/go-litellm/internal/jsonx"
)

// DefaultSupported is the OpenAI Chat Completions param surface.
var DefaultSupported = []string{
	"model", "messages", "temperature", "top_p", "n", "stream", "stream_options", "stop", "max_tokens",
	"max_completion_tokens", "presence_penalty", "frequency_penalty", "logit_bias", "user",
	"response_format", "seed", "tools", "tool_choice", "parallel_tool_calls", "functions",
	"function_call", "logprobs", "top_logprobs", "reasoning_effort", "include_reasoning",
	"reasoning_format", "metadata",
}

// Compat is a thin OpenAI-compatible provider (Groq, Cerebras, …).
type Compat struct {
	name        string
	baseURL     string
	apiKeyEnv   string
	chatPath    string
	embedPath   string
	unsupported map[string]bool
	allowNoKey  bool
}

func newCompat(name, baseURL, apiKeyEnv string, unsupported []string, allowNoKey bool) *Compat {
	u := map[string]bool{}
	for _, k := range unsupported {
		u[k] = true
	}
	return &Compat{
		name: name, baseURL: baseURL, apiKeyEnv: apiKeyEnv,
		chatPath: "/chat/completions", embedPath: "/embeddings",
		unsupported: u, allowNoKey: allowNoKey,
	}
}

func (c *Compat) Name() string { return c.name }

func (c *Compat) SupportedParams(_ string) []string {
	if len(c.unsupported) == 0 {
		return DefaultSupported
	}
	var out []string
	for _, k := range DefaultSupported {
		if !c.unsupported[k] {
			out = append(out, k)
		}
	}
	return out
}

func (c *Compat) MapOpenAIParams(nonDefault, optional map[string]any, model string, drop bool) map[string]any {
	supported := map[string]bool{}
	for _, k := range c.SupportedParams(model) {
		supported[k] = true
	}
	out := jsonx.Clone(optional)
	for k, v := range nonDefault {
		switch {
		case supported[k]:
			out[k] = v
		case drop:
			// drop
		default:
			out[k] = v
		}
	}
	return out
}

func (c *Compat) ValidateEnvironment(req *Request, headers map[string]string) (map[string]string, *errx.Error) {
	if headers == nil {
		headers = map[string]string{}
	}
	headers["content-type"] = "application/json"
	key := resolveAPIKey(req.LiteLLMParams, c.apiKeyEnv)
	if key == "" {
		if c.allowNoKey {
			return headers, nil
		}
		env := c.apiKeyEnv
		if env == "" {
			env = "(no env)"
		}
		return nil, errx.New(401, "no API key found (checked litellm_params.api_key and "+env+")", errx.WithType("authentication_error"))
	}
	headers["authorization"] = "Bearer " + key
	return headers, nil
}

func (c *Compat) CompleteURL(req *Request) string {
	base := strings.TrimRight(jsonx.Str(req.LiteLLMParams, "api_base"), "/")
	if base == "" {
		base = strings.TrimRight(c.baseURL, "/")
	}
	path := c.chatPath
	if req.CallType == "embedding" {
		path = c.embedPath
	}
	if strings.HasSuffix(base, path) {
		return base
	}
	return base + path
}

func (c *Compat) TransformRequest(req *Request) map[string]any {
	body := jsonx.Clone(req.Params)
	body["model"] = req.Model
	return jsonx.DropNil(body)
}

func (c *Compat) TransformResponse(raw map[string]any, req *Request) *ModelResponse {
	return NewModelResponse(map[string]any{
		"id":                 raw["id"],
		"object":             firstNonNil(raw["object"], "chat.completion"),
		"created":            raw["created"],
		"model":              firstNonNil(raw["model"], req.Model),
		"choices":            firstNonNil(raw["choices"], []any{}),
		"usage":              raw["usage"],
		"system_fingerprint": raw["system_fingerprint"],
	})
}

func (c *Compat) ErrorClass(status int, body any, _ map[string]string) *errx.Error {
	return errx.New(status, extractErrorMessage(body))
}

func (c *Compat) ChunkParser(event any) StreamChunk {
	if event == nil {
		return StreamChunk{Done: true}
	}
	if s, ok := event.(string); ok && s == "done" {
		return StreamChunk{Done: true}
	}
	m := jsonx.AsMap(event)
	if m == nil {
		return StreamChunk{}
	}
	choices, _ := m["choices"].([]any)
	var choice map[string]any
	if len(choices) > 0 {
		choice = jsonx.AsMap(choices[0])
	}
	if choice == nil {
		choice = map[string]any{}
	}
	delta := jsonx.AsMap(choice["delta"])
	if delta == nil {
		delta = map[string]any{}
	}
	text, _ := delta["content"].(string)
	reasoning := ""
	if r, ok := delta["reasoning"].(string); ok {
		reasoning = r
	} else if r, ok := delta["reasoning_content"].(string); ok {
		reasoning = r
	}
	idx, _ := jsonx.Int(choice, "index")
	return StreamChunk{
		Text:         text,
		Reasoning:    reasoning,
		IsFinished:   choice["finish_reason"] != nil,
		FinishReason: choice["finish_reason"],
		Usage:        m["usage"],
		ToolUse:      delta["tool_calls"],
		Index:        idx,
		Raw:          event,
	}
}

func resolveAPIKey(lp map[string]any, apiKeyEnv string) string {
	if k := jsonx.Str(lp, "api_key"); k != "" {
		if s, ok := config.Resolve(k).(string); ok {
			return s
		}
	}
	if apiKeyEnv != "" {
		return strings.TrimSpace(os.Getenv(apiKeyEnv))
	}
	return ""
}

func extractErrorMessage(body any) string {
	m := jsonx.AsMap(body)
	if m != nil {
		if errm := jsonx.AsMap(m["error"]); errm != nil {
			if msg := jsonx.Str(errm, "message"); msg != "" {
				return msg
			}
		}
		if msg, ok := m["error"].(string); ok {
			return msg
		}
		if msg := jsonx.Str(m, "message"); msg != "" {
			return msg
		}
	}
	if s, ok := body.(string); ok && s != "" {
		return s
	}
	return "upstream provider error"
}

func firstNonNil(vals ...any) any {
	for _, v := range vals {
		if v != nil {
			return v
		}
	}
	return nil
}

// NewModelResponse fills id/created defaults.
func NewModelResponse(fields map[string]any) *ModelResponse {
	r := &ModelResponse{
		Object:  "chat.completion",
		Choices: []any{},
	}
	if s, ok := fields["id"].(string); ok {
		r.ID = s
	}
	if s, ok := fields["object"].(string); ok && s != "" {
		r.Object = s
	}
	switch v := fields["created"].(type) {
	case int64:
		r.Created = v
	case int:
		r.Created = int64(v)
	case float64:
		r.Created = int64(v)
	}
	if s, ok := fields["model"].(string); ok {
		r.Model = s
	}
	if ch, ok := fields["choices"].([]any); ok {
		r.Choices = ch
	}
	r.Usage = fields["usage"]
	r.SystemFingerprint = fields["system_fingerprint"]
	if r.ID == "" {
		r.ID = "chatcmpl-" + RandID(16)
	}
	if r.Created == 0 {
		r.Created = time.Now().Unix()
	}
	return r
}

// RandID returns n random bytes, URL-safe base64 without padding.
func RandID(n int) string {
	buf := make([]byte, n)
	_, _ = rand.Read(buf)
	return base64.RawURLEncoding.EncodeToString(buf)
}

// Registered OpenAI-compatible providers.
var (
	OpenAI     Adapter = newCompat("openai", "https://api.openai.com/v1", "OPENAI_API_KEY", nil, false)
	Groq       Adapter = newCompat("groq", "https://api.groq.com/openai/v1", "GROQ_API_KEY", []string{"logit_bias", "logprobs", "top_logprobs"}, false)
	Cerebras   Adapter = newCompat("cerebras", "https://api.cerebras.ai/v1", "CEREBRAS_API_KEY", []string{"logit_bias", "logprobs", "top_logprobs", "frequency_penalty", "presence_penalty"}, false)
	DeepSeek   Adapter = newCompat("deepseek", "https://api.deepseek.com/v1", "DEEPSEEK_API_KEY", nil, false)
	XAI        Adapter = newCompat("xai", "https://api.x.ai/v1", "GROK_API_KEY", nil, false)
	Mistral    Adapter = newCompat("mistral", "https://api.mistral.ai/v1", "MISTRAL_API_KEY", nil, false)
	Perplexity Adapter = newCompat("perplexity", "https://api.perplexity.ai", "PERPLEXITYAI_API_KEY", nil, false)
	Ollama     Adapter = newCompat("ollama", "http://localhost:11434/v1", "", nil, true)
)
