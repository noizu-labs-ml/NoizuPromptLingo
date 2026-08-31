package keys

import (
	"testing"
)

func TestNameFromEnv(t *testing.T) {
	cases := map[string]string{
		"ZAI_SUB_KEY":       "zai",
		"ZAI_SUB_KEY_TYNA":  "tyna",
		"CEREBRAS_SUB_KEY":  "cerebras",
		"QWEN_SUB_KEY":      "qwen",
		"ANTHROPIC_API_KEY": "anthropic",
		"FOO_SUB_KEY":       "foo",
		"ACME_SUB_KEY_BETA": "beta",
	}
	for env, want := range cases {
		got, ok := NameFromEnv(env)
		if !ok || got != want {
			t.Errorf("%s: got %q ok=%v want %q", env, got, ok, want)
		}
	}
	if _, ok := NameFromEnv("PATH"); ok {
		t.Fatal("PATH should not be a key env")
	}
}

func TestCanonicalAliases(t *testing.T) {
	if Canonical("zai-tyna") != "tyna" {
		t.Fatal(Canonical("zai-tyna"))
	}
	if Canonical("TYNA") != "tyna" {
		t.Fatal(Canonical("TYNA"))
	}
}

func TestMatchesFamily(t *testing.T) {
	if !Matches("zai/haiku", "zai") {
		t.Fatal("family")
	}
	if !Matches("zai/opus[1m]", "zai") {
		t.Fatal("1m")
	}
	if Matches("zai-tyna/haiku", "zai") {
		t.Fatal("must not match zai-tyna under zai")
	}
	if !Matches("zai-tyna/haiku", "zai-tyna") {
		t.Fatal("tyna family")
	}
	if !Matches("zai/haiku", "zai/") {
		t.Fatal("prefix slash")
	}
	if !Matches("zai/opus", "zai/opus") {
		t.Fatal("exact")
	}
}

func TestResolvePrefersNamedKey(t *testing.T) {
	s := New()
	s.Put("zai", "default-secret", "ZAI_SUB_KEY", "env")
	s.Put("tyna", "tyna-secret", "ZAI_SUB_KEY_TYNA", "env")
	lp := map[string]any{"api_key": "default-secret", "api_key_name": "tyna"}
	if got := s.Resolve(lp); got != "tyna-secret" {
		t.Fatalf("got %q", got)
	}
}

func TestSeedFromEnv(t *testing.T) {
	t.Setenv("ZAI_SUB_KEY", "main-key")
	t.Setenv("ZAI_SUB_KEY_TYNA", "tyna-key")
	s := New()
	s.SeedFromEnv()
	if s.Value("zai") != "main-key" {
		t.Fatalf("zai=%q", s.Value("zai"))
	}
	if s.Value("tyna") != "tyna-key" {
		t.Fatalf("tyna=%q", s.Value("tyna"))
	}
	if s.Value("zai-tyna") != "tyna-key" {
		t.Fatalf("alias=%q", s.Value("zai-tyna"))
	}
}

func TestInferNameFromEnvRef(t *testing.T) {
	s := New()
	lp := map[string]any{"api_key": "os.environ/ZAI_SUB_KEY_TYNA"}
	s.InferName(lp)
	if lp["api_key_name"] != "tyna" {
		t.Fatalf("%+v", lp)
	}
}

func TestInferNameFromValue(t *testing.T) {
	s := New()
	s.Put("tyna", "abc", "ZAI_SUB_KEY_TYNA", "env")
	lp := map[string]any{"api_key": "abc"}
	s.InferName(lp)
	if lp["api_key_name"] != "tyna" {
		t.Fatalf("%+v", lp)
	}
}

func TestListRedacts(t *testing.T) {
	s := New()
	s.Put("tyna", "super-secret-key", "ZAI_SUB_KEY_TYNA", "env")
	list := s.List()
	if len(list) != 1 || list[0].Preview == "super-secret-key" || !list[0].Configured {
		t.Fatalf("%+v", list)
	}
	if list[0].Preview != "…-key" {
		t.Fatalf("preview %q", list[0].Preview)
	}
}

func TestSeedKeepsUnsetBuiltin(t *testing.T) {
	t.Setenv("ZAI_SUB_KEY_TYNA", "")
	t.Setenv("ZAI_SUB_KEY", "x")
	s := New()
	s.SeedFromEnv()
	e := s.Get("tyna")
	if e == nil {
		t.Fatal("tyna should be listed even when unset")
	}
	if e.Env != "ZAI_SUB_KEY_TYNA" {
		t.Fatalf("%+v", e)
	}
}
