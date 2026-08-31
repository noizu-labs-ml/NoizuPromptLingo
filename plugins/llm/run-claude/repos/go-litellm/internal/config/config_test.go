package config

import (
	"testing"
)

func TestFromMapCanonicalSections(t *testing.T) {
	cfg, err := FromMap(map[string]any{
		"model_list":       []any{map[string]any{"model_name": "gpt-4o"}},
		"litellm_settings": map[string]any{"drop_params": true},
		"router_settings":  map[string]any{"routing_strategy": "simple-shuffle"},
		"general_settings": map[string]any{"master_key": "sk-abc"},
		"front_proxy":      map[string]any{"mode": "standard"},
	})
	if err != nil {
		t.Fatal(err)
	}
	if len(cfg.ModelList) != 1 || cfg.ModelList[0]["model_name"] != "gpt-4o" {
		t.Fatalf("model_list: %+v", cfg.ModelList)
	}
	if !cfg.DropParams() {
		t.Fatal("expected drop_params")
	}
	if cfg.FrontProxyMode() != "standard" {
		t.Fatalf("mode %s", cfg.FrontProxyMode())
	}
}

func TestFromMapOsEnviron(t *testing.T) {
	t.Setenv("GO_LITELLM_TEST_KEY", "resolved-secret")
	cfg, err := FromMap(map[string]any{
		"model_list": []any{
			map[string]any{
				"model_name":     "m",
				"litellm_params": map[string]any{"api_key": "os.environ/GO_LITELLM_TEST_KEY"},
			},
		},
	})
	if err != nil {
		t.Fatal(err)
	}
	lp := cfg.ModelList[0]["litellm_params"].(map[string]any)
	if lp["api_key"] != "resolved-secret" {
		t.Fatalf("api_key=%v", lp["api_key"])
	}
}

func TestFromMapRejectsNonMap(t *testing.T) {
	if _, err := FromMap(nil); err == nil {
		t.Fatal("expected error")
	}
}
