defmodule NoizuPromptLinguaWeb.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :noizu_prompt_lingua,
    module: NoizuPromptLingua.Guardian,
    error_handler: NoizuPromptLinguaWeb.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
