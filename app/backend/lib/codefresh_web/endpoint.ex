defmodule CodefreshWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :codefresh

  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :codefresh
  end

  plug CodefreshWeb.Plugs.CORS
  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug CodefreshWeb.Router
end
