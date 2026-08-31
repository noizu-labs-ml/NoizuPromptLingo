package gateway

import (
	"fmt"
	"html"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/noizu-labs/go-litellm/internal/jsonx"
	"github.com/noizu-labs/go-litellm/internal/store"
	"github.com/noizu-labs/go-litellm/internal/version"
)

func (a *App) snapshot() map[string]any {
	var deps []any
	for _, d := range a.Router.Deployments() {
		lp := jsonx.Nested(d, "litellm_params")
		deps = append(deps, map[string]any{
			"model_name": jsonx.Str(d, "model_name"),
			"model":      jsonx.Str(lp, "model"),
			"api_base":   jsonx.Str(lp, "api_base"),
			"model_id":   jsonx.Str(d, "model_id"),
			"key":        jsonx.Str(lp, "api_key_name"),
		})
	}
	dbBackend := "sqlite (default)"
	if a.Settings.DatabaseURL != "" {
		dbBackend = store.RedactURL(a.Settings.DatabaseURL)
	} else if a.Store != nil && a.Store.Path() != "" {
		dbBackend = a.Store.Path()
	}
	return map[string]any{
		"service":        "go-litellm",
		"version":        version.Version,
		"listen":         fmt.Sprintf("%s:%d", a.Settings.Host, a.Settings.Port),
		"uptime_seconds": int(time.Since(a.Started).Seconds()),
		"config_path":    a.Settings.ConfigPath,
		"db": map[string]any{
			"backend":   dbBackend,
			"connected": a.Store != nil && a.Store.Connected(),
		},
		"front_proxy": map[string]any{
			"mode":  a.Rules.Mode(),
			"rules": len(a.Rules.List()),
		},
		"deployments": deps,
		"cooldowns":   a.Router.Cooldowns(),
	}
}

func (a *App) statusJSON(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, 200, a.snapshot())
}

func (a *App) statusHTML(w http.ResponseWriter, _ *http.Request) {
	s := a.snapshot()
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	_, _ = fmt.Fprint(w, renderStatus(s))
}

func (a *App) statusRequests(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()
	limit := 100
	if n, err := strconv.Atoi(q.Get("limit")); err == nil && n > 0 {
		limit = n
		if limit > 500 {
			limit = 500
		}
	}
	errorsOnly := q.Get("errors") == "1" || q.Get("errors") == "true"
	pathFilter := q.Get("path")
	var rows []store.Record
	var stats store.Stats
	if a.Store != nil {
		rows = a.Store.Recent(limit, errorsOnly, pathFilter)
		stats = a.Store.Stats(60)
	}
	if q.Get("format") == "json" {
		writeJSON(w, 200, map[string]any{"stats": stats, "requests": rows})
		return
	}
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	_, _ = fmt.Fprint(w, renderRequests(rows, stats, errorsOnly))
}

func writeLogin(w http.ResponseWriter, err bool) {
	status := 200
	errHTML := ""
	if err {
		status = 401
		errHTML = `<p class="err">Invalid master key.</p>`
	}
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.WriteHeader(status)
	_, _ = fmt.Fprintf(w, `<!doctype html>
<html><head><meta charset="utf-8"><title>go-litellm status — sign in</title>
<style>
  :root { color-scheme: light dark; }
  body { font: 14px/1.5 -apple-system, "Segoe UI", sans-serif; display: flex;
         min-height: 90vh; align-items: center; justify-content: center; }
  form { border: 1px solid #8884; border-radius: 8px; padding: 2rem; min-width: 320px; }
  h1 { font-size: 1.1rem; margin-top: 0; }
  input[type=password] { width: 100%%; box-sizing: border-box; padding: .5rem;
         margin: .5rem 0 1rem; border: 1px solid #8886; border-radius: 4px; }
  button { padding: .5rem 1.2rem; border-radius: 4px; border: none;
         background: #2e6be6; color: white; font-weight: 600; cursor: pointer; }
  .err { color: #d33; margin-bottom: .8rem; }
</style></head><body>
<form method="get" action="/status">
  <h1>go-litellm status</h1>
  %s
  <label for="key">Master key</label>
  <input type="password" id="key" name="key" autofocus autocomplete="current-password">
  <button type="submit">View status</button>
</form>
</body></html>`, errHTML)
}

func renderStatus(s map[string]any) string {
	db := jsonx.AsMap(s["db"])
	fp := jsonx.AsMap(s["front_proxy"])
	connected := "down"
	if jsonx.Bool(db, "connected") {
		connected = `<span class="ok">connected</span>`
	}
	cfg := jsonx.Str(s, "config_path")
	if cfg == "" {
		cfg = "(none)"
	}
	deps, _ := s["deployments"].([]any)
	cds, _ := s["cooldowns"].([]string)
	uptime, _ := s["uptime_seconds"].(int)
	return fmt.Sprintf(`<!doctype html>
<html><head><meta charset="utf-8"><title>go-litellm status</title>
<meta http-equiv="refresh" content="10">
<style>
  :root { color-scheme: light dark; }
  body { font: 14px/1.5 -apple-system, "Segoe UI", sans-serif; max-width: 900px;
         margin: 2rem auto; padding: 0 1rem; }
  h1 { font-size: 1.3rem; } h2 { font-size: 1.05rem; margin-top: 1.6rem; }
  .ok { color: #2e9e44; font-weight: 600; }
  table { border-collapse: collapse; width: 100%%; }
  th, td { text-align: left; padding: .35rem .6rem; border-bottom: 1px solid #8884; }
  code { background: #8882; padding: .1rem .3rem; border-radius: 3px; }
  .meta td:first-child { font-weight: 600; width: 11rem; }
  .empty { opacity: .6; font-style: italic; }
</style></head><body>
<h1>go-litellm <span class="ok">&#9679; running</span></h1>
<table class="meta">
  <tr><td>Version</td><td>%s</td></tr>
  <tr><td>Listen</td><td><code>%s</code></td></tr>
  <tr><td>Uptime</td><td>%s</td></tr>
  <tr><td>Config</td><td><code>%s</code></td></tr>
  <tr><td>Database</td><td><code>%s</code> — %s</td></tr>
  <tr><td>Routing mode</td><td><code>%s</code> (%d rules — <a href="/front/rules">view</a>)</td></tr>
</table>
<h2>Deployments (%d)</h2>
%s
<h2>Active cooldowns (%d)</h2>
%s
<p style="margin-top:2rem;opacity:.6">auto-refreshes every 10s ·
  <a href="/status/requests">request log</a> ·
  <a href="/status.json">status.json</a> · <a href="/health">health</a> ·
  <a href="/model/info">model/info</a></p>
</body></html>`,
		h(jsonx.Str(s, "version")),
		h(jsonx.Str(s, "listen")),
		uptimeStr(uptime),
		h(cfg),
		h(jsonx.Str(db, "backend")),
		connected,
		h(fmt.Sprint(fp["mode"])),
		toInt(fp["rules"]),
		len(deps),
		deploymentsTable(deps),
		len(cds),
		cooldownsList(cds),
	)
}

func deploymentsTable(deps []any) string {
	if len(deps) == 0 {
		return `<p class="empty">none registered</p>`
	}
	var b strings.Builder
	b.WriteString(`<table><tr><th>model_name</th><th>upstream model</th><th>key</th><th>api_base</th><th>id</th></tr>`)
	for _, d := range deps {
		m := jsonx.AsMap(d)
		base := jsonx.Str(m, "api_base")
		if base == "" {
			base = "provider default"
		}
		key := jsonx.Str(m, "key")
		if key == "" {
			key = "—"
		}
		fmt.Fprintf(&b, "<tr><td><code>%s</code></td><td>%s</td><td><code>%s</code></td><td>%s</td><td><code>%s</code></td></tr>",
			h(jsonx.Str(m, "model_name")), h(jsonx.Str(m, "model")), h(key), h(base), h(shortID(jsonx.Str(m, "model_id"))))
	}
	b.WriteString(`</table>`)
	return b.String()
}

func cooldownsList(ids []string) string {
	if len(ids) == 0 {
		return `<p class="empty">none — all deployments healthy</p>`
	}
	var b strings.Builder
	b.WriteString("<ul>")
	for _, id := range ids {
		fmt.Fprintf(&b, "<li><code>%s</code></li>", h(id))
	}
	b.WriteString("</ul>")
	return b.String()
}

func renderRequests(rows []store.Record, stats store.Stats, errorsOnly bool) string {
	errQ := ""
	if errorsOnly {
		errQ = "&errors=1"
	}
	table := `<p class="empty">no requests logged yet</p>`
	if len(rows) > 0 {
		var b strings.Builder
		b.WriteString(`<table>
<tr><th>time</th><th>m</th><th>path</th><th>model</th><th>target</th>
    <th>st</th><th>dur</th><th>in</th><th>out</th><th></th><th>error</th></tr>`)
		for _, r := range rows {
			stream := ""
			if r.Stream {
				stream = "sse"
			}
			fmt.Fprintf(&b, `<tr><td>%s</td><td>%s</td><td class="path" title="%s"><code>%s</code></td>
<td>%s</td><td>%s</td><td class="%s">%s</td><td>%dms</td><td>%s</td><td>%s</td><td>%s</td>
<td class="err" title="%s">%s</td></tr>`,
				r.At.Format("15:04:05"), h(r.Method), h(r.Path), h(r.Path),
				h(dash(r.Model)), h(shortTarget(r.Target)),
				statusClass(r.Status), statusStr(r.Status), r.DurationMS,
				bytesStr(r.ReqBytes), bytesStr(r.RespBytes), stream,
				h(r.Error), h(r.Error))
		}
		b.WriteString(`</table>`)
		table = b.String()
	}
	return fmt.Sprintf(`<!doctype html>
<html><head><meta charset="utf-8"><title>go-litellm requests</title>
<meta http-equiv="refresh" content="15">
<style>
  :root { color-scheme: light dark; }
  body { font: 13px/1.45 -apple-system, "Segoe UI", sans-serif; max-width: 1200px;
         margin: 1.5rem auto; padding: 0 1rem; }
  h1 { font-size: 1.2rem; }
  table { border-collapse: collapse; width: 100%%; }
  th, td { text-align: left; padding: .3rem .55rem; border-bottom: 1px solid #8883; white-space: nowrap; }
  td.path { max-width: 260px; overflow: hidden; text-overflow: ellipsis; }
  td.err { max-width: 240px; overflow: hidden; text-overflow: ellipsis; color: #d33; }
  code { background: #8882; padding: .05rem .3rem; border-radius: 3px; }
  .s2 { color: #2e9e44; } .s4 { color: #d98a00; } .s5 { color: #d33; font-weight: 600; }
  .stats { display: flex; gap: 1.6rem; margin: .8rem 0 1.2rem; flex-wrap: wrap; }
  .stat b { display: block; font-size: 1.15rem; }
  .filters a { margin-right: 1rem; }
  .empty { opacity: .6; font-style: italic; }
</style></head><body>
<h1>Request log <small>(<a href="/status">status</a>)</small></h1>
<div class="stats">
  <div class="stat"><b>%d</b> requests / %dm</div>
  <div class="stat"><b>%d</b> errors</div>
  <div class="stat"><b>%dms</b> avg</div>
  <div class="stat"><b>%dms</b> max</div>
  <div class="stat"><b>%s</b> in</div>
  <div class="stat"><b>%s</b> out</div>
</div>
<p class="filters">
  <a href="/status/requests">all</a>
  <a href="/status/requests?errors=1">errors only</a>
  <a href="/status/requests?path=/v1/messages">messages</a>
  <a href="/status/requests?path=/v1/chat">chat</a>
  <a href="/status/requests?format=json%s">json</a>
</p>
%s
<p style="margin-top:1.5rem;opacity:.6">newest first · auto-refreshes every 15s · showing %d rows</p>
</body></html>`,
		stats.Count, stats.WindowMinutes, stats.Errors, stats.AvgMS, stats.MaxMS,
		bytesStr(stats.ReqBytes), bytesStr(stats.RespBytes), errQ, table, len(rows))
}

func h(s string) string { return html.EscapeString(s) }

func dash(s string) string {
	if s == "" {
		return "-"
	}
	return s
}

func shortID(id string) string {
	if len(id) > 10 {
		return id[:10] + "…"
	}
	if id == "" {
		return "-"
	}
	return id
}

func shortTarget(t string) string {
	switch {
	case t == "":
		return "-"
	case strings.HasPrefix(t, "https://api.anthropic.com"):
		return "anthropic"
	case strings.HasPrefix(t, "native:"):
		return strings.TrimPrefix(t, "native:")
	default:
		t = strings.TrimPrefix(strings.TrimPrefix(t, "https://"), "http://")
		if len(t) > 24 {
			return t[:24]
		}
		return t
	}
}

func statusClass(s int) string {
	switch {
	case s < 400:
		return "s2"
	case s < 500:
		return "s4"
	default:
		return "s5"
	}
}

func statusStr(s int) string {
	if s == 0 {
		return "-"
	}
	return strconv.Itoa(s)
}

func bytesStr(n int64) string {
	switch {
	case n < 1024:
		return fmt.Sprintf("%dB", n)
	case n < 1024*1024:
		return fmt.Sprintf("%.1fK", float64(n)/1024)
	default:
		return fmt.Sprintf("%.1fM", float64(n)/(1024*1024))
	}
}

func uptimeStr(secs int) string {
	switch {
	case secs < 60:
		return fmt.Sprintf("%ds", secs)
	case secs < 3600:
		return fmt.Sprintf("%dm %ds", secs/60, secs%60)
	default:
		h := secs / 3600
		m := (secs % 3600) / 60
		if h >= 24 {
			return fmt.Sprintf("%dd %dh %dm", h/24, h%24, m)
		}
		return fmt.Sprintf("%dh %dm", h, m)
	}
}

func toInt(v any) int {
	switch n := v.(type) {
	case int:
		return n
	case int64:
		return int(n)
	case float64:
		return int(n)
	default:
		return 0
	}
}
