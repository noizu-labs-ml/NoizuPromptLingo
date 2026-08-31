defmodule NoizuPromptLinguaWeb.Plugs.AuthPipeline.GuardianHeader do
  @moduledoc false

  # Guardian's VerifyHeader would treat a raw (non-JWT) key as an invalid token
  # and its error handler SENDS a 401 even with halt: false — so requests that
  # key-auth plugs already authenticated (:auth_method == :api_key) must skip
  # header verification entirely, not merely AuthPipeline's ensure_session.

  @behaviour Plug

  @impl true
  def init(opts), do: Guardian.Plug.VerifyHeader.init(opts)

  @impl true
  def call(conn, opts) do
    case conn.assigns[:auth_method] do
      :api_key -> conn
      _ -> Guardian.Plug.VerifyHeader.call(conn, opts)
    end
  end
end

defmodule NoizuPromptLinguaWeb.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :noizu_prompt_lingua,
    module: NoizuPromptLingua.Guardian,
    error_handler: NoizuPromptLinguaWeb.AuthErrorHandler

  # halt: false so a raw service API key (not a JWT) does not 401 here —
  # ApiKeyAuth already authenticated those requests.
  plug NoizuPromptLinguaWeb.Plugs.AuthPipeline.GuardianHeader
  plug :ensure_session
  plug Guardian.Plug.LoadResource, allow_blank: true

  defp ensure_session(conn, opts) do
    cond do
      conn.assigns[:auth_method] == :api_key ->
        conn

      Guardian.Plug.authenticated?(conn, opts) ->
        conn

      true ->
        conn
        |> NoizuPromptLinguaWeb.AuthErrorHandler.auth_error(
          {:unauthenticated, :unauthenticated},
          opts
        )
        |> Plug.Conn.halt()
    end
  end
end
