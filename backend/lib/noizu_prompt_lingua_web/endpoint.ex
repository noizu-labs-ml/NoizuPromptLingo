defmodule NoizuPromptLinguaWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :noizu_prompt_lingua

  socket "/socket", NoizuPromptLinguaWeb.UserSocket,
    websocket: [timeout: 45_000],
    longpoll: false

  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :noizu_prompt_lingua
  end

  plug NoizuPromptLinguaWeb.Plugs.CORS
  plug Plug.RequestId
  plug NoizuPromptLinguaWeb.Plugs.OtelLoggerMetadata
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug NoizuPromptLinguaWeb.Plugs.McpHostRedirect
  plug NoizuPromptLinguaWeb.Router
end
