package gateway

import (
	"net/http"
	"os"
	"strconv"

	"github.com/noizu-labs/go-litellm/internal/errx"
	"github.com/noizu-labs/go-litellm/internal/jsonx"
	"github.com/noizu-labs/go-litellm/internal/keys"
	"github.com/noizu-labs/go-litellm/internal/router"
)

func (a *App) keysList(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, 200, map[string]any{
		"keys":     a.Router.Keys.List(),
		"bindings": a.Router.Bindings(),
	})
}

func (a *App) keysPut(w http.ResponseWriter, r *http.Request) {
	body := a.jsonBody(r)
	name := jsonx.Str(body, "name")
	if name == "" {
		writeErr(w, errx.New(400, "name is required", errx.WithType("invalid_request_error")))
		return
	}
	env := jsonx.Str(body, "env")
	if env == "" {
		env = jsonx.Str(body, "from_env")
	}
	value := jsonx.Str(body, "api_key")
	if value == "" {
		value = jsonx.Str(body, "value")
	}
	if value == "" && env != "" {
		value = os.Getenv(env)
	}
	source := "api"
	if env != "" {
		source = "env"
	}
	if value == "" && env == "" {
		writeErr(w, errx.New(400, "api_key or env is required", errx.WithType("invalid_request_error")))
		return
	}
	if env != "" && value == "" {
		writeErr(w, errx.New(400, "env "+env+" is empty", errx.WithType("invalid_request_error")))
		return
	}
	stored := a.Router.Keys.Put(name, value, env, source)
	writeJSON(w, 200, map[string]any{
		"message": "key " + stored.Name + " stored",
		"key":     stored.PublicView(),
	})
}

func (a *App) keysDelete(w http.ResponseWriter, r *http.Request) {
	body := a.jsonBody(r)
	name := jsonx.Str(body, "name")
	if name == "" {
		writeErr(w, errx.New(400, "name is required", errx.WithType("invalid_request_error")))
		return
	}
	if !a.Router.Keys.Delete(name) {
		writeErr(w, errx.New(404, "key "+keys.Canonical(name)+" not found", errx.WithType("not_found_error")))
		return
	}
	writeJSON(w, 200, map[string]any{"message": "key " + keys.Canonical(name) + " deleted"})
}

func (a *App) keysSwitch(w http.ResponseWriter, r *http.Request) {
	body := a.jsonBody(r)
	keyName := jsonx.Str(body, "key")
	if keyName == "" {
		keyName = jsonx.Str(body, "name")
	}
	if keyName == "" {
		writeErr(w, errx.New(400, "key is required", errx.WithType("invalid_request_error")))
		return
	}
	if a.Router.Keys.Value(keyName) == "" {
		writeErr(w, errx.New(400, "named key "+keys.Canonical(keyName)+" is not configured", errx.WithType("invalid_request_error")))
		return
	}
	spec := router.BindSpec{
		Target: jsonx.Str(body, "target"),
		Prefix: jsonx.Str(body, "prefix"),
		Using:  jsonx.Str(body, "using"),
	}
	if spec.Target == "" {
		spec.Target = jsonx.Str(body, "model")
	}
	if spec.Target == "" && spec.Prefix == "" && spec.Using == "" {
		writeErr(w, errx.New(400, "target, prefix, or using is required", errx.WithType("invalid_request_error")))
		return
	}
	updated := a.Router.BindKey(spec, keyName)
	if updated == nil {
		updated = []string{}
	}
	writeJSON(w, 200, map[string]any{
		"message": "bound " + keys.Canonical(keyName) + " to " + strconv.Itoa(len(updated)) + " model(s)",
		"key":     keys.Canonical(keyName),
		"updated": updated,
	})
}
