defmodule NoizuPromptLingua.MCP.Sessions.Tools.Manifest do
  use Noizu.MCP.Server.Tool,
    name: "Session_Manifest",
    description:
      "Session manifest — list every registered MCP method with its effective state " <>
        "for the calling client: enabled (execution), visible (discovery) and " <>
        "expires_at. Names are canonical underscore form; absent entries are " <>
        "enabled and visible by default.",
    annotations: [read_only_hint: true],
    category: "Sessions"

  @impl true
  def call(_args, ctx) do
    {:ok, NoizuPromptLingua.MCP.SessionManifest.generate(ctx)}
  end
end
