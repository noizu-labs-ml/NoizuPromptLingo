// Package frontproxy is the runtime-alterable routing table folded into the gateway.
package frontproxy

import (
	"strconv"
	"strings"
	"sync"

	"github.com/noizu-labs/go-litellm/internal/jsonx"
	"github.com/noizu-labs/go-litellm/internal/router"
	"github.com/noizu-labs/go-litellm/internal/runtime"
)

const AnthropicAPI = "https://api.anthropic.com"

var openaiPaths = []string{
	"/v1/chat/completions",
	"/v1/completions",
	"/v1/embeddings",
	"/v1/images",
	"/v1/audio",
	"/v1/responses",
}

// Match kinds.
const (
	MatchAny              = "any"
	MatchPathIn           = "path_in"
	MatchMessagesModel    = "messages_model"
	MatchMessagesNotModel = "messages_not_model"
)

// Target kinds.
const (
	TargetLiteLLM   = "litellm"
	TargetAnthropic = "anthropic"
	TargetURL       = "url"
)

// Auth modes.
const (
	AuthMasterKey   = "master_key"
	AuthPassthrough = "passthrough"
)

// Rule is one front-proxy routing rule.
type Rule struct {
	MatchType  string   `json:"-"`
	Paths      []string `json:"-"`
	Prefix     string   `json:"-"`
	TargetType string   `json:"-"`
	TargetURL  string   `json:"-"`
	Auth       string   `json:"-"`
}

// Encode serializes a rule to the admin JSON shape.
func (r Rule) Encode() map[string]any {
	match := map[string]any{"type": r.MatchType}
	switch r.MatchType {
	case MatchPathIn:
		match["paths"] = r.Paths
	case MatchMessagesModel, MatchMessagesNotModel:
		match["prefix"] = r.Prefix
	}
	target := map[string]any{"type": r.TargetType}
	if r.TargetType == TargetURL {
		target["url"] = r.TargetURL
	}
	return map[string]any{"match": match, "target": target, "auth": r.Auth}
}

// DecodeRule parses one admin JSON rule.
func DecodeRule(raw map[string]any) (Rule, error) {
	m := jsonx.AsMap(raw["match"])
	t := jsonx.AsMap(raw["target"])
	r := Rule{Auth: jsonx.Str(raw, "auth")}
	if m != nil {
		r.MatchType = jsonx.Str(m, "type")
		if p, ok := m["paths"].([]any); ok {
			for _, x := range p {
				if s, ok := x.(string); ok {
					r.Paths = append(r.Paths, s)
				}
			}
		}
		r.Prefix = jsonx.Str(m, "prefix")
	}
	if t != nil {
		r.TargetType = jsonx.Str(t, "type")
		r.TargetURL = jsonx.Str(t, "url")
	}
	return r, nil
}

// Rules is the live ordered rule list.
type Rules struct {
	mu    sync.RWMutex
	mode  string
	rules []Rule
	host  string
	port  int
}

// NewRules seeds from config front_proxy.mode (default passthrough).
func NewRules(mode string, settings runtime.Settings) *Rules {
	if mode != "standard" {
		mode = "passthrough"
	}
	r := &Rules{mode: mode, host: settings.Host, port: settings.Port}
	r.rules = DefaultRules(mode)
	return r
}

// DefaultRules is the seed set for a named mode.
func DefaultRules(mode string) []Rule {
	if mode == "standard" {
		return []Rule{{MatchType: MatchAny, TargetType: TargetLiteLLM, Auth: AuthMasterKey}}
	}
	return []Rule{
		{MatchType: MatchPathIn, Paths: openaiPaths, TargetType: TargetLiteLLM, Auth: AuthMasterKey},
		{MatchType: MatchMessagesNotModel, Prefix: "claude-", TargetType: TargetLiteLLM, Auth: AuthMasterKey},
		{MatchType: MatchMessagesModel, Prefix: "claude-", TargetType: TargetAnthropic, Auth: AuthPassthrough},
		{MatchType: MatchAny, TargetType: TargetAnthropic, Auth: AuthPassthrough},
	}
}

func (r *Rules) Mode() string {
	r.mu.RLock()
	defer r.mu.RUnlock()
	return r.mode
}

func (r *Rules) List() []Rule {
	r.mu.RLock()
	defer r.mu.RUnlock()
	out := make([]Rule, len(r.rules))
	copy(out, r.rules)
	return out
}

func (r *Rules) Put(rules []Rule) {
	r.mu.Lock()
	r.rules = rules
	r.mode = "custom"
	r.mu.Unlock()
}

func (r *Rules) SetMode(mode string) bool {
	if mode != "standard" && mode != "passthrough" {
		return false
	}
	r.mu.Lock()
	r.mode = mode
	r.rules = DefaultRules(mode)
	r.mu.Unlock()
	return true
}

// Decision is {target_base_url, auth_mode}.
type Decision struct {
	BaseURL string
	Auth    string
}

// Route walks the ordered rule list.
func (r *Rules) Route(path string, body map[string]any) Decision {
	for _, rule := range r.List() {
		if matches(rule, path, body) {
			return r.toTarget(rule)
		}
	}
	return Decision{BaseURL: AnthropicAPI, Auth: AuthPassthrough}
}

func matches(rule Rule, path string, body map[string]any) bool {
	switch rule.MatchType {
	case MatchPathIn:
		for _, p := range rule.Paths {
			if path == p || strings.HasPrefix(path, p+"/") {
				return true
			}
		}
		return false
	case MatchMessagesModel:
		return messagesPath(path) && strings.HasPrefix(ExtractModel(body), rule.Prefix)
	case MatchMessagesNotModel:
		return messagesPath(path) && !strings.HasPrefix(ExtractModel(body), rule.Prefix)
	case MatchAny:
		return true
	default:
		return false
	}
}

func messagesPath(path string) bool {
	return strings.HasPrefix(path, "/v1/messages") && !strings.HasSuffix(path, "/count_tokens")
}

func (r *Rules) toTarget(rule Rule) Decision {
	var base string
	switch rule.TargetType {
	case TargetLiteLLM:
		base = r.litellmURL()
	case TargetAnthropic:
		base = AnthropicAPI
	case TargetURL:
		base = rule.TargetURL
	default:
		base = AnthropicAPI
	}
	auth := rule.Auth
	if auth == "" {
		auth = AuthPassthrough
	}
	return Decision{BaseURL: base, Auth: auth}
}

func (r *Rules) litellmURL() string {
	host := r.host
	if host == "" {
		host = "127.0.0.1"
	}
	port := r.port
	if port == 0 {
		port = 4445
	}
	return "http://" + host + ":" + strconv.Itoa(port)
}

// ExtractModel returns body["model"] or "".
func ExtractModel(body map[string]any) string {
	return jsonx.Str(body, "model")
}

// Bootstrap is GET /api/claude_cli/bootstrap.
func Bootstrap(rt *router.Router) map[string]any {
	var options []any
	if rt != nil {
		seen := map[string]bool{}
		for _, d := range rt.Deployments() {
			name := jsonx.Str(d, "model_name")
			if name == "" || seen[name] {
				continue
			}
			seen[name] = true
			options = append(options, map[string]any{
				"model": name, "name": name, "description": "via go-litellm proxy",
			})
		}
	}
	var extra any
	if len(options) > 0 {
		extra = options
	}
	return map[string]any{
		"client_data":              nil,
		"additional_model_options": extra,
	}
}
