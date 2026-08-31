defmodule ExLiteLLM.Schema.RequestLog do
  @moduledoc """
  One gateway request — timing, size, routing target, and outcome. Written
  asynchronously by `ExLiteLLM.RequestLog` after every proxied/served call;
  browsable from the status page (`/status/requests`).
  """
  use Ecto.Schema

  schema "request_logs" do
    field(:method, :string)
    field(:path, :string)
    field(:model, :string)
    field(:target, :string)
    field(:status, :integer)
    field(:duration_ms, :integer)
    field(:req_bytes, :integer)
    field(:resp_bytes, :integer)
    field(:stream, :boolean, default: false)
    field(:error, :string)
    field(:inserted_at, :utc_datetime_usec)
  end
end
