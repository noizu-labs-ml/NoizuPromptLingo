defmodule HttpKitchenSink.Toolkit do
  @moduledoc """
  Several small tools in one module via `@mcp` annotations
  (`Noizu.MCP.Server.Toolkit`).

  Demonstrates the data-form input spec (validated, atom-keyed args), the
  raw JSON-text schema form (string-keyed args), per-tool `category:`
  overriding the toolkit default, and a hidden tool (`visible: false`) that
  stays callable by name and is discoverable through the `catalog` tool.
  """

  use Noizu.MCP.Server.Toolkit, category: "Utility"

  @mcp name: "util.reverse",
       description: "Reverse a string.",
       input: [text: [type: :string, required: true, description: "Text to reverse"]],
       annotations: [read_only_hint: true]
  def reverse(%{text: text}, _ctx), do: {:ok, String.reverse(text)}

  @mcp category: "Time",
       description: "Current UTC time, ISO 8601. Takes no arguments."
  def server_time, do: {:ok, DateTime.utc_now() |> DateTime.to_iso8601()}

  # Hidden from tools/list (still callable; listed by the `catalog` tool).
  # JSON-text schemas are decoded at compile time; args arrive string-keyed.
  @mcp visible: false
  @mcp name: "util.checksum",
       description: "SHA-256 of the given text, hex-encoded.",
       input: """
       {"type": "object", "properties": {"text": {"type": "string"}}, "required": ["text"]}
       """
  def checksum(args, _ctx) do
    {:ok, :crypto.hash(:sha256, args["text"]) |> Base.encode16(case: :lower)}
  end
end
