defmodule CodefreshWeb.Plugs.ApiTokenAuth do
  @moduledoc """
  Authenticates requests via a CodeFresh API token (distinct from the Guardian
  JWT pipeline used by browser sessions). Reads `authorization: Bearer <raw>`
  from the request headers, calls `Codefresh.ApiTokens.authenticate/1`, and
  on success assigns:

    * `conn.assigns[:api_token]` — the `%ApiToken{}` record
    * `conn.assigns[:organization_id]` — the token's `organization_id`

  On failure, responds `401 unauthorized` and halts.

  Used by OTel ingest endpoints (US-081) so that SDK/agent exporters can
  push spans using the same tokens we issue to CI and the CLI, without
  involving the user-auth pipeline.
  """

  import Plug.Conn

  alias Codefresh.ApiTokens

  def init(opts), do: opts

  def call(conn, _opts) do
    with {:ok, raw} <- fetch_bearer(conn),
         {:ok, token} <- ApiTokens.authenticate(raw) do
      conn
      |> assign(:api_token, token)
      |> assign(:organization_id, token.organization_id)
    else
      _ -> deny(conn)
    end
  end

  defp fetch_bearer(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> raw] -> {:ok, String.trim(raw)}
      ["bearer " <> raw] -> {:ok, String.trim(raw)}
      _ -> {:error, :missing_token}
    end
  end

  defp deny(conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, Jason.encode!(%{error: "unauthorized"}))
    |> halt()
  end
end
