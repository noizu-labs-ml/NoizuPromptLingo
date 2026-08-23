defmodule NoizuPromptLinguaWeb.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :noizu_prompt_lingua,
    module: NoizuPromptLingua.Guardian,
    error_handler: NoizuPromptLinguaWeb.AuthErrorHandler

  # halt: false so a raw service API key (not a JWT) does not 401 here —
  # ApiKeyAuth already authenticated those requests.
  plug Guardian.Plug.VerifyHeader, scheme: "Bearer", halt: false
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
