defmodule NoizuPromptLingua.Domains.Browser.Tools.Overview do
  use Noizu.MCP.Server.Tool,
    name: "Browser.Overview",
    description:
      "List browser-control tools and report whether a local controller is currently connected for the organization.",
    annotations: [read_only_hint: true],
    category: "Browser"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
  end

  alias NoizuPromptLingua.Domains.Browser
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)

    case Resolve.organization_id(org_ref) do
      nil ->
        {:error, "Organization '#{org_ref}' not found"}

      org_id ->
        {:ok,
         %{
           domain: "Browser",
           subdomain: "browser.tobor.locker",
           organization_id: org_id,
           controller_connected: Browser.connected?(org_ref),
           tools: [
             %{name: "Browser.Overview", description: "List tools + controller connection status"},
             %{name: "Browser.Navigate", description: "Navigate the browser to a URL"},
             %{name: "Browser.Screenshot", description: "Capture a screenshot → uploaded to media gallery"},
             %{name: "Browser.Click", description: "Click an element by selector"},
             %{name: "Browser.Fill", description: "Fill an input by selector"},
             %{name: "Browser.GetState", description: "Get current url, title, and optional text"},
             %{name: "Browser.RecordStart", description: "Begin recording a session video"},
             %{name: "Browser.RecordStop", description: "Stop recording → uploaded to media gallery"}
           ]
         }}
    end
  end
end
