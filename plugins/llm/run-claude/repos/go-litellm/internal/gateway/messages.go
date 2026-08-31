package gateway

import (
	"encoding/json"
	"net/http"
	"strings"

	"github.com/noizu-labs/go-litellm/internal/anthropic"
	"github.com/noizu-labs/go-litellm/internal/core"
	"github.com/noizu-labs/go-litellm/internal/errx"
	"github.com/noizu-labs/go-litellm/internal/frontproxy"
	"github.com/noizu-labs/go-litellm/internal/jsonx"
	"github.com/noizu-labs/go-litellm/internal/providers"
)

func (a *App) messages(w http.ResponseWriter, r *http.Request) {
	body := a.jsonBody(r)
	model := frontproxy.ExtractModel(body)
	a.tag(r, model, "", "")

	if strings.HasPrefix(model, "claude-") {
		a.tag(r, "", frontproxy.AnthropicAPI, "")
		a.forward(w, r, frontproxy.AnthropicAPI+r.URL.RequestURI(), a.forwardHeaders(r, frontproxy.AuthPassthrough), a.rawBody(r))
		return
	}

	if dep := a.Router.Lookup(model); dep != nil {
		a.messagesViaDeployment(w, r, body, dep)
		return
	}

	writeJSON(w, http.StatusNotFound, errx.New(404, "model not found: "+model, errx.WithType("not_found_error")).AnthropicBody())
}

func (a *App) messagesViaDeployment(w http.ResponseWriter, r *http.Request, body, dep map[string]any) {
	lp := jsonx.Nested(dep, "litellm_params")
	if lp == nil {
		lp = map[string]any{}
	}
	upstream := jsonx.Str(lp, "model")
	res, e := providers.Resolve(upstream, lp)
	if e != nil || res.Provider != "anthropic" {
		a.openaiFamilyTranslate(w, r, body)
		return
	}
	req := &providers.Request{
		Model:         res.Model,
		Provider:      "anthropic",
		LiteLLMParams: lp,
		CallType:      "chat",
	}
	headers, e := res.Adapter.ValidateEnvironment(req, map[string]string{})
	if e != nil {
		writeJSON(w, e.Status, e.AnthropicBody())
		return
	}
	url := res.Adapter.CompleteURL(req)
	out := jsonx.Clone(body)
	out["model"] = res.Model
	raw, _ := json.Marshal(out)
	a.tag(r, "", url, "")
	a.forwardTo(w, r, url, headers, raw)
}

func (a *App) openaiFamilyTranslate(w http.ResponseWriter, r *http.Request, body map[string]any) {
	openaiBody := anthropic.RequestToOpenAI(body)
	if jsonx.Bool(body, "stream") {
		p, e := core.Prepare(a.Router, a.Config, openaiBody)
		if e != nil {
			writeJSON(w, e.Status, e.AnthropicBody())
			return
		}
		a.tag(r, "", "native:"+p.Req.Provider, "")
		if e := core.StreamAnthropic(w, a.HTTP, p, jsonx.Str(body, "model")); e != nil {
			writeJSON(w, e.Status, e.AnthropicBody())
		}
		return
	}
	resp, e := core.Completion(a.HTTP, a.Router, a.Config, openaiBody)
	if e != nil {
		writeJSON(w, e.Status, e.AnthropicBody())
		return
	}
	writeJSON(w, 200, anthropic.ResponseFromModelResponse(resp, jsonx.Str(body, "model")))
}
