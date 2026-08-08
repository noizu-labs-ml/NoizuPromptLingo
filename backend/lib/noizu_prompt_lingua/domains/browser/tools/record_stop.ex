defmodule NoizuPromptLingua.Domains.Browser.Tools.RecordStop do
  use Noizu.MCP.Server.Tool,
    name: "Browser.RecordStop",
    description:
      "Stop the in-progress browser recording. The controller finalizes the video and uploads it to object storage; returns the viewable media URL (short_id).",
    category: "Browser",
    annotations: [idempotent_hint: false]

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
  end

  alias NoizuPromptLingua.Domains.Browser
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    Browser.record_stop(Args.get(args, :organization))
  end
end
