defmodule NPLWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :noizu_prompt_lingua

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason

  plug NPLWeb.Router
end
