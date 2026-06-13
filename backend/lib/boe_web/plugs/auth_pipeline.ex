defmodule BoeWeb.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :boe,
    module: Boe.Guardian,
    error_handler: BoeWeb.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
