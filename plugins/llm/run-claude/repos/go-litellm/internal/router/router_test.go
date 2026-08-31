package router

import (
	"testing"
	"time"

	"github.com/noizu-labs/go-litellm/internal/jsonx"
)

func TestAddDeleteUpdate(t *testing.T) {
	r := New(nil)
	stored := r.Add(map[string]any{"model_name": "m1", "litellm_params": map[string]any{"model": "openai/gpt-4o"}})
	if jsonx.Str(stored, "model_id") == "" {
		t.Fatal("missing model_id")
	}
	got, ok := r.Select("m1")
	if !ok || jsonx.Str(got, "model_name") != "m1" {
		t.Fatalf("%+v %v", got, ok)
	}

	stored2 := r.Add(map[string]any{"model_name": "m2", "litellm_params": map[string]any{}})
	if !r.Delete(jsonx.Str(stored2, "model_id")) {
		t.Fatal("delete failed")
	}
	if _, ok := r.Select("m2"); ok {
		t.Fatal("m2 should be gone")
	}
	if r.Delete("nope") {
		t.Fatal("unknown delete")
	}

	stored3 := r.Add(map[string]any{"model_name": "m3", "litellm_params": map[string]any{"model": "x", "api_base": "a"}})
	updated, ok := r.Update(jsonx.Str(stored3, "model_id"), map[string]any{"litellm_params": map[string]any{"api_base": "b"}})
	if !ok {
		t.Fatal("update")
	}
	lp := jsonx.Nested(updated, "litellm_params")
	if jsonx.Str(lp, "api_base") != "b" || jsonx.Str(lp, "model") != "x" {
		t.Fatalf("%+v", lp)
	}
}

func TestBindKeyFamilyDoesNotTouchTyna(t *testing.T) {
	r := New(nil)
	r.Keys.Put("zai", "main", "ZAI_SUB_KEY", "env")
	r.Keys.Put("tyna", "other", "ZAI_SUB_KEY_TYNA", "env")
	r.Add(map[string]any{"model_name": "zai/opus", "litellm_params": map[string]any{"api_key": "main", "api_key_name": "zai"}})
	r.Add(map[string]any{"model_name": "zai-tyna/opus", "litellm_params": map[string]any{"api_key": "other", "api_key_name": "tyna"}})
	updated := r.BindKey(BindSpec{Target: "zai"}, "tyna")
	if len(updated) != 1 || updated[0] != "zai/opus" {
		t.Fatalf("%v", updated)
	}
	got := r.Lookup("zai/opus")
	lp := jsonx.Nested(got, "litellm_params")
	if jsonx.Str(lp, "api_key_name") != "tyna" || jsonx.Str(lp, "api_key") != "other" {
		t.Fatalf("%+v", lp)
	}
	kept := r.Lookup("zai-tyna/opus")
	klp := jsonx.Nested(kept, "litellm_params")
	if jsonx.Str(klp, "api_key_name") != "tyna" {
		t.Fatalf("tyna family clobbered: %+v", klp)
	}
}

func TestLookupStrips1mSuffix(t *testing.T) {
	r := New(nil)
	r.Add(map[string]any{"model_name": "groq/opus", "litellm_params": map[string]any{"model": "groq/openai/gpt-oss-120b"}})
	got := r.Lookup("groq/opus[1m]")
	if got == nil || jsonx.Str(got, "model_name") != "groq/opus" {
		t.Fatalf("%+v", got)
	}
}

func TestCooldownSkip(t *testing.T) {
	r := New(nil)
	a := r.Add(map[string]any{"model_name": "g", "litellm_params": map[string]any{"model": "a"}})
	_ = r.Add(map[string]any{"model_name": "g", "litellm_params": map[string]any{"model": "b"}})
	r.cooldowns.Add(jsonx.Str(a, "model_id"), "boom", time.Minute)
	for i := 0; i < 10; i++ {
		picked, ok := r.Select("g")
		if !ok {
			t.Fatal("select")
		}
		if jsonx.Str(jsonx.Nested(picked, "litellm_params"), "model") != "b" {
			t.Fatalf("picked %+v", picked)
		}
	}
}

func TestCooldownFailOpen(t *testing.T) {
	r := New(nil)
	a := r.Add(map[string]any{"model_name": "solo2", "litellm_params": map[string]any{}})
	r.cooldowns.Add(jsonx.Str(a, "model_id"), "boom", time.Minute)
	got, ok := r.Select("solo2")
	if !ok || jsonx.Str(got, "model_name") != "solo2" {
		t.Fatalf("%+v %v", got, ok)
	}
}
