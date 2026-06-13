defmodule DerobotWeb.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :derobot,
    module: Derobot.Guardian,
    error_handler: DerobotWeb.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
