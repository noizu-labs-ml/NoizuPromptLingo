defmodule NoizuPromptLingua.MCP.Clients.Tools.Overview do
  use Noizu.MCP.Server.Tool,
    name: "Clients.Overview",
    description: "Describe the Clients domain (customers under an organization).",
    category: "Clients",
    annotations: [read_only_hint: true]

  @impl true
  def call(_args, _ctx) do
    {:ok,
     %{
       domain: "clients",
       summary:
         "Clients are external customers/billable parties under an Organization. " <>
           "They are not Organizations (tenants). Projects may optionally nest under a Client. " <>
           "Data lives in pm_core and is shared with therobotplans. " <>
           "external_ids is reserved for Stopwatch/Timely linkage.",
       tools: ~w(Client.Create Client.Get Client.List Client.Update Clients.Overview)
     }}
  end
end
