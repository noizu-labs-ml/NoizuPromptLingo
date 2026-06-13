defmodule DerobotWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :derobot

  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :derobot
  end

  plug DerobotWeb.Plugs.CORS
  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug DerobotWeb.Router
end
