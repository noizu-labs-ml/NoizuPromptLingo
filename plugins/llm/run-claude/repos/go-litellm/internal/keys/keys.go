// Package keys is the live named-credential registry for go-litellm.
//
// Deployments bind to a key by litellm_params.api_key_name. Request paths
// resolve that name to a secret at call time so run-claude can swap which
// subscription a model family uses without re-registering the model.
package keys

import (
	"os"
	"strings"
	"sync"

	"github.com/noizu-labs/go-litellm/internal/config"
	"github.com/noizu-labs/go-litellm/internal/jsonx"
)

// CanonicalEnvNames maps well-known env vars to short key names.
var CanonicalEnvNames = map[string]string{
	"ZAI_SUB_KEY":       "zai",
	"ZAI_SUB_KEY_TYNA":  "tyna",
	"CEREBRAS_SUB_KEY":  "cerebras",
	"QWEN_SUB_KEY":      "qwen",
	"ANTHROPIC_API_KEY": "anthropic",
}

var aliases = map[string]string{
	"zai-tyna":    "tyna",
	"default":     "zai",
	"zai-default": "zai",
}

// Entry is one named credential.
type Entry struct {
	Name   string
	Env    string
	Value  string
	Source string // env, api
}

// Public is the redacted view returned by the HTTP API.
type Public struct {
	Name       string `json:"name"`
	Env        string `json:"env,omitempty"`
	Source     string `json:"source"`
	Configured bool   `json:"configured"`
	Preview    string `json:"preview,omitempty"`
}

// Store holds named keys.
type Store struct {
	mu      sync.RWMutex
	entries map[string]*Entry
}

// New returns an empty store.
func New() *Store {
	return &Store{entries: map[string]*Entry{}}
}

// SeedFromEnv registers builtin + *_SUB_KEY* env vars.
func (s *Store) SeedFromEnv() {
	if s == nil {
		return
	}
	for env, name := range CanonicalEnvNames {
		s.Put(name, os.Getenv(env), env, "env")
	}
	for _, raw := range os.Environ() {
		k, v, ok := strings.Cut(raw, "=")
		if !ok {
			continue
		}
		if _, known := CanonicalEnvNames[k]; known {
			continue
		}
		name, ok := NameFromEnv(k)
		if !ok {
			continue
		}
		if s.Get(name) != nil {
			continue
		}
		s.Put(name, v, k, "env")
	}
}

// Canonical folds aliases (tyna ← zai-tyna).
func Canonical(name string) string {
	n := strings.ToLower(strings.TrimSpace(name))
	if a, ok := aliases[n]; ok {
		return a
	}
	return n
}

// NameFromEnv derives a short key name from an environment variable.
func NameFromEnv(env string) (string, bool) {
	if env == "" {
		return "", false
	}
	if n, ok := CanonicalEnvNames[env]; ok {
		return n, true
	}
	if rest, ok := strings.CutSuffix(env, "_SUB_KEY"); ok && rest != "" {
		return strings.ToLower(rest), true
	}
	const mid = "_SUB_KEY_"
	if i := strings.Index(env, mid); i >= 0 {
		suffix := env[i+len(mid):]
		if suffix != "" {
			return strings.ToLower(suffix), true
		}
	}
	return "", false
}

// Matches reports whether modelName is selected by target.
// "zai" matches "zai/haiku" and "zai/opus[1m]" but not "zai-tyna/haiku".
func Matches(modelName, target string) bool {
	if target == "" || modelName == "" {
		return false
	}
	if modelName == target {
		return true
	}
	if strings.HasSuffix(target, "/") {
		return strings.HasPrefix(modelName, target)
	}
	return strings.HasPrefix(modelName, target+"/")
}

// Put registers or replaces a named key. Empty values are kept so builtins
// still appear in listings when the env var is unset.
func (s *Store) Put(name, value, env, source string) *Entry {
	if s == nil {
		return nil
	}
	name = Canonical(name)
	if name == "" {
		return nil
	}
	if source == "" {
		source = "api"
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.entries == nil {
		s.entries = map[string]*Entry{}
	}
	e := &Entry{Name: name, Env: env, Value: value, Source: source}
	s.entries[name] = e
	return e
}

// Delete removes a named key.
func (s *Store) Delete(name string) bool {
	if s == nil {
		return false
	}
	name = Canonical(name)
	s.mu.Lock()
	defer s.mu.Unlock()
	if _, ok := s.entries[name]; !ok {
		return false
	}
	delete(s.entries, name)
	return true
}

// Get returns a copy of an entry, or nil.
func (s *Store) Get(name string) *Entry {
	if s == nil {
		return nil
	}
	name = Canonical(name)
	s.mu.RLock()
	defer s.mu.RUnlock()
	e := s.entries[name]
	if e == nil {
		return nil
	}
	cp := *e
	return &cp
}

// Value returns the secret for name, re-reading env when the stored value is empty.
func (s *Store) Value(name string) string {
	e := s.Get(name)
	if e == nil {
		return ""
	}
	if e.Value != "" {
		return e.Value
	}
	if e.Env != "" {
		return os.Getenv(e.Env)
	}
	return ""
}

// PublicView is the redacted form of this entry.
func (e *Entry) PublicView() Public {
	if e == nil {
		return Public{}
	}
	val := e.Value
	if val == "" && e.Env != "" {
		val = os.Getenv(e.Env)
	}
	return Public{
		Name:       e.Name,
		Env:        e.Env,
		Source:     e.Source,
		Configured: val != "",
		Preview:    preview(val),
	}
}

// List returns redacted entries, sorted by name.
func (s *Store) List() []Public {
	if s == nil {
		return nil
	}
	s.mu.RLock()
	defer s.mu.RUnlock()
	out := make([]Public, 0, len(s.entries))
	for _, e := range s.entries {
		cp := *e
		out = append(out, cp.PublicView())
	}
	// insertion order is random; sort for stable API
	for i := 0; i < len(out); i++ {
		for j := i + 1; j < len(out); j++ {
			if out[j].Name < out[i].Name {
				out[i], out[j] = out[j], out[i]
			}
		}
	}
	return out
}

// Resolve picks the effective api_key for a deployment's litellm_params.
func (s *Store) Resolve(lp map[string]any) string {
	if lp == nil {
		return ""
	}
	if name := jsonx.Str(lp, "api_key_name"); name != "" {
		if v := s.Value(name); v != "" {
			return v
		}
	}
	if k := jsonx.Str(lp, "api_key"); k != "" {
		if resolved, ok := config.Resolve(k).(string); ok {
			return resolved
		}
	}
	return ""
}

// InferName stamps api_key_name when the caller omitted it.
func (s *Store) InferName(lp map[string]any) {
	if lp == nil || jsonx.Str(lp, "api_key_name") != "" {
		return
	}
	ak := jsonx.Str(lp, "api_key")
	if strings.HasPrefix(ak, configEnvPrefix) {
		env := strings.TrimPrefix(ak, configEnvPrefix)
		if n, ok := NameFromEnv(env); ok {
			lp["api_key_name"] = n
		}
		return
	}
	if n := s.nameForValue(ak); n != "" {
		lp["api_key_name"] = n
	}
}

const configEnvPrefix = "os.environ/"

func (s *Store) nameForValue(value string) string {
	if value == "" || s == nil {
		return ""
	}
	s.mu.RLock()
	defer s.mu.RUnlock()
	for _, e := range s.entries {
		v := e.Value
		if v == "" && e.Env != "" {
			v = os.Getenv(e.Env)
		}
		if v != "" && v == value {
			return e.Name
		}
	}
	return ""
}

func preview(s string) string {
	if s == "" {
		return ""
	}
	if len(s) <= 4 {
		return "****"
	}
	return "…" + s[len(s)-4:]
}
