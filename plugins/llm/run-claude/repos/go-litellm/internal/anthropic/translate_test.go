package anthropic

import (
	"testing"

	"github.com/noizu-labs/go-litellm/internal/providers"
)

func TestRequestToOpenAISystemAndTools(t *testing.T) {
	body := map[string]any{
		"model":      "gpt-4o",
		"max_tokens": 32,
		"system":     "be nice",
		"messages":   []any{map[string]any{"role": "user", "content": "hi"}},
		"tools": []any{
			map[string]any{"name": "lookup", "description": "d", "input_schema": map[string]any{"type": "object"}},
		},
	}
	out := RequestToOpenAI(body)
	msgs := out["messages"].([]any)
	sys := msgs[0].(map[string]any)
	if sys["role"] != "system" || sys["content"] != "be nice" {
		t.Fatalf("%+v", msgs)
	}
	if out["max_tokens"] != 32 {
		t.Fatalf("%v", out["max_tokens"])
	}
	tools := out["tools"].([]any)
	fn := tools[0].(map[string]any)["function"].(map[string]any)
	if fn["name"] != "lookup" {
		t.Fatalf("%+v", fn)
	}
}

func TestResponseFromModelResponse(t *testing.T) {
	resp := providers.NewModelResponse(map[string]any{
		"id": "abc",
		"choices": []any{
			map[string]any{
				"finish_reason": "stop",
				"message":       map[string]any{"role": "assistant", "content": "hello"},
			},
		},
		"usage": map[string]any{"prompt_tokens": 3, "completion_tokens": 2},
	})
	out := ResponseFromModelResponse(resp, "my-model")
	if out["stop_reason"] != "end_turn" || out["model"] != "my-model" {
		t.Fatalf("%+v", out)
	}
	u := out["usage"].(map[string]any)
	if u["input_tokens"] != 3 || u["output_tokens"] != 2 {
		t.Fatalf("%+v", u)
	}
}

func TestThinkingMapsToReasoningEffort(t *testing.T) {
	out := RequestToOpenAI(map[string]any{
		"model":      "groq/opus",
		"max_tokens": 8,
		"messages":   []any{map[string]any{"role": "user", "content": "hi"}},
		"thinking":   map[string]any{"type": "enabled", "budget_tokens": 32},
	})
	if out["reasoning_effort"] != "high" {
		t.Fatalf("%+v", out)
	}
}

func TestStopReason(t *testing.T) {
	if StopReason("stop") != "end_turn" || StopReason("tool_calls") != "tool_use" {
		t.Fatal(StopReason("stop"), StopReason("tool_calls"))
	}
}
