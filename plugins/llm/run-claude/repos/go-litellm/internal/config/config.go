// Package config loads a litellm-style config.yaml (model_list, settings, front_proxy).
package config

import (
	"fmt"
	"log"
	"os"
	"strings"
	"sync"

	"github.com/noizu-labs/go-litellm/internal/jsonx"
	"gopkg.in/yaml.v3"
)

// known top-level keys (anything else is ignored with a warning).
var knownKeys = map[string]bool{
	"model_list": true, "litellm_settings": true, "router_settings": true,
	"general_settings": true, "environment_variables": true,
	"finetune_settings": true, "files_settings": true, "front_proxy": true,
}

// Config is the hydrated snapshot of a litellm config.yaml.
type Config struct {
	mu              sync.RWMutex
	ModelList       []map[string]any
	LiteLLMSettings map[string]any
	RouterSettings  map[string]any
	GeneralSettings map[string]any
	FrontProxy      map[string]any
	Raw             map[string]any
}

// Empty returns a zero config.
func Empty() *Config {
	return &Config{
		ModelList:       []map[string]any{},
		LiteLLMSettings: map[string]any{},
		RouterSettings:  map[string]any{},
		GeneralSettings: map[string]any{},
		FrontProxy:      map[string]any{},
		Raw:             map[string]any{},
	}
}

// LoadFile reads and hydrates a YAML config. Missing path → empty config, nil error.
func LoadFile(path string) (*Config, error) {
	if path == "" {
		return Empty(), nil
	}
	raw, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("config_read_failed: %s: %w", path, err)
	}
	var parsed any
	if err := yaml.Unmarshal(raw, &parsed); err != nil {
		return nil, fmt.Errorf("config_parse_failed: %w", err)
	}
	parsed = jsonx.StringKeys(parsed)
	m := jsonx.AsMap(parsed)
	if m == nil {
		return nil, fmt.Errorf("config_not_a_map")
	}
	return FromMap(m)
}

// FromMap hydrates an already-parsed map (tests + environment_variables).
func FromMap(parsed map[string]any) (*Config, error) {
	if parsed == nil {
		return nil, fmt.Errorf("config_not_a_map")
	}
	for k := range parsed {
		if !knownKeys[k] {
			log.Printf("[config] ignoring unknown top-level key: %s", k)
		}
	}
	applyEnvironmentVariables(jsonx.AsMap(parsed["environment_variables"]))
	hydrated := jsonx.AsMap(ResolveDeep(parsed))
	if hydrated == nil {
		hydrated = map[string]any{}
	}

	cfg := Empty()
	cfg.Raw = hydrated
	if list, ok := hydrated["model_list"].([]any); ok {
		for _, item := range list {
			if m := jsonx.AsMap(item); m != nil {
				cfg.ModelList = append(cfg.ModelList, m)
			}
		}
	}
	if m := jsonx.AsMap(hydrated["litellm_settings"]); m != nil {
		cfg.LiteLLMSettings = m
	}
	if m := jsonx.AsMap(hydrated["router_settings"]); m != nil {
		cfg.RouterSettings = m
	}
	if m := jsonx.AsMap(hydrated["general_settings"]); m != nil {
		cfg.GeneralSettings = m
	}
	if m := jsonx.AsMap(hydrated["front_proxy"]); m != nil {
		cfg.FrontProxy = m
	}
	return cfg, nil
}

// DropParams reports litellm_settings.drop_params.
func (c *Config) DropParams() bool {
	if c == nil {
		return false
	}
	c.mu.RLock()
	defer c.mu.RUnlock()
	return jsonx.Bool(c.LiteLLMSettings, "drop_params")
}

// Setting returns a litellm_settings value.
func (c *Config) Setting(key string) any {
	if c == nil {
		return nil
	}
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.LiteLLMSettings[key]
}

// RouterSetting returns a router_settings value.
func (c *Config) RouterSetting(key string) any {
	if c == nil {
		return nil
	}
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.RouterSettings[key]
}

// FrontProxyMode is "standard" or "passthrough" (default).
func (c *Config) FrontProxyMode() string {
	if c == nil {
		return "passthrough"
	}
	c.mu.RLock()
	defer c.mu.RUnlock()
	if jsonx.Str(c.FrontProxy, "mode") == "standard" {
		return "standard"
	}
	return "passthrough"
}

// SnapshotModelList returns a copy of the model_list.
func (c *Config) SnapshotModelList() []map[string]any {
	if c == nil {
		return nil
	}
	c.mu.RLock()
	defer c.mu.RUnlock()
	out := make([]map[string]any, len(c.ModelList))
	copy(out, c.ModelList)
	return out
}

const envPrefix = "os.environ/"

// Resolve hydrates a single value. "os.environ/VAR" → getenv(VAR).
func Resolve(v any) any {
	s, ok := v.(string)
	if !ok {
		return v
	}
	if strings.HasPrefix(s, envPrefix) {
		return os.Getenv(strings.TrimPrefix(s, envPrefix))
	}
	return s
}

// ResolveDeep walks maps/lists and resolves every string leaf.
func ResolveDeep(v any) any {
	switch t := v.(type) {
	case map[string]any:
		out := make(map[string]any, len(t))
		for k, val := range t {
			out[k] = ResolveDeep(val)
		}
		return out
	case []any:
		out := make([]any, len(t))
		for i, val := range t {
			out[i] = ResolveDeep(val)
		}
		return out
	default:
		return Resolve(v)
	}
}

func applyEnvironmentVariables(vars map[string]any) {
	if vars == nil {
		return
	}
	for k, v := range vars {
		s, ok := v.(string)
		if !ok {
			continue
		}
		if os.Getenv(k) == "" {
			if resolved, ok := Resolve(s).(string); ok {
				_ = os.Setenv(k, resolved)
			}
		}
	}
}
