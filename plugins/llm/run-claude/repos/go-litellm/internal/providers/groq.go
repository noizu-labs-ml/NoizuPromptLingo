package providers

import (
	"strings"

	"github.com/noizu-labs/go-litellm/internal/jsonx"
)

const minGptOSSCompletion = 2048

// ShapeGroq sanitizes a chat body for Groq's strict API.
//
// GPT-OSS models put CoT in `reasoning` and can exhaust max_tokens before any
// `content` is produced (Claude Code then shows an empty turn). Hide reasoning
// on the wire, alias max_tokens → max_completion_tokens, and coerce illegal
// reasoning_effort values so Groq does not 400.
func ShapeGroq(body map[string]any, model string) map[string]any {
	if body == nil {
		body = map[string]any{}
	}
	body = sanitizeEffort(body)
	sanitizeToolSchemas(body)
	if gptOSS(model) {
		if _, ok := body["include_reasoning"]; !ok {
			body["include_reasoning"] = false
		}
		n := asInt(body["max_completion_tokens"])
		if n == 0 {
			n = asInt(body["max_tokens"])
		}
		if n < minGptOSSCompletion {
			n = minGptOSSCompletion
		}
		body["max_completion_tokens"] = n
		delete(body, "max_tokens")
	}
	return body
}

func gptOSS(model string) bool {
	return strings.Contains(model, "gpt-oss")
}

// Groq compiles tool JSON Schema (draft 2020-12) and rejects Claude Code
// patterns such as ^[A-Za-z0-9_=-]{1,4096}$ (invalid character-class range
// under format:regex). Strip pattern / patternProperties so the request is
// accepted; the model still sees property names and types.
func sanitizeToolSchemas(body map[string]any) {
	tools, ok := body["tools"].([]any)
	if !ok {
		return
	}
	out := make([]any, len(tools))
	for i, t := range tools {
		m := jsonx.AsMap(t)
		if m == nil {
			out[i] = t
			continue
		}
		tool := jsonx.Clone(m)
		if fn := jsonx.AsMap(tool["function"]); fn != nil {
			fn = jsonx.Clone(fn)
			if schema := jsonx.AsMap(fn["parameters"]); schema != nil {
				fn["parameters"] = stripJSONSchemaPatterns(schema)
			}
			tool["function"] = fn
		}
		out[i] = tool
	}
	body["tools"] = out
}

func stripJSONSchemaPatterns(v any) any {
	switch n := v.(type) {
	case map[string]any:
		out := make(map[string]any, len(n))
		for k, child := range n {
			if k == "pattern" || k == "patternProperties" {
				continue
			}
			out[k] = stripJSONSchemaPatterns(child)
		}
		return out
	case []any:
		out := make([]any, len(n))
		for i, child := range n {
			out[i] = stripJSONSchemaPatterns(child)
		}
		return out
	default:
		return v
	}
}

func sanitizeEffort(body map[string]any) map[string]any {
	v, ok := body["reasoning_effort"].(string)
	if !ok {
		delete(body, "reasoning_effort")
		return body
	}
	switch v {
	case "low", "medium", "high", "none", "default":
		return body
	case "max", "xhigh", "highest":
		body["reasoning_effort"] = "high"
	case "enabled", "adaptive", "auto":
		body["reasoning_effort"] = "medium"
	case "minimal", "min":
		body["reasoning_effort"] = "low"
	default:
		delete(body, "reasoning_effort")
	}
	return body
}

func asInt(v any) int {
	switch n := v.(type) {
	case int:
		return n
	case int64:
		return int(n)
	case float64:
		return int(n)
	default:
		return 0
	}
}
