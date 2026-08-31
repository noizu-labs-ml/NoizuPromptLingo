package core

import (
	"github.com/noizu-labs/go-litellm/internal/config"
	"github.com/noizu-labs/go-litellm/internal/errx"
	"github.com/noizu-labs/go-litellm/internal/jsonx"
	"github.com/noizu-labs/go-litellm/internal/providers"
	"github.com/noizu-labs/go-litellm/internal/router"
)

var structural = map[string]bool{"model": true, "messages": true, "input": true}

// Prepared is a resolved adapter + request ready to execute or stream.
type Prepared struct {
	Adapter providers.Adapter
	Req     *providers.Request
}

// Optional maps tunables through the adapter allowlist (drop_params).
func Optional(params map[string]any, ad providers.Adapter, model string, drop bool) map[string]any {
	structurals := map[string]any{}
	tunable := map[string]any{}
	for k, v := range params {
		if structural[k] {
			structurals[k] = v
		} else {
			tunable[k] = v
		}
	}
	mapped := ad.MapOpenAIParams(tunable, map[string]any{}, model, drop)
	out := jsonx.Clone(structurals)
	for k, v := range mapped {
		out[k] = v
	}
	return out
}

func messagesOf(params map[string]any) []any {
	if m, ok := params["messages"].([]any); ok {
		return m
	}
	return []any{}
}

var deploymentTunables = []string{"reasoning_effort", "include_reasoning", "temperature", "max_tokens", "max_completion_tokens"}

func applyDeploymentTunables(params, lp map[string]any) map[string]any {
	out := jsonx.Clone(params)
	if lp == nil {
		return out
	}
	for _, k := range deploymentTunables {
		if v, ok := lp[k]; ok && v != nil {
			out[k] = v
		}
	}
	switch drop := lp["additional_drop_params"].(type) {
	case []any:
		for _, d := range drop {
			if s, ok := d.(string); ok {
				delete(out, s)
			}
		}
	case []string:
		for _, s := range drop {
			delete(out, s)
		}
	}
	return out
}

func deploymentParams(dep map[string]any, requested string) map[string]any {
	if dep == nil {
		return map[string]any{"model": requested}
	}
	if lp := jsonx.Nested(dep, "litellm_params"); lp != nil {
		return lp
	}
	return map[string]any{"model": requested}
}

// Prepare resolves provider + adapter for a chat body without executing.
func Prepare(rt *router.Router, cfg *config.Config, params map[string]any) (*Prepared, *errx.Error) {
	requested := jsonx.Str(params, "model")
	if requested == "" {
		return nil, errx.New(400, "missing required field: model", errx.WithType("invalid_request_error"))
	}
	var dep map[string]any
	if rt != nil {
		dep = rt.Lookup(requested)
	}
	lp := deploymentParams(dep, requested)
	underlying := jsonx.Str(lp, "model")
	if underlying == "" {
		underlying = requested
	}
	res, e := providers.Resolve(underlying, lp)
	if e != nil {
		return nil, e
	}
	drop := false
	if cfg != nil {
		drop = cfg.DropParams()
	}
	if b, ok := lp["drop_params"].(bool); ok && b {
		drop = true
	}
	mapped := Optional(params, res.Adapter, res.Model, drop)
	mapped = applyDeploymentTunables(mapped, lp)
	if res.Provider == "groq" {
		mapped = providers.ShapeGroq(mapped, res.Model)
	}
	mapped["model"] = res.Model
	req := &providers.Request{
		Model:         res.Model,
		Provider:      res.Provider,
		Messages:      messagesOf(params),
		Params:        mapped,
		LiteLLMParams: lp,
		Stream:        jsonx.Bool(params, "stream"),
		CallType:      "chat",
	}
	return &Prepared{Adapter: res.Adapter, Req: req}, nil
}

// Completion runs a non-streaming chat completion.
func Completion(client HTTPDoer, rt *router.Router, cfg *config.Config, params map[string]any) (*providers.ModelResponse, *errx.Error) {
	p, e := Prepare(rt, cfg, params)
	if e != nil {
		return nil, e
	}
	return DoCompletion(client, p)
}

// Embeddings runs an embedding request and returns the provider body as-is.
func Embeddings(client HTTPDoer, rt *router.Router, cfg *config.Config, params map[string]any) (map[string]any, *errx.Error) {
	requested := jsonx.Str(params, "model")
	if requested == "" || params["input"] == nil {
		return nil, errx.New(400, "missing required field: model or input", errx.WithType("invalid_request_error"))
	}
	var dep map[string]any
	if rt != nil {
		dep = rt.Lookup(requested)
	}
	lp := deploymentParams(dep, requested)
	underlying := jsonx.Str(lp, "model")
	if underlying == "" {
		underlying = requested
	}
	res, e := providers.Resolve(underlying, lp)
	if e != nil {
		return nil, e
	}
	_ = cfg
	req := &providers.Request{
		Model:         res.Model,
		Provider:      res.Provider,
		Params:        jsonx.Clone(params),
		LiteLLMParams: lp,
		CallType:      "embedding",
	}
	req.Params["model"] = res.Model
	return DoRaw(client, res.Adapter, req)
}
