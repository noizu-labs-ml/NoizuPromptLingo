defmodule CodefreshWeb.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :codefresh,
    module: Codefresh.Guardian,
    error_handler: CodefreshWeb.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
