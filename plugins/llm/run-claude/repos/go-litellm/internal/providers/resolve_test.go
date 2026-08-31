package providers

import "testing"

func TestResolvePrefix(t *testing.T) {
	r, e := Resolve("anthropic/claude-3-5-sonnet", nil)
	if e != nil || r.Provider != "anthropic" || r.Model != "claude-3-5-sonnet" || r.Adapter.Name() != "anthropic" {
		t.Fatalf("%+v %v", r, e)
	}
	r, e = Resolve("openai/gpt-4o", nil)
	if e != nil || r.Provider != "openai" || r.Model != "gpt-4o" {
		t.Fatalf("%+v %v", r, e)
	}
	r, e = Resolve("groq/llama-3", nil)
	if e != nil || r.Provider != "groq" || r.Model != "llama-3" {
		t.Fatalf("%+v %v", r, e)
	}
}

func TestResolvePattern(t *testing.T) {
	r, e := Resolve("claude-3-5-sonnet-20241022", nil)
	if e != nil || r.Provider != "anthropic" {
		t.Fatalf("%+v %v", r, e)
	}
	r, _ = Resolve("gpt-4o", nil)
	if r.Provider != "openai" {
		t.Fatalf("%s", r.Provider)
	}
	r, _ = Resolve("o3-mini", nil)
	if r.Provider != "openai" {
		t.Fatalf("%s", r.Provider)
	}
}

func TestResolveEndpoint(t *testing.T) {
	r, e := Resolve("some-model", map[string]any{"api_base": "https://api.groq.com/openai/v1"})
	if e != nil || r.Provider != "groq" || r.Model != "some-model" {
		t.Fatalf("%+v %v", r, e)
	}
}

func TestResolveDefault(t *testing.T) {
	r, e := Resolve("mystery-model", nil)
	if e != nil || r.Provider != "openai_compatible" || r.Adapter.Name() != "openai" {
		t.Fatalf("%+v %v", r, e)
	}
}
