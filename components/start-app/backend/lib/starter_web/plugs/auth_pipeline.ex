defmodule StarterWeb.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :starter,
    module: Starter.Guardian,
    error_handler: StarterWeb.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
