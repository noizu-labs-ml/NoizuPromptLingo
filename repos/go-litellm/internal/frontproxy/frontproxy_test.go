package frontproxy

import (
	"strings"
	"testing"

	"github.com/noizu-labs/go-litellm/internal/runtime"
)

func TestPassthroughRouting(t *testing.T) {
	r := NewRules("passthrough", runtime.Settings{Host: "127.0.0.1", Port: 4445})

	d := r.Route("/v1/chat/completions", map[string]any{})
	if d.Auth != AuthMasterKey || !strings.Contains(d.BaseURL, "4445") {
		t.Fatalf("%+v", d)
	}
	d = r.Route("/v1/embeddings", map[string]any{})
	if d.Auth != AuthMasterKey {
		t.Fatalf("%+v", d)
	}
	d = r.Route("/v1/messages", map[string]any{"model": "claude-haiku-4-5"})
	if d.BaseURL != AnthropicAPI || d.Auth != AuthPassthrough {
		t.Fatalf("%+v", d)
	}
	d = r.Route("/v1/messages", map[string]any{"model": "gpt-4o"})
	if d.Auth != AuthMasterKey || d.BaseURL == AnthropicAPI {
		t.Fatalf("%+v", d)
	}
	d = r.Route("/v1/messages/count_tokens", map[string]any{"model": "gpt-4o"})
	if d.BaseURL != AnthropicAPI || d.Auth != AuthPassthrough {
		t.Fatalf("%+v", d)
	}
	d = r.Route("/v1/foo", map[string]any{})
	if d.BaseURL != AnthropicAPI {
		t.Fatalf("%+v", d)
	}
}

func TestStandardRouting(t *testing.T) {
	r := NewRules("standard", runtime.Settings{Host: "127.0.0.1", Port: 4445})
	d := r.Route("/v1/messages", map[string]any{"model": "claude-x"})
	if d.Auth != AuthMasterKey {
		t.Fatalf("%+v", d)
	}
	d = r.Route("/anything", map[string]any{})
	if d.Auth != AuthMasterKey {
		t.Fatalf("%+v", d)
	}
}

func TestCustomRules(t *testing.T) {
	r := NewRules("passthrough", runtime.Settings{})
	r.Put([]Rule{{MatchType: MatchAny, TargetType: TargetURL, TargetURL: "https://example.com", Auth: AuthPassthrough}})
	d := r.Route("/v1/chat/completions", map[string]any{})
	if d.BaseURL != "https://example.com" || r.Mode() != "custom" {
		t.Fatalf("%+v mode=%s", d, r.Mode())
	}
	r.SetMode("passthrough")
}
