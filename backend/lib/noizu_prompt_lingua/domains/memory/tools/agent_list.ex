defmodule NoizuPromptLingua.Domains.Memory.Tools.AgentList do
  @moduledoc false
  use Noizu.MCP.Server.Tool,
    name: "Memory.AgentList",
    description: "List the registered agent identities (weego / team_member call signs) for an organization.",
    annotations: [read_only_hint: true],
    category: "Memory.Agents"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID (required)"
    field :kind, :string, description: "Filter by kind: weego | team_member"
  end

  alias NoizuPromptLingua.MCP.{Args, Resolve}
  alias NoizuPromptLingua.Domains.Memory.Agents

  @impl true
  def call(args, _ctx) do
    case Resolve.organization_id(Args.get(args, :organization)) do
      nil ->
        {:error, "Organization '#{Args.get(args, :organization)}' not found"}

      org_id ->
        kind = parse_kind(Args.get(args, :kind))
        agents = Agents.list(org_id, kind: kind, status: "active")

        {:ok,
         %{
           count: length(agents),
           agents:
             Enum.map(agents, fn a ->
               %{id: a.id, call_sign: a.call_sign, kind: to_string(a.kind), display_name: a.display_name, persona_id: a.persona_id}
             end)
         }}
    end
  end

  defp parse_kind("weego"), do: :weego
  defp parse_kind("team_member"), do: :team_member
  defp parse_kind(_), do: nil
end
