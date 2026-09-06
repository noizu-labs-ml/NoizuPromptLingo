alias NoizuPromptLingua.MCPCustomScopes
alias NoizuPromptLingua.MCP.UrlToolsetParam
alias NoizuPromptLingua.MCP.EffectiveToolset
alias Noizu.MCP.Ctx

slug = "dbg-param-#{System.unique_integer([:positive])}"

{:ok, scope} =
  MCPCustomScopes.create(%{
    "slug" => slug,
    "name" => "Dbg",
    "kind" => "custom",
    "config" => %{"groups" => %{"tickets" => %{"tools" => %{"Ticket.Get" => %{"disabled" => true}}}}}
  })

{:ok, layer} =
  UrlToolsetParam.compile(%{"tools" => %{"Ticket_Get" => %{"visible" => true}}}, scope)

IO.inspect(get_in(layer, ["groups", "tickets", "tools", "Ticket_Get"]), label: "layer entry")

ctx = %Ctx{server: NoizuPromptLingua.MCP, assigns: %{custom_scope_slug: slug, toolset_param_cfg: layer}}
client = EffectiveToolset.param_only_client(ctx)

states = EffectiveToolset.resolve(scope, client, nil)
IO.inspect(EffectiveToolset.lookup(states, "Ticket.Get"), label: "Ticket.Get state")
IO.inspect(EffectiveToolset.lookup(states, "Ticket.List"), label: "Ticket.List state")
