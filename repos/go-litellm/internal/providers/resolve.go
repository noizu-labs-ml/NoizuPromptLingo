package providers

import (
	"strings"

	"github.com/noizu-labs/go-litellm/internal/errx"
	"github.com/noizu-labs/go-litellm/internal/jsonx"
)

var registry = map[string]Adapter{
	"openai":            OpenAI,
	"anthropic":         Anthropic,
	"groq":              Groq,
	"cerebras":          Cerebras,
	"deepseek":          DeepSeek,
	"xai":               XAI,
	"mistral":           Mistral,
	"perplexity":        Perplexity,
	"ollama":            Ollama,
	"openai_compatible": OpenAI,
}

// Resolved is a classified model → adapter binding.
type Resolved struct {
	Provider string
	Model    string
	Adapter  Adapter
}

// Resolve classifies a model string (+ optional deployment litellm_params).
func Resolve(model string, lp map[string]any) (*Resolved, *errx.Error) {
	provider, bare := classify(model, lp)
	ad, ok := registry[provider]
	if !ok {
		return nil, errx.New(400, "unknown provider: "+provider, errx.WithType("invalid_request_error"))
	}
	return &Resolved{Provider: provider, Model: bare, Adapter: ad}, nil
}

func classify(model string, lp map[string]any) (provider, bare string) {
	if p := prefixProvider(model); p != "" {
		return p, stripPrefix(model)
	}
	if p := endpointProvider(lp); p != "" {
		return p, model
	}
	if p := patternProvider(model); p != "" {
		return p, model
	}
	return "openai_compatible", model
}

func prefixProvider(model string) string {
	head, _, ok := strings.Cut(model, "/")
	if !ok {
		return ""
	}
	if _, ok := registry[head]; ok && head != "openai_compatible" {
		return head
	}
	return ""
}

func stripPrefix(model string) string {
	_, rest, ok := strings.Cut(model, "/")
	if !ok {
		return model
	}
	return rest
}

func endpointProvider(lp map[string]any) string {
	base := jsonx.Str(lp, "api_base")
	switch {
	case strings.Contains(base, "api.groq.com"):
		return "groq"
	case strings.Contains(base, "api.cerebras.ai"):
		return "cerebras"
	case strings.Contains(base, "api.deepseek.com"):
		return "deepseek"
	case strings.Contains(base, "api.x.ai"):
		return "xai"
	case strings.Contains(base, "api.mistral.ai"):
		return "mistral"
	case strings.Contains(base, "api.perplexity.ai"):
		return "perplexity"
	case strings.Contains(base, "api.anthropic.com"):
		return "anthropic"
	case strings.Contains(base, "api.openai.com"):
		return "openai"
	default:
		return ""
	}
}

func patternProvider(model string) string {
	switch {
	case strings.HasPrefix(model, "claude-"):
		return "anthropic"
	case strings.HasPrefix(model, "gpt-"),
		strings.HasPrefix(model, "o1"),
		strings.HasPrefix(model, "o3"),
		strings.HasPrefix(model, "chatgpt"),
		strings.HasPrefix(model, "text-embedding-"):
		return "openai"
	case strings.HasPrefix(model, "deepseek-"):
		return "deepseek"
	case strings.HasPrefix(model, "grok-"):
		return "xai"
	case strings.HasPrefix(model, "mistral-"):
		return "mistral"
	default:
		return ""
	}
}
