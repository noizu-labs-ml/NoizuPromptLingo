defmodule HttpKitchenSink.Tools.Echo do
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
    Noizu.MCP.Ctx.report_progress(ctx, 0.5, total: 1, message: "echoing")
    text = message |> List.duplicate(repeat) |> Enum.join(" ")
    {:ok, if(mode == :loud, do: String.upcase(text), else: text)}
  end
end

defmodule HttpKitchenSink.Tools.LongTask do
  @moduledoc """
  A slow tool that streams progress notifications and cooperates with
  client-side cancellation via `Noizu.MCP.Ctx.cancelled?/1`.

  Over Streamable HTTP, the first progress notification upgrades the POST
  response to an SSE stream; the final JSON-RPC result arrives as the last
  SSE event.
  """

  use Noizu.MCP.Server.Tool,
    name: "long_task",
    description: "Run a ~2s job in 4 steps, reporting progress along the way."

  @steps 4
  @step_ms 500

  @impl true
  def call(_args, ctx) do
    Enum.reduce_while(1..@steps, {:ok, "done in #{@steps} steps"}, fn step, acc ->
      if Noizu.MCP.Ctx.cancelled?(ctx) do
        {:halt, {:ok, "cancelled after #{step - 1} steps"}}
      else
        Process.sleep(@step_ms)
        Noizu.MCP.Ctx.report_progress(ctx, step, total: @steps, message: "step #{step}/#{@steps}")
        {:cont, acc}
      end
    end)
  end
end

defmodule HttpKitchenSink.Tools.ConsultLLM do
  @moduledoc """
  Demonstrates server -> client sampling (`sampling/createMessage`) from
  inside a tool call. When the connected client did not advertise the
  `sampling` capability, this degrades gracefully into an `isError: true`
  tool result instead of a protocol error.
  """

  use Noizu.MCP.Server.Tool,
    name: "consult_llm",
    description: "Ask the connected client's LLM a question via MCP sampling."

  input do
    field :question, :string, required: true, description: "Question for the client's LLM"
  end

  @impl true
  def call(%{question: question}, ctx) do
    params = %{
      "messages" => [
        %{"role" => "user", "content" => %{"type" => "text", "text" => question}}
      ],
      "maxTokens" => 200
    }

    case Noizu.MCP.Ctx.sample(ctx, params, timeout: 30_000) do
      {:ok, result} ->
        {:ok, "The client's #{result["model"] || "LLM"} says: #{result["content"]["text"]}"}

      {:error, :capability_not_supported} ->
        # `{:error, text}` becomes an isError: true tool result, visible to
        # the model rather than failing the JSON-RPC request.
        {:error, "This client does not support MCP sampling; consult_llm is unavailable."}

      {:error, reason} ->
        {:error, "Sampling failed: #{inspect(reason)}"}
    end
  end
end
