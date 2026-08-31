package gateway

import (
	"net/http"

	"github.com/noizu-labs/go-litellm/internal/core"
	"github.com/noizu-labs/go-litellm/internal/errx"
	"github.com/noizu-labs/go-litellm/internal/frontproxy"
	"github.com/noizu-labs/go-litellm/internal/jsonx"
)

func (a *App) chatCompletions(w http.ResponseWriter, r *http.Request) {
	params := a.jsonBody(r)
	a.tag(r, jsonx.Str(params, "model"), "", "")
	if jsonx.Bool(params, "stream") {
		p, e := core.Prepare(a.Router, a.Config, params)
		if e != nil {
			a.tag(r, "", "", e.Message)
			writeErr(w, e)
			return
		}
		a.tag(r, "", "native:"+p.Req.Provider, "")
		if e := core.StreamOpenAI(w, a.HTTP, p); e != nil {
			a.tag(r, "", "", e.Message)
			writeErr(w, e)
		}
		return
	}
	p, e := core.Prepare(a.Router, a.Config, params)
	if e != nil {
		a.tag(r, "", "", e.Message)
		writeErr(w, e)
		return
	}
	a.tag(r, "", "native:"+p.Req.Provider, "")
	resp, e := core.DoCompletion(a.HTTP, p)
	if e != nil {
		a.tag(r, "", "", e.Message)
		writeErr(w, e)
		return
	}
	writeJSON(w, 200, resp)
}

func (a *App) embeddings(w http.ResponseWriter, r *http.Request) {
	params := a.jsonBody(r)
	a.tag(r, jsonx.Str(params, "model"), "", "")
	resp, e := core.Embeddings(a.HTTP, a.Router, a.Config, params)
	if e != nil {
		a.tag(r, "", "", e.Message)
		writeErr(w, e)
		return
	}
	writeJSON(w, 200, resp)
}

func (a *App) listModels(w http.ResponseWriter, _ *http.Request) {
	var data []any
	for _, name := range a.Router.ModelNames() {
		data = append(data, map[string]any{
			"id": name, "object": "model", "created": 0, "owned_by": "go-litellm",
		})
	}
	if data == nil {
		data = []any{}
	}
	writeJSON(w, 200, map[string]any{"object": "list", "data": data})
}

func (a *App) modelNew(w http.ResponseWriter, r *http.Request) {
	body := a.jsonBody(r)
	name := jsonx.Str(body, "model_name")
	if name == "" {
		writeErr(w, errx.New(400, "model_name is required", errx.WithType("invalid_request_error")))
		return
	}
	if _, ok := body["litellm_params"]; !ok {
		body["litellm_params"] = map[string]any{}
	}
	if _, ok := body["model_info"]; !ok {
		body["model_info"] = map[string]any{}
	}
	stored := a.Router.Add(body)
	if lp := jsonx.Nested(stored, "litellm_params"); lp != nil && a.Router.Keys != nil {
		a.Router.Keys.InferName(lp)
	}
	writeJSON(w, 200, map[string]any{
		"message":  "Model " + name + " added successfully",
		"model_id": stored["model_id"],
	})
}

func (a *App) modelDelete(w http.ResponseWriter, r *http.Request) {
	body := a.jsonBody(r)
	id := jsonx.Str(body, "id")
	if id == "" {
		id = jsonx.Str(body, "model_id")
	}
	if id == "" {
		writeErr(w, errx.New(400, "id is required", errx.WithType("invalid_request_error")))
		return
	}
	if a.Router.Delete(id) {
		writeJSON(w, 200, map[string]any{"message": "Model " + id + " deleted successfully"})
		return
	}
	writeErr(w, errx.New(404, "model "+id+" not found", errx.WithType("not_found_error")))
}

func (a *App) modelUpdate(w http.ResponseWriter, r *http.Request) {
	body := a.jsonBody(r)
	id := jsonx.Str(body, "id")
	if id == "" {
		id = jsonx.Str(body, "model_id")
	}
	if id == "" {
		writeErr(w, errx.New(400, "id is required", errx.WithType("invalid_request_error")))
		return
	}
	changes := jsonx.Clone(body)
	delete(changes, "id")
	delete(changes, "model_id")
	updated, ok := a.Router.Update(id, changes)
	if !ok {
		writeErr(w, errx.New(404, "model "+id+" not found", errx.WithType("not_found_error")))
		return
	}
	writeJSON(w, 200, map[string]any{"message": "Model " + id + " updated", "model_id": updated["model_id"]})
}

func (a *App) modelInfo(w http.ResponseWriter, _ *http.Request) {
	var data []any
	for _, d := range a.Router.Deployments() {
		data = append(data, redact(d))
	}
	if data == nil {
		data = []any{}
	}
	writeJSON(w, 200, map[string]any{"data": data})
}

func redact(d map[string]any) map[string]any {
	out := jsonx.Clone(d)
	lp := jsonx.Nested(out, "litellm_params")
	if lp == nil {
		return out
	}
	lp = jsonx.Clone(lp)
	for _, k := range []string{"api_key", "aws_secret_access_key", "vertex_credentials"} {
		if _, ok := lp[k]; ok {
			lp[k] = "****"
		}
	}
	out["litellm_params"] = lp
	return out
}

func (a *App) getRules(w http.ResponseWriter, _ *http.Request) {
	var rules []any
	for _, r := range a.Rules.List() {
		rules = append(rules, r.Encode())
	}
	writeJSON(w, 200, map[string]any{"mode": a.Rules.Mode(), "rules": rules})
}

func (a *App) putRules(w http.ResponseWriter, r *http.Request) {
	body := a.jsonBody(r)
	raw, ok := body["rules"].([]any)
	if !ok {
		writeJSON(w, 400, map[string]any{"error": map[string]any{"message": "invalid rules: missing_rules_key"}})
		return
	}
	var rules []frontproxy.Rule
	for _, item := range raw {
		m := jsonx.AsMap(item)
		if m == nil {
			writeJSON(w, 400, map[string]any{"error": map[string]any{"message": "invalid rules: bad item"}})
			return
		}
		rule, err := frontproxy.DecodeRule(m)
		if err != nil {
			writeJSON(w, 400, map[string]any{"error": map[string]any{"message": "invalid rules: " + err.Error()}})
			return
		}
		rules = append(rules, rule)
	}
	a.Rules.Put(rules)
	writeJSON(w, 200, map[string]any{"status": "ok", "count": len(rules)})
}

func (a *App) putMode(w http.ResponseWriter, r *http.Request) {
	mode := jsonx.Str(a.jsonBody(r), "mode")
	if !a.Rules.SetMode(mode) {
		writeJSON(w, 400, map[string]any{"error": map[string]any{"message": "mode must be 'standard' or 'passthrough'"}})
		return
	}
	writeJSON(w, 200, map[string]any{"status": "ok", "mode": mode})
}
