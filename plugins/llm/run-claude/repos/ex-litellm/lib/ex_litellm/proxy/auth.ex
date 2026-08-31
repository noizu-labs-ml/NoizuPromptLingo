defmodule ExLiteLLM.Proxy.Auth do
  @moduledoc """
  Request authentication — ex-litellm's `UserAPIKeyAuth`
  (`litellm/proxy/auth/user_api_key_auth.py`).

  Phase 2 implements the two ends that matter for run-claude:

    * **public routes** — health/liveness/readiness bypass auth entirely.
    * **master key** — a `Bearer <master_key>` (constant-time compared) grants
      admin/proxy access and short-circuits any DB lookup.

  Virtual-key DB lookup (hashed tokens, budgets, RPM/TPM), JWT, and SSO layer in
  at the persistence + auth-plane phases. Until then, any non-master key is
  rejected unless no master key is configured (open dev mode).

  Used as a plug: on success it stamps `conn.assigns.auth` with a
  `%{role: :proxy_admin | :open, api_key: ...}` and continues; on failure it
  halts with a 401 in the OpenAI error envelope.
  """

  import Plug.Conn

  alias ExLiteLLM.Error
  alias ExLiteLLM.Runtime

  @token_headers ~w(authorization x-api-key api-key)

  @doc "Plug entry — authenticate the request or halt 401."
  @spec call(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def call(conn, _opts) do
    case authenticate(conn) do
      {:ok, auth} -> assign(conn, :auth, auth)
      {:error, %Error{} = e} -> halt_error(conn, e)
    end
  end

  @doc """
  Authenticate a conn. Returns `{:ok, auth_map}` or `{:error, %Error{}}`.
  Exposed for direct use by controllers that need auth without the plug.
  """
  @spec authenticate(Plug.Conn.t()) :: {:ok, map()} | {:error, Error.t()}
  def authenticate(conn) do
    master_key = Runtime.get().master_key
    token = extract_token(conn)

    cond do
      is_nil(master_key) or master_key == "" ->
        # No master key configured → open dev mode.
        {:ok, %{role: :open, api_key: token}}

      is_binary(token) and secure_equal?(token, master_key) ->
        {:ok, %{role: :proxy_admin, api_key: token}}

      is_nil(token) ->
        {:error, Error.new(401, "no API key provided", type: "authentication_error")}

      true ->
        # Virtual-key DB lookup lands later; for now non-master keys are denied.
        {:error, Error.new(401, "invalid API key", type: "authentication_error")}
    end
  end

  # --- token extraction ---

  defp extract_token(conn) do
    Enum.find_value(@token_headers, fn header ->
      case get_req_header(conn, header) do
        [value | _] -> strip_bearer(value)
        _ -> nil
      end
    end)
  end

  defp strip_bearer("Bearer " <> rest), do: String.trim(rest)
  defp strip_bearer("bearer " <> rest), do: String.trim(rest)
  defp strip_bearer(value) when is_binary(value), do: String.trim(value)
  defp strip_bearer(_), do: nil

  defp secure_equal?(a, b) when is_binary(a) and is_binary(b),
    do: Plug.Crypto.secure_compare(a, b)

  defp secure_equal?(_, _), do: false

  defp halt_error(conn, %Error{} = e) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(e.status, Jason.encode!(Error.to_body(e)))
    |> halt()
  end
end
