defmodule ExLiteLLM.Gateway do
  @moduledoc """
  The unified ex-litellm gateway — one HTTP server that is *both* the LiteLLM
  proxy and the front-proxy routing layer, on a single port.

  Rather than run two tiers (front :4443 → litellm :4444) as separate processes
  chained over HTTP, the front-proxy routing is folded directly into the gateway:

    * **Native LiteLLM endpoints** — `/v1/chat/completions`, `/v1/embeddings`,
      `/v1/models`, `/model/*`, health — are served **in-process** by the
      `ExLiteLLM.Proxy.*` handlers. No self-HTTP hop.
    * **Anthropic-shaped + passthrough traffic** — `/v1/messages` and anything
      else — is routed by the runtime-alterable `FrontProxy.Rules`. A `claude-*`
      messages request (or any `:passthrough` rule) is reverse-proxied upstream
      to Anthropic via `Gateway.Forwarder`, preserving the caller's auth. A
      non-`claude-*` messages request routes to the native inference path.
    * **Admin** — `GET/PUT /front/rules`, `PUT /front/mode`, `/api/claude_cli/bootstrap`.

  This is the single server run-claude launches: it listens where the front proxy
  used to (prod :4443) and needs no second litellm process.
  """
  use Plug.Router

  alias ExLiteLLM.FrontProxy.Bootstrap
  alias ExLiteLLM.Gateway.Router, as: GatewayRouter
  alias ExLiteLLM.Proxy.{Auth, Health, Inference, Models, Status}

  plug(ExLiteLLM.Proxy.MetricsPlug)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason, body_reader: {__MODULE__, :cache_body, []})
  plug(:stash_json_body)
  plug(:tag_model)
  plug(:dispatch)

  # --- public: health + banner + bootstrap ---
  get("/", do: send_resp(conn, 200, "LiteLLM: RUNNING"))
  get("/health", do: Health.health(conn))
  get("/health/readiness", do: Health.readiness(conn))
  get("/health/liveliness", do: Health.liveness(conn))
  get("/health/liveness", do: Health.liveness(conn))
  get("/api/claude_cli/bootstrap", do: json(conn, 200, Bootstrap.model_options()))

  # --- native LiteLLM inference plane (master-key auth) ---
  post("/v1/chat/completions", do: authed(conn, &Inference.chat_completions/1))
  post("/chat/completions", do: authed(conn, &Inference.chat_completions/1))
  post("/v1/embeddings", do: authed(conn, &Inference.embeddings/1))
  post("/embeddings", do: authed(conn, &Inference.embeddings/1))
  get("/v1/models", do: authed(conn, &Inference.models/1))
  get("/models", do: authed(conn, &Inference.models/1))

  # --- model management (run-claude registers models here) ---
  post("/model/new", do: authed(conn, &Models.new/1))
  post("/model/delete", do: authed(conn, &Models.delete/1))
  post("/model/update", do: authed(conn, &Models.update/1))
  get("/model/info", do: authed(conn, &Models.info/1))
  get("/v1/model/info", do: authed(conn, &Models.info/1))

  # --- front-proxy admin + status (master-key gated) ---
  get("/front/rules", do: gated(conn, &GatewayRouter.get_rules/1))
  put("/front/rules", do: gated(conn, &GatewayRouter.put_rules/1))
  put("/front/mode", do: gated(conn, &GatewayRouter.put_mode/1))
  get("/status", do: browser_gated(conn, &Status.html/1))
  get("/status.json", do: gated(conn, &Status.json/1))
  get("/status/requests", do: browser_gated(conn, &Status.requests/1))

  # --- Anthropic messages + all passthrough traffic ---
  # /v1/messages: claude-* → Anthropic passthrough; non-claude → native inference.
  post "/v1/messages" do
    GatewayRouter.messages(conn)
  end

  # Everything else → front-proxy rule table (default: Anthropic passthrough).
  match _ do
    GatewayRouter.passthrough(conn)
  end

  # --- plumbing ---

  defp authed(conn, handler) do
    conn = Auth.call(conn, [])
    if conn.halted, do: conn, else: handler.(conn)
  end

  defp gated(conn, handler) do
    master = ExLiteLLM.Runtime.get().master_key

    cond do
      is_nil(master) or master == "" -> handler.(conn)
      provided_key(conn) == master -> handler.(conn)
      true -> json(conn, 401, %{error: %{message: "unauthorized"}})
    end
  end

  # Admin key from the Authorization header, or `?key=` for browser pages
  # (the HTML /status page can't set headers from a plain URL).
  defp provided_key(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> key | _] -> String.trim(key)
      [key | _] -> String.trim(key)
      _ -> conn |> fetch_query_params() |> Map.get(:query_params) |> Map.get("key")
    end
  end

  # Browser-friendly gate for HTML pages: accepts the Authorization header, a
  # `?key=` query param, or the session cookie set on a prior successful `?key=`
  # auth. Query-param auth sets the cookie then redirects to the clean URL (so
  # the key doesn't linger in the address bar); no/invalid key → login form.
  defp browser_gated(conn, handler) do
    master = ExLiteLLM.Runtime.get().master_key
    conn = conn |> fetch_query_params() |> fetch_cookies()
    query_key = conn.query_params["key"]

    cond do
      is_nil(master) or master == "" ->
        handler.(conn)

      # Fresh ?key= auth → set session cookie, redirect to the clean URL.
      is_binary(query_key) and Plug.Crypto.secure_compare(query_key, master) ->
        conn
        |> put_resp_cookie("exll_session", cookie_token(master),
          http_only: true,
          same_site: "Strict",
          max_age: 24 * 3600
        )
        |> put_resp_header("location", conn.request_path)
        |> send_resp(302, "")

      # Wrong ?key= explicitly submitted → login form with error.
      is_binary(query_key) ->
        ExLiteLLM.Proxy.Status.login(conn, true)

      # Header auth (curl etc.).
      header_key_valid?(conn, master) ->
        handler.(conn)

      # Session cookie from a prior login.
      cookie_valid?(conn, master) ->
        handler.(conn)

      true ->
        ExLiteLLM.Proxy.Status.login(conn)
    end
  end

  defp header_key_valid?(conn, master) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> key | _] -> Plug.Crypto.secure_compare(String.trim(key), master)
      [key | _] -> Plug.Crypto.secure_compare(String.trim(key), master)
      _ -> false
    end
  end

  defp cookie_valid?(conn, master) do
    case conn.req_cookies["exll_session"] do
      token when is_binary(token) -> Plug.Crypto.secure_compare(token, cookie_token(master))
      _ -> false
    end
  end

  # Session token derived from the master key — not the key itself, so the
  # cookie can't be replayed as an API credential.
  defp cookie_token(master) do
    :crypto.mac(:hmac, :sha256, master, "exll-status-session") |> Base.url_encode64(padding: false)
  end

  defp stash_json_body(conn, _opts) do
    case conn.body_params do
      %Plug.Conn.Unfetched{} -> conn
      params when is_map(params) -> Plug.Conn.assign(conn, :json_body, params)
      _ -> conn
    end
  end

  # Attribute the request to its model in the request log (target is tagged by
  # the handlers once routing resolves).
  defp tag_model(conn, _opts) do
    case conn.assigns[:json_body] do
      %{"model" => model} when is_binary(model) ->
        ExLiteLLM.Proxy.MetricsPlug.tag(model: model)
        conn

      _ ->
        conn
    end
  end

  defp json(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(body))
  end

  @doc """
  Plug.Parsers body reader that also stashes the raw body in the process dict, so
  passthrough forwarding can relay the exact original bytes upstream (parsing
  consumes the body otherwise).
  """
  def cache_body(conn, opts) do
    {:ok, body, conn} = Plug.Conn.read_body(conn, opts)
    Process.put(:exll_raw_body, body)
    {:ok, body, conn}
  end
end
