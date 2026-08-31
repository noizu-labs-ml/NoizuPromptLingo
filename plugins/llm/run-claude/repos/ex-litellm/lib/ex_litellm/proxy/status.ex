defmodule ExLiteLLM.Proxy.Status do
  @moduledoc """
  Human-friendly status page — `GET /status` (HTML) and `GET /status.json`.

  Shows what the gateway is doing right now: version, uptime, listen address,
  routing mode + rules, registered deployments (credentials redacted), active
  cooldowns, and DB state. Master-key gated like the other admin surfaces —
  deployment names/models are configuration, not for anonymous eyes.
  """

  import Plug.Conn

  alias ExLiteLLM.FrontProxy.Rules
  alias ExLiteLLM.RequestLog
  alias ExLiteLLM.Router
  alias ExLiteLLM.Router.CooldownCache
  alias ExLiteLLM.Runtime

  @doc "GET /status.json — machine-readable status."
  def json(conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(snapshot()))
  end

  @doc "GET /status — HTML status page."
  def html(conn) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, render(snapshot()))
  end

  @doc """
  GET /status/requests — browsable request log. Query params: `limit` (default
  100, max 500), `errors=1` (errors only), `path=<substring>` filter,
  `format=json` for machine-readable.
  """
  def requests(conn) do
    conn = fetch_query_params(conn)
    q = conn.query_params

    opts = [
      limit: q |> Map.get("limit", "100") |> parse_limit(),
      errors_only: Map.get(q, "errors") in ["1", "true"],
      path_filter: blank_nil(Map.get(q, "path"))
    ]

    rows = RequestLog.recent(opts)
    stats = RequestLog.stats(60)

    if Map.get(q, "format") == "json" do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Jason.encode!(%{stats: stats, requests: rows}))
    else
      conn
      |> put_resp_content_type("text/html")
      |> send_resp(200, render_requests(rows, stats, opts))
    end
  end

  defp parse_limit(s) do
    case Integer.parse(s) do
      {n, _} when n > 0 -> min(n, 500)
      _ -> 100
    end
  end

  defp blank_nil(nil), do: nil
  defp blank_nil(""), do: nil
  defp blank_nil(v), do: v

  defp render_requests(rows, stats, opts) do
    """
    <!doctype html>
    <html><head><meta charset="utf-8"><title>ex-litellm requests</title>
    <meta http-equiv="refresh" content="15">
    <style>
      :root { color-scheme: light dark; }
      body { font: 13px/1.45 -apple-system, "Segoe UI", sans-serif; max-width: 1200px;
             margin: 1.5rem auto; padding: 0 1rem; }
      h1 { font-size: 1.2rem; }
      table { border-collapse: collapse; width: 100%; }
      th, td { text-align: left; padding: .3rem .55rem; border-bottom: 1px solid #8883;
               white-space: nowrap; }
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
      <div class="stat"><b>#{stats.count}</b> requests / #{stats.window_minutes}m</div>
      <div class="stat"><b>#{stats.errors}</b> errors</div>
      <div class="stat"><b>#{stats.avg_ms}ms</b> avg</div>
      <div class="stat"><b>#{stats.max_ms}ms</b> max</div>
      <div class="stat"><b>#{bytes(stats.req_bytes)}</b> in</div>
      <div class="stat"><b>#{bytes(stats.resp_bytes)}</b> out</div>
    </div>
    <p class="filters">
      <a href="/status/requests">all</a>
      <a href="/status/requests?errors=1">errors only</a>
      <a href="/status/requests?path=/v1/messages">messages</a>
      <a href="/status/requests?path=/v1/chat">chat</a>
      <a href="/status/requests?format=json#{if opts[:errors_only], do: "&errors=1", else: ""}">json</a>
    </p>
    #{requests_table(rows)}
    <p style="margin-top:1.5rem;opacity:.6">newest first · auto-refreshes every 15s ·
      showing #{length(rows)} rows</p>
    </body></html>
    """
  end

  defp requests_table([]), do: ~s(<p class="empty">no requests logged yet</p>)

  defp requests_table(rows) do
    tr =
      Enum.map_join(rows, "\n", fn r ->
        "<tr><td>#{time(r.at)}</td><td>#{h(r.method)}</td>" <>
          "<td class=\"path\" title=\"#{h(r.path)}\"><code>#{h(r.path)}</code></td>" <>
          "<td>#{h(r.model || "-")}</td><td>#{h(short_target(r.target))}</td>" <>
          "<td class=\"#{status_class(r.status)}\">#{r.status || "-"}</td>" <>
          "<td>#{r.duration_ms || 0}ms</td><td>#{bytes(r.req_bytes)}</td>" <>
          "<td>#{bytes(r.resp_bytes)}</td><td>#{if r.stream, do: "sse", else: ""}</td>" <>
          "<td class=\"err\" title=\"#{h(r.error)}\">#{h(r.error)}</td></tr>"
      end)

    """
    <table>
    <tr><th>time</th><th>m</th><th>path</th><th>model</th><th>target</th>
        <th>st</th><th>dur</th><th>in</th><th>out</th><th></th><th>error</th></tr>
    #{tr}
    </table>
    """
  end

  defp status_class(s) when is_integer(s) and s < 400, do: "s2"
  defp status_class(s) when is_integer(s) and s < 500, do: "s4"
  defp status_class(_), do: "s5"

  defp time(nil), do: "-"
  defp time(%DateTime{} = dt), do: dt |> DateTime.truncate(:second) |> Calendar.strftime("%H:%M:%S")

  defp short_target(nil), do: "-"
  defp short_target("https://api.anthropic.com" <> _), do: "anthropic"
  defp short_target("native:" <> provider), do: provider
  defp short_target(url), do: url |> String.replace(~r{^https?://}, "") |> String.slice(0, 24)

  defp bytes(nil), do: "0"
  defp bytes(n) when n < 1024, do: "#{n}B"
  defp bytes(n) when n < 1024 * 1024, do: "#{Float.round(n / 1024, 1)}K"
  defp bytes(n), do: "#{Float.round(n / (1024 * 1024), 1)}M"

  @doc """
  Login form shown when `/status` is opened in a browser without a valid key.
  Submits the master key as a GET param; on success the gateway sets a session
  cookie and redirects to a clean `/status` URL (key never lingers in the bar).
  """
  def login(conn, error? \\ false) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(if(error?, do: 401, else: 200), render_login(error?))
  end

  defp render_login(error?) do
    """
    <!doctype html>
    <html><head><meta charset="utf-8"><title>ex-litellm status — sign in</title>
    <style>
      :root { color-scheme: light dark; }
      body { font: 14px/1.5 -apple-system, "Segoe UI", sans-serif; display: flex;
             min-height: 90vh; align-items: center; justify-content: center; }
      form { border: 1px solid #8884; border-radius: 8px; padding: 2rem;
             min-width: 320px; }
      h1 { font-size: 1.1rem; margin-top: 0; }
      input[type=password] { width: 100%; box-sizing: border-box; padding: .5rem;
             margin: .5rem 0 1rem; border: 1px solid #8886; border-radius: 4px; }
      button { padding: .5rem 1.2rem; border-radius: 4px; border: none;
             background: #2e6be6; color: white; font-weight: 600; cursor: pointer; }
      .err { color: #d33; margin-bottom: .8rem; }
    </style></head><body>
    <form method="get" action="/status">
      <h1>ex-litellm status</h1>
      #{if error?, do: ~s(<p class="err">Invalid master key.</p>), else: ""}
      <label for="key">Master key</label>
      <input type="password" id="key" name="key" autofocus autocomplete="current-password">
      <button type="submit">View status</button>
    </form>
    </body></html>
    """
  end

  # --- data ---

  defp snapshot do
    settings = Runtime.get()
    {wall_ms, _} = :erlang.statistics(:wall_clock)

    %{
      service: "ex-litellm",
      version: ExLiteLLM.version(),
      listen: "#{settings.host}:#{settings.port}",
      uptime_seconds: div(wall_ms, 1000),
      config_path: settings.config_path,
      db: db_info(settings),
      front_proxy: %{
        mode: Rules.mode(),
        rules: length(Rules.list())
      },
      deployments: deployments(),
      cooldowns: CooldownCache.active()
    }
  end

  defp deployments do
    Enum.map(Router.deployments(), fn d ->
      %{
        model_name: d["model_name"],
        model: get_in(d, ["litellm_params", "model"]),
        api_base: get_in(d, ["litellm_params", "api_base"]),
        model_id: d["model_id"]
      }
    end)
  end

  defp db_info(settings) do
    %{
      backend: if(settings.database_url, do: redact(settings.database_url), else: "sqlite (default)"),
      connected: Process.whereis(ExLiteLLM.Schema.Repo) != nil
    }
  end

  defp redact(url), do: Regex.replace(~r{://([^:/@]+):([^@]+)@}, url, "://\\1:****@")

  # --- render ---

  defp render(s) do
    """
    <!doctype html>
    <html><head><meta charset="utf-8"><title>ex-litellm status</title>
    <meta http-equiv="refresh" content="10">
    <style>
      :root { color-scheme: light dark; }
      body { font: 14px/1.5 -apple-system, "Segoe UI", sans-serif; max-width: 900px;
             margin: 2rem auto; padding: 0 1rem; }
      h1 { font-size: 1.3rem; } h2 { font-size: 1.05rem; margin-top: 1.6rem; }
      .ok { color: #2e9e44; font-weight: 600; }
      table { border-collapse: collapse; width: 100%; }
      th, td { text-align: left; padding: .35rem .6rem; border-bottom: 1px solid #8884; }
      th { font-weight: 600; }
      code { background: #8882; padding: .1rem .3rem; border-radius: 3px; }
      .meta td:first-child { font-weight: 600; width: 11rem; }
      .empty { opacity: .6; font-style: italic; }
    </style></head><body>
    <h1>ex-litellm <span class="ok">&#9679; running</span></h1>
    <table class="meta">
      <tr><td>Version</td><td>#{h(s.version)}</td></tr>
      <tr><td>Listen</td><td><code>#{h(s.listen)}</code></td></tr>
      <tr><td>Uptime</td><td>#{uptime(s.uptime_seconds)}</td></tr>
      <tr><td>Config</td><td><code>#{h(s.config_path || "(none)")}</code></td></tr>
      <tr><td>Database</td><td><code>#{h(s.db.backend)}</code> — #{if s.db.connected, do: ~s(<span class="ok">connected</span>), else: "down"}</td></tr>
      <tr><td>Routing mode</td><td><code>#{h(s.front_proxy.mode)}</code> (#{s.front_proxy.rules} rules — <a href="/front/rules">view</a>)</td></tr>
    </table>

    <h2>Deployments (#{length(s.deployments)})</h2>
    #{deployments_table(s.deployments)}

    <h2>Active cooldowns (#{length(s.cooldowns)})</h2>
    #{cooldowns_list(s.cooldowns)}

    <p style="margin-top:2rem;opacity:.6">auto-refreshes every 10s ·
      <a href="/status/requests">request log</a> ·
      <a href="/status.json">status.json</a> · <a href="/health">health</a> ·
      <a href="/model/info">model/info</a></p>
    </body></html>
    """
  end

  defp deployments_table([]), do: ~s(<p class="empty">none registered</p>)

  defp deployments_table(deps) do
    rows =
      Enum.map_join(deps, "\n", fn d ->
        "<tr><td><code>#{h(d.model_name)}</code></td><td>#{h(d.model)}</td>" <>
          "<td>#{h(d.api_base || "provider default")}</td><td><code>#{h(short(d.model_id))}</code></td></tr>"
      end)

    """
    <table><tr><th>model_name</th><th>upstream model</th><th>api_base</th><th>id</th></tr>
    #{rows}</table>
    """
  end

  defp cooldowns_list([]), do: ~s(<p class="empty">none — all deployments healthy</p>)

  defp cooldowns_list(ids) do
    "<ul>" <> Enum.map_join(ids, "", &"<li><code>#{h(&1)}</code></li>") <> "</ul>"
  end

  defp uptime(secs) when secs < 60, do: "#{secs}s"
  defp uptime(secs) when secs < 3600, do: "#{div(secs, 60)}m #{rem(secs, 60)}s"

  defp uptime(secs) do
    h = div(secs, 3600)
    m = div(rem(secs, 3600), 60)
    if h >= 24, do: "#{div(h, 24)}d #{rem(h, 24)}h #{m}m", else: "#{h}h #{m}m"
  end

  defp short(nil), do: "-"
  defp short(id) when byte_size(id) > 10, do: binary_part(id, 0, 10) <> "…"
  defp short(id), do: id

  # Minimal HTML escaping for interpolated values.
  defp h(nil), do: ""

  defp h(value) do
    value
    |> to_string()
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
  end
end
