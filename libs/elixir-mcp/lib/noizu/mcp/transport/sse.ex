defmodule Noizu.MCP.Transport.SSE do
  @moduledoc """
  Minimal Server-Sent Events codec used by the Streamable HTTP transport.
  Encoder for the server side, incremental parser for the client side.
  """

  defmodule Event do
    @moduledoc "A parsed server-sent event."
    @type t :: %__MODULE__{
            id: String.t() | nil,
            event: String.t() | nil,
            data: String.t(),
            retry: integer() | nil
          }
    defstruct [:id, :event, :retry, data: ""]
  end

  @doc "Encode one SSE event as iodata."
  @spec encode(String.t() | iodata(), keyword()) :: iodata()
  def encode(data, opts \\ []) do
    data_lines =
      data
      |> IO.iodata_to_binary()
      |> String.split("\n")
      |> Enum.map(&["data: ", &1, "\n"])

    [
      if(opts[:id], do: ["id: ", to_string(opts[:id]), "\n"], else: []),
      if(opts[:event], do: ["event: ", opts[:event], "\n"], else: []),
      if(opts[:retry], do: ["retry: ", Integer.to_string(opts[:retry]), "\n"], else: []),
      data_lines,
      "\n"
    ]
  end

  @doc """
  Incremental parse: feed a chunk plus the leftover buffer, get completed
  events and the new buffer. Multi-line `data:` fields are joined per spec.
  """
  @spec parse(binary(), binary()) :: {[Event.t()], binary()}
  def parse(buffer, chunk) do
    data = buffer <> chunk

    # Events are terminated by a blank line. Keep the trailing partial event
    # (no terminator yet) in the buffer.
    parts = String.split(data, ~r/\r?\n\r?\n/)
    {complete, [rest]} = Enum.split(parts, -1)

    events =
      complete
      |> Enum.map(&parse_event/1)
      |> Enum.reject(&is_nil/1)

    {events, rest}
  end

  defp parse_event(block) do
    fields =
      block
      |> String.split(~r/\r?\n/)
      |> Enum.reduce(%{data: []}, fn line, acc ->
        case line do
          ":" <> _comment -> acc
          "data:" <> value -> Map.update!(acc, :data, &[String.trim_leading(value, " ") | &1])
          "data" -> Map.update!(acc, :data, &["" | &1])
          "id:" <> value -> Map.put(acc, :id, String.trim_leading(value, " "))
          "event:" <> value -> Map.put(acc, :event, String.trim_leading(value, " "))
          "retry:" <> value -> parse_retry(acc, value)
          _other -> acc
        end
      end)

    case fields.data do
      [] ->
        nil

      data ->
        %Event{
          id: fields[:id],
          event: fields[:event],
          retry: fields[:retry],
          data: data |> Enum.reverse() |> Enum.join("\n")
        }
    end
  end

  defp parse_retry(acc, value) do
    case Integer.parse(String.trim(value)) do
      {retry, ""} -> Map.put(acc, :retry, retry)
      _ -> acc
    end
  end
end
