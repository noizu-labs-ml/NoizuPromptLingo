defmodule NoizuPromptLingua.Domains.Browser.Tools.RecordStart do
  use Noizu.MCP.Server.Tool,
    name: "Browser.RecordStart",
    description:
      "Start recording a video of the connected browser session. Call Browser.RecordStop to finalize; the video is uploaded to object storage and appears in the org's browser gallery.",
    category: "Browser",
    annotations: [idempotent_hint: false]

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
  end

  alias NoizuPromptLingua.Domains.Browser
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    Browser.record_start(Args.get(args, :organization))
  end
end
