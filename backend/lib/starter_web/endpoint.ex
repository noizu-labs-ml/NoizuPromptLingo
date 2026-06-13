defmodule StarterWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :starter

  socket "/socket", StarterWeb.UserSocket,
    websocket: [timeout: 45_000],
    longpoll: false

  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :starter
  end

  plug StarterWeb.Plugs.CORS
  plug Plug.RequestId
  plug StarterWeb.Plugs.OtelLoggerMetadata
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug StarterWeb.Router
end
