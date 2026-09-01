defmodule NoizuPromptLingua.TRP.ServiceAuth do
  @moduledoc """
  JWT service-identity auth for the TRP surfaces the shared-key plane does not
  cover (v1: org provisioning — `POST /api/v1/organizations` is JWT-only per
  docs/api/shared-key-api.md §4.1).

  - Credentials: `TRP_SERVICE_EMAIL` / `TRP_SERVICE_PASSWORD` env vars (or app
    env `:noizu_prompt_lingua, :trp_service` keyword `[:email, :password]`).
    Base URL is the shared `NoizuPromptLingua.TRP.Config.base_url/0`.
  - `POST /api/v1/auth/login` yields a 1h access token + 7d refresh token
    (TRP AuthController); the access token is cached in ETS and rotated via
    `POST /api/v1/auth/refresh` once it passes the refresh margin (50m).
  - A 401 mid-flight clears the cache, re-authenticates once, and retries.
  - Missing config is not a boot error: calls return
    `{:error, :trp_service_not_configured}` / `{:error, :trp_not_configured}`.
  """

  require Logger

  @table :noizu_trp_service_auth
  @refresh_after_ms 50 * 60 * 1000

  alias NoizuPromptLingua.TRP.{Config, Error}

  @doc "`{:ok, access_token}` or `{:error, term}` — cached; rotates past the margin."
  def token do
    case cached() do
      %{access: access, fetched_at: at} when is_binary(access) ->
        if stale?(at), do: rotate(), else: {:ok, access}

      _ ->
        login()
    end
  end

  @doc """
  Authenticated request against the JWT plane. Same shapes as
  `NoizuPromptLingua.TRP.Client.request/3`; one 401-triggered re-auth retry.
  """
  def authed_request(method, path, opts \\ []) do
    case token() do
      {:ok, access} -> do_request(method, path, opts, access, retries_left: 1)
      {:error, _} = err -> err
    end
  end

  @doc "Force re-authentication on the next call (tests + 401 recovery)."
  def reset do
    ensure_table()
    :ets.delete(@table, :auth)
    :ok
  end

  # ── internals ─────────────────────────────────────────────────────

  defp do_request(method, path, opts, access, retries_left: left) do
    headers = [
      {"authorization", "Bearer " <> access},
      {"accept", "application/json"}
    ]

    case transport().request(method, Config.base_url(), path, headers, opts[:json], []) do
      {:ok, status, raw_body} when status == 401 and left > 0 ->
        Logger.warning("TRP service token rejected (401); re-authenticating once")
        reset()

        case login() do
          {:ok, fresh} -> do_request(method, path, opts, fresh, retries_left: 0)
          {:error, _} = err -> err
        end

      {:ok, status, raw_body} when status in 200..299 ->
        {:ok, decode(raw_body)}

      {:ok, status, raw_body} ->
        {:error, Error.from_response(status, decode(raw_body))}

      {:error, reason} ->
        {:error, {:transport, reason}}
    end
  end

  defp login do
    case credentials() do
      {email, password} when is_binary(email) and email != "" and is_binary(password) ->
        case call(:post, "/api/v1/auth/login", %{email: email, password: password}) do
          {:ok, body} ->
            access = pick(body, :access_token)
            refresh = pick(body, :refresh_token)

            if is_binary(access) and is_binary(refresh) do
              store(%{access: access, refresh: refresh, fetched_at: now_ms()})
              {:ok, access}
            else
              {:error, :trp_service_login_invalid_response}
            end

          {:error, _} = err ->
            err
        end

      _ ->
        {:error, :trp_service_not_configured}
    end
  end

  defp rotate do
    %{refresh: refresh} = cached()

    case call(:post, "/api/v1/auth/refresh", %{refresh_token: refresh}) do
      {:ok, body} ->
        access = pick(body, :access_token)
        new_refresh = pick(body, :refresh_token) || refresh

        if is_binary(access) do
          store(%{access: access, refresh: new_refresh, fetched_at: now_ms()})
          {:ok, access}
        else
          Logger.warning("TRP service token refresh failed; falling back to login")
          reset()
          login()
        end

      _ ->
        # Refresh rejected/revoked — fall back to a full login.
        Logger.warning("TRP service token refresh failed; falling back to login")
        reset()
        login()
    end
  end

  # Req/Jason key-style tolerance: transports may hand back atom- or
  # string-keyed decoded JSON.
  defp pick(map, key) when is_map(map) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key))
  end

  defp pick(_, _), do: nil

  defp call(method, path, body) do
    headers = [{"accept", "application/json"}]

    case transport().request(method, Config.base_url(), path, headers, body, []) do
      {:ok, status, raw_body} when status in 200..299 ->
        {:ok, decode(raw_body)}

      {:ok, status, raw_body} ->
        {:error, Error.from_response(status, decode(raw_body))}

      {:error, reason} ->
        {:error, {:transport, reason}}
    end
  end

  defp credentials do
    kw = Application.get_env(:noizu_prompt_lingua, :trp_service, [])
    email = Keyword.get(kw, :email) || System.get_env("TRP_SERVICE_EMAIL")
    password = Keyword.get(kw, :password) || System.get_env("TRP_SERVICE_PASSWORD")
    {email, password}
  end

  defp transport do
    Application.get_env(:noizu_prompt_lingua, :trp_service_transport) ||
      Application.get_env(:noizu_prompt_lingua, :trp_transport) ||
      NoizuPromptLingua.TRP.Transport.Req
  end

  defp cached do
    ensure_table()

    case :ets.lookup(@table, :auth) do
      [{:auth, value}] -> value
      [] -> nil
    end
  end

  defp store(value) do
    ensure_table()
    :ets.insert(@table, {:auth, value})
    :ok
  end

  defp stale?(fetched_at), do: now_ms() - fetched_at > @refresh_after_ms

  # Envelope decode matching NoizuPromptLingua.TRP.Client: string-keyed wire
  # data atomized safely (unknown keys keep their string form; callers use
  # key-style-tolerant pick/2).
  defp decode(nil), do: nil
  defp decode(""), do: nil

  defp decode(body) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, decoded} -> atomize(decoded)
      _ -> nil
    end
  end

  defp decode(decoded) when is_map(decoded) or is_list(decoded), do: atomize(decoded)

  # Structs (DateTime etc.) are maps — pass them through untouched.
  defp atomize(%_{} = struct), do: struct

  defp atomize(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {safe_atom(k), atomize(v)} end)
  end

  defp atomize(list) when is_list(list), do: Enum.map(list, &atomize/1)
  defp atomize(other), do: other

  defp safe_atom(k) when is_binary(k) do
    String.to_existing_atom(k)
  rescue
    ArgumentError -> k
  end

  defp safe_atom(k), do: k

  defp now_ms, do: System.system_time(:millisecond)

  defp ensure_table do
    # Named-table creation races between concurrent processes are fine: the
    # loser gets ArgumentError, which we swallow.
    if :ets.whereis(@table) == :undefined do
      try do
        :ets.new(@table, [:named_table, :public, :set])
      rescue
        ArgumentError -> :ok
      end
    end

    :ok
  end
end
