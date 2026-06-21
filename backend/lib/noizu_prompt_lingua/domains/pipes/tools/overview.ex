defmodule NoizuPromptLingua.Domains.Pipes.Tools.Overview do
  use Noizu.MCP.Server.Tool,
    name: "Pipe.Overview",
    description: "List the agent-pipe tools and current entry count for an organization.",
    annotations: [read_only_hint: true],
    category: "Pipes"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
  end

  alias NoizuPromptLingua.Domains.Pipes
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)

    case Resolve.organization_id(org_ref) do
      nil ->
        {:error, "Organization '#{org_ref}' not found"}

      org_id ->
        {:ok, %{
          domain: "Pipes",
          subdomain: "pipes.tobor.locker",
          organization_id: org_id,
          stats: Pipes.stats(org_id),
          tools: [
            %{name: "Pipe.Output", description: "Publish a payload under a message name to an agent/group/broadcast"},
            %{name: "Pipe.Input", description: "Pull messages addressed to an agent handle"}
          ]
        }}
    end
  end
end
