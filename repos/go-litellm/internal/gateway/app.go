package gateway

import (
	"bytes"
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/base64"
	"encoding/json"
	"io"
	"log"
	"net"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/noizu-labs/go-litellm/internal/config"
	"github.com/noizu-labs/go-litellm/internal/core"
	"github.com/noizu-labs/go-litellm/internal/errx"
	"github.com/noizu-labs/go-litellm/internal/frontproxy"
	"github.com/noizu-labs/go-litellm/internal/jsonx"
	"github.com/noizu-labs/go-litellm/internal/router"
	"github.com/noizu-labs/go-litellm/internal/runtime"
	"github.com/noizu-labs/go-litellm/internal/store"
	"github.com/noizu-labs/go-litellm/internal/version"
)

const maxBody = 64 << 20

type ctxKey struct{}

type reqCtx struct {
	Start   time.Time
	RawBody []byte
	JSON    map[string]any
	Model   string
	Target  string
	Error   string
	RespN   int64
	Logged  bool
}

// App is the unified gateway (LiteLLM surface + front-proxy routing).
type App struct {
	Settings runtime.Settings
	Config   *config.Config
	Router   *router.Router
	Rules    *frontproxy.Rules
	Store    *store.Store
	HTTP     core.HTTPDoer
	Started  time.Time
}

// New constructs the gateway from resolved settings + loaded config.
func New(settings runtime.Settings, cfg *config.Config) *App {
	if cfg == nil {
		cfg = config.Empty()
	}
	return &App{
		Settings: settings,
		Config:   cfg,
		Router:   router.New(cfg),
		Rules:    frontproxy.NewRules(cfg.FrontProxyMode(), settings),
		Store:    store.MustOpen(settings.DatabaseURL),
		HTTP:     core.DefaultClient,
		Started:  time.Now(),
	}
}

// ListenAndServe binds the unified gateway.
func (a *App) ListenAndServe() error {
	addr := net.JoinHostPort(a.Settings.Host, strconv.Itoa(a.Settings.Port))
	srv := &http.Server{
		Addr:              addr,
		Handler:           a.Handler(),
		ReadHeaderTimeout: 30 * time.Second,
		IdleTimeout:       120 * time.Second,
	}
	log.Printf("[go-litellm] gateway listening on %s", addr)
	return srv.ListenAndServe()
}

// Handler wraps metrics + dispatch.
func (a *App) Handler() http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		rc := &reqCtx{Start: time.Now()}
		r = r.WithContext(context.WithValue(r.Context(), ctxKey{}, rc))
		if r.Body != nil && r.ContentLength != 0 {
			body, err := io.ReadAll(io.LimitReader(r.Body, maxBody))
			_ = r.Body.Close()
			if err == nil {
				rc.RawBody = body
				r.Body = io.NopCloser(bytes.NewReader(body))
				ct := r.Header.Get("Content-Type")
				if strings.Contains(ct, "json") || len(body) > 0 && body[0] == '{' {
					var m map[string]any
					if json.Unmarshal(body, &m) == nil {
						rc.JSON = m
						if s := jsonx.Str(m, "model"); s != "" {
							rc.Model = s
						}
					}
				}
			}
		}
		ww := &countingWriter{ResponseWriter: w, status: 200}
		a.ServeHTTP(ww, r)
		a.logRequest(r, ww, rc)
	})
}

func (a *App) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	p := r.URL.Path
	switch {
	case r.Method == http.MethodGet && p == "/":
		w.WriteHeader(200)
		_, _ = io.WriteString(w, "LiteLLM: RUNNING")
	case r.Method == http.MethodGet && p == "/health":
		a.health(w)
	case r.Method == http.MethodGet && p == "/health/readiness":
		a.readiness(w)
	case r.Method == http.MethodGet && (p == "/health/liveliness" || p == "/health/liveness"):
		writeJSON(w, 200, map[string]any{"status": "alive"})
	case r.Method == http.MethodGet && p == "/api/claude_cli/bootstrap":
		writeJSON(w, 200, frontproxy.Bootstrap(a.Router))

	case r.Method == http.MethodPost && (p == "/v1/chat/completions" || p == "/chat/completions"):
		a.authed(w, r, a.chatCompletions)
	case r.Method == http.MethodPost && (p == "/v1/embeddings" || p == "/embeddings"):
		a.authed(w, r, a.embeddings)
	case r.Method == http.MethodGet && (p == "/v1/models" || p == "/models"):
		a.authed(w, r, a.listModels)

	case r.Method == http.MethodPost && p == "/model/new":
		a.authed(w, r, a.modelNew)
	case r.Method == http.MethodPost && p == "/model/delete":
		a.authed(w, r, a.modelDelete)
	case r.Method == http.MethodPost && p == "/model/update":
		a.authed(w, r, a.modelUpdate)
	case r.Method == http.MethodGet && (p == "/model/info" || p == "/v1/model/info"):
		a.authed(w, r, a.modelInfo)

	case r.Method == http.MethodGet && (p == "/keys" || p == "/v1/keys"):
		a.authed(w, r, a.keysList)
	case r.Method == http.MethodPost && (p == "/keys" || p == "/v1/keys"):
		a.authed(w, r, a.keysPut)
	case r.Method == http.MethodPost && (p == "/keys/delete" || p == "/v1/keys/delete"):
		a.authed(w, r, a.keysDelete)
	case r.Method == http.MethodPost && (p == "/keys/switch" || p == "/v1/keys/switch"):
		a.authed(w, r, a.keysSwitch)

	case r.Method == http.MethodGet && p == "/front/rules":
		a.gated(w, r, a.getRules)
	case r.Method == http.MethodPut && p == "/front/rules":
		a.gated(w, r, a.putRules)
	case r.Method == http.MethodPut && p == "/front/mode":
		a.gated(w, r, a.putMode)
	case r.Method == http.MethodGet && p == "/status.json":
		a.gated(w, r, a.statusJSON)
	case r.Method == http.MethodGet && p == "/status":
		a.browserGated(w, r, a.statusHTML)
	case r.Method == http.MethodGet && p == "/status/requests":
		a.browserGated(w, r, a.statusRequests)

	case r.Method == http.MethodPost && p == "/v1/messages":
		a.messages(w, r)
	default:
		a.passthrough(w, r)
	}
}

func getRC(r *http.Request) *reqCtx {
	if v, ok := r.Context().Value(ctxKey{}).(*reqCtx); ok {
		return v
	}
	return &reqCtx{}
}

func (a *App) jsonBody(r *http.Request) map[string]any {
	if rc := getRC(r); rc.JSON != nil {
		return rc.JSON
	}
	return map[string]any{}
}

func (a *App) rawBody(r *http.Request) []byte {
	if rc := getRC(r); rc.RawBody != nil {
		return rc.RawBody
	}
	return nil
}

func (a *App) tag(r *http.Request, model, target, errMsg string) {
	rc := getRC(r)
	if model != "" {
		rc.Model = model
	}
	if target != "" {
		rc.Target = target
	}
	if errMsg != "" {
		rc.Error = errMsg
	}
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func writeErr(w http.ResponseWriter, e *errx.Error) {
	if e == nil {
		writeJSON(w, 500, errx.New(500, "unknown error").Body())
		return
	}
	writeJSON(w, e.Status, e.Body())
}

func providedKey(r *http.Request) string {
	if h := r.Header.Get("Authorization"); h != "" {
		h = strings.TrimSpace(h)
		if strings.HasPrefix(strings.ToLower(h), "bearer ") {
			return strings.TrimSpace(h[7:])
		}
		return h
	}
	if k := r.Header.Get("x-api-key"); k != "" {
		return strings.TrimSpace(k)
	}
	if k := r.Header.Get("api-key"); k != "" {
		return strings.TrimSpace(k)
	}
	return strings.TrimSpace(r.URL.Query().Get("key"))
}

func secureEqual(a, b string) bool {
	if len(a) != len(b) {
		// still compare to keep timing closer
		subtle.ConstantTimeCompare([]byte(a), []byte(a))
		return false
	}
	return subtle.ConstantTimeCompare([]byte(a), []byte(b)) == 1
}

func (a *App) authenticate(r *http.Request) *errx.Error {
	master := a.Settings.MasterKey
	token := providedKey(r)
	// extract from headers (not query) for API auth
	token = headerToken(r)
	if master == "" {
		return nil
	}
	if token == "" {
		return errx.New(401, "no API key provided", errx.WithType("authentication_error"))
	}
	if secureEqual(token, master) {
		return nil
	}
	return errx.New(401, "invalid API key", errx.WithType("authentication_error"))
}

func headerToken(r *http.Request) string {
	for _, h := range []string{"Authorization", "x-api-key", "api-key"} {
		if v := r.Header.Get(h); v != "" {
			v = strings.TrimSpace(v)
			if strings.HasPrefix(strings.ToLower(v), "bearer ") {
				return strings.TrimSpace(v[7:])
			}
			return v
		}
	}
	return ""
}

func (a *App) authed(w http.ResponseWriter, r *http.Request, h func(http.ResponseWriter, *http.Request)) {
	if e := a.authenticate(r); e != nil {
		writeErr(w, e)
		return
	}
	h(w, r)
}

func (a *App) gated(w http.ResponseWriter, r *http.Request, h func(http.ResponseWriter, *http.Request)) {
	master := a.Settings.MasterKey
	if master == "" || secureEqual(providedKey(r), master) {
		h(w, r)
		return
	}
	writeJSON(w, 401, map[string]any{"error": map[string]any{"message": "unauthorized"}})
}

func cookieToken(master string) string {
	mac := hmac.New(sha256.New, []byte(master))
	_, _ = mac.Write([]byte("goll-status-session"))
	return base64.RawURLEncoding.EncodeToString(mac.Sum(nil))
}

func (a *App) browserGated(w http.ResponseWriter, r *http.Request, h func(http.ResponseWriter, *http.Request)) {
	master := a.Settings.MasterKey
	if master == "" {
		h(w, r)
		return
	}
	qKey := r.URL.Query().Get("key")
	if qKey != "" && secureEqual(qKey, master) {
		http.SetCookie(w, &http.Cookie{
			Name:     "goll_session",
			Value:    cookieToken(master),
			Path:     "/",
			HttpOnly: true,
			SameSite: http.SameSiteStrictMode,
			MaxAge:   24 * 3600,
		})
		http.Redirect(w, r, r.URL.Path, http.StatusFound)
		return
	}
	if qKey != "" {
		writeLogin(w, true)
		return
	}
	if tok := headerToken(r); tok != "" && secureEqual(tok, master) {
		h(w, r)
		return
	}
	if c, err := r.Cookie("goll_session"); err == nil && secureEqual(c.Value, cookieToken(master)) {
		h(w, r)
		return
	}
	writeLogin(w, false)
}

type countingWriter struct {
	http.ResponseWriter
	status      int
	n           int64
	wroteHeader bool
}

func (c *countingWriter) WriteHeader(code int) {
	if !c.wroteHeader {
		c.status = code
		c.wroteHeader = true
		c.ResponseWriter.WriteHeader(code)
	}
}

func (c *countingWriter) Write(p []byte) (int, error) {
	if !c.wroteHeader {
		c.WriteHeader(200)
	}
	n, err := c.ResponseWriter.Write(p)
	c.n += int64(n)
	return n, err
}

func (c *countingWriter) Flush() {
	if f, ok := c.ResponseWriter.(http.Flusher); ok {
		f.Flush()
	}
}

func (a *App) logRequest(r *http.Request, ww *countingWriter, rc *reqCtx) {
	if skipLog(r.URL.Path) || a.Store == nil {
		return
	}
	reqN := r.ContentLength
	if reqN < 0 {
		reqN = int64(len(rc.RawBody))
	}
	a.Store.Record(store.Record{
		Method:     r.Method,
		Path:       r.URL.Path,
		Model:      rc.Model,
		Target:     rc.Target,
		Status:     ww.status,
		DurationMS: time.Since(rc.Start).Milliseconds(),
		ReqBytes:   reqN,
		RespBytes:  ww.n,
		Stream:     strings.Contains(r.Header.Get("Accept"), "text/event-stream"),
		Error:      rc.Error,
	})
}

func skipLog(p string) bool {
	switch p {
	case "/health", "/health/readiness", "/health/liveliness", "/health/liveness",
		"/status", "/status.json", "/status/requests", "/favicon.ico", "/":
		return true
	default:
		return false
	}
}

func (a *App) health(w http.ResponseWriter) {
	writeJSON(w, 200, map[string]any{
		"healthy_endpoints":   []any{},
		"unhealthy_endpoints": []any{},
		"healthy_count":       0,
		"unhealthy_count":     0,
	})
}

func (a *App) readiness(w http.ResponseWriter) {
	db := "unconnected"
	if a.Store != nil && a.Store.Connected() {
		db = "connected"
	}
	writeJSON(w, 200, map[string]any{
		"status":          "connected",
		"db":              db,
		"litellm_version": version.Version,
	})
}

func (a *App) Close() {
	if a.Store != nil {
		a.Store.Close()
	}
}
