defmodule NoizuPromptLinguaWeb.Plugs.ApiKeyAuth do
  @moduledoc """
  Fixed API-key authentication plug — runs BEFORE the Guardian AuthPipeline.

  When a request carries a Bearer token or X-API-Key header matching one of the
  configured `:api_key_auth` keys AND `NPL_SERVICE_USER_ID` is set, this plug
  loads the service user, builds a synthetic `%UserSession{}`, and puts it as
  the Guardian current resource. AuthPipeline then skips JWT verification for
  `:auth_method == :api_key`. This plug must not `halt/1` — a halted conn never
  reaches the controller.

  If no key is present, the key is invalid, or the service user is not
  configured / does not exist, the conn passes through unchanged so the normal
  Guardian OAuth/JWT pipeline runs.

  ## Configuration (config/runtime.exs)

      config :noizu_prompt_lingua, :api_key_auth,
        keys: ["secret1", "secret2"],           # CSV from NPL_SERVICE_API_KEYS
        service_user_id: "00000000-..."          # from NPL_SERVICE_USER_ID

  # TODO: The operator must seed a service-account user (+ org membership) and
  # set NPL_SERVICE_USER_ID to its UUID. A mix task or migration could automate
  # this — for now it is a manual ops prerequisite.
  """

  import Plug.Conn
  import Guardian.Plug, only: [put_current_resource: 2]

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    config = Application.get_env(:noizu_prompt_lingua, :api_key_auth, [])
    keys = Keyword.get(config, :keys, [])
    service_user_id = Keyword.get(config, :service_user_id)

    key = extract_key(conn)

    cond do
      key == nil or key == "" ->
        conn

      service_user_id == nil or service_user_id == "" ->
        # Service user not configured — fall through to OAuth pipeline.
        conn

      key in keys ->
        authenticate_as_service_user(conn, service_user_id)

      true ->
        # Key present but not recognised — fall through (Guardian will reject
        # it if it's also not a valid JWT).
        conn
    end
  end

  defp extract_key(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token | _] -> String.trim(token)
      _ -> get_req_header(conn, "x-api-key") |> List.first()
    end
  end

  defp authenticate_as_service_user(conn, service_user_id) do
    case load_service_user(service_user_id) do
      {:ok, user} when user != nil ->
        session = build_session(user)
        # Do not halt: Phoenix skips the controller when conn.halted is set, so
        # a successful API-key auth would never reach the action. AuthPipeline
        # skips Guardian when :auth_method == :api_key.
        conn
        |> put_current_resource(session)
        |> assign(:auth_method, :api_key)

      _ ->
        # Service user doesn't exist, nil, or DB error — fall through.
        # TODO: log the error so operators can diagnose misconfiguration.
        conn
    end
  end

  defp load_service_user(user_id) do
    NoizuPromptLingua.Users.get_user(user_id, Noizu.Context.system())
  end

  defp build_session(user) do
    %NoizuPromptLingua.Users.Sessions.UserSession{
      id: nil,
      user: {:ref, NoizuPromptLingua.Users.User, user.id},
      status: :active,
      details: %{auth_method: :api_key}
    }
  end
end
