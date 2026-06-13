defmodule EchoStdio.Tools.Echo do
  @moduledoc "Echo a message back, optionally repeated or upcased."

  use Noizu.MCP.Server.Tool,
    description: "Echo a message back. Set mode=loud to upcase it.",
    annotations: [read_only_hint: true]

  input do
    field :message, :string, required: true, description: "The message to echo"
    field :repeat, :integer, min: 1, max: 5, default: 1, description: "Repeat count"
    field :mode, :enum, values: [:plain, :loud], default: :plain
  end

  @impl true
  def call(%{message: message, repeat: repeat, mode: mode}, ctx) do
    Noizu.MCP.Ctx.report_progress(ctx, 0.5, message: "echoing")
    text = message |> List.duplicate(repeat) |> Enum.join(" ")
    {:ok, if(mode == :loud, do: String.upcase(text), else: text)}
  end
end

defmodule EchoStdio.Tools.SystemTime do
  @moduledoc "Report the server's current UTC time."

  use Noizu.MCP.Server.Tool,
    name: "system_time",
    description: "Get the server's current UTC time as ISO 8601.",
    annotations: [read_only_hint: true, idempotent_hint: false]

  output do
    field :utc, :string, required: true, description: "ISO 8601 timestamp"
  end

  @impl true
  def call(_args, _ctx) do
    {:ok, %{utc: DateTime.utc_now() |> DateTime.to_iso8601()}}
  end
end

defmodule EchoStdio.MCP do
  @moduledoc "The MCP server: two demo tools over stdio."

  use Noizu.MCP.Server,
    name: "echo_stdio",
    version: "0.1.0",
    instructions: "Demo server. Use `echo` to reflect text and `system_time` for the clock."

  tool EchoStdio.Tools.Echo
  tool EchoStdio.Tools.SystemTime
end
