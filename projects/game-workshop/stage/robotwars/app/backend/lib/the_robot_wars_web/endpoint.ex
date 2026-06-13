defmodule TheRobotWarsWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :the_robot_wars

  socket "/socket", TheRobotWarsWeb.UserSocket,
    websocket: [timeout: 45_000],
    longpoll: false

  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :the_robot_wars
  end

  plug TheRobotWarsWeb.Plugs.CORS
  plug Plug.RequestId
  plug TheRobotWarsWeb.Plugs.OtelLoggerMetadata
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug TheRobotWarsWeb.Router
end
