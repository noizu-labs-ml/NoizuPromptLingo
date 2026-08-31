package core

import (
	"testing"

	"github.com/noizu-labs/go-litellm/internal/providers"
)

func TestOptionalOpenAIKeepsParams(t *testing.T) {
	params := map[string]any{"model": "gpt-4o", "messages": []any{}, "temperature": 0.7, "max_tokens": 100}
	out := Optional(params, providers.OpenAI, "gpt-4o", true)
	if out["temperature"] != 0.7 || out["max_tokens"] != 100 || out["model"] != "gpt-4o" {
		t.Fatalf("%+v", out)
	}
}

func TestOptionalGroqDropsUnsupported(t *testing.T) {
	params := map[string]any{
		"model": "llama-3", "messages": []any{}, "temperature": 0.5,
		"logit_bias": map[string]any{"50256": -100}, "top_logprobs": 5,
	}
	out := Optional(params, providers.Groq, "llama-3", true)
	if out["temperature"] != 0.5 {
		t.Fatalf("temp %+v", out)
	}
	if _, ok := out["logit_bias"]; ok {
		t.Fatal("logit_bias should be dropped")
	}
	if _, ok := out["top_logprobs"]; ok {
		t.Fatal("top_logprobs should be dropped")
	}
}

func TestOptionalGroqKeepsWhenNotDropping(t *testing.T) {
	params := map[string]any{"model": "llama-3", "messages": []any{}, "logit_bias": map[string]any{"1": 1}}
	out := Optional(params, providers.Groq, "llama-3", false)
	if _, ok := out["logit_bias"]; !ok {
		t.Fatal("expected logit_bias kept")
	}
}
