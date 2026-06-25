defmodule NoizuPromptLingua.Domains.Memory.Tools.Scope do
  @moduledoc """
  Shared helper: resolve the common MCP tool args (`organization`, `scope_type`, `agent`) into a
  memory engine `context` map `%{organization_id, scope_type, scope_id, requester_id, source_agent}`.

  `scope_type` is `persona | weego | team_member`. `agent` is a persona slug/uuid (persona scope),
  a call sign / uuid (weego/team_member), or omitted for the org's weego.
  """
  alias NoizuPromptLingua.MCP.{Args, Resolve}
  alias NoizuPromptLingua.Domains.Memory.Agents

  @valid ~w(persona weego team_member)

  @spec resolve(map()) :: {:ok, map()} | {:error, String.t()}
  def resolve(args) do
    org_ref = Args.get(args, :organization)
    st = Args.get(args, :scope_type)
    agent_ref = Args.get(args, :agent)

    with {:org, org_id} when not is_nil(org_id) <- {:org, Resolve.organization_id(org_ref)},
         {:type, {:ok, scope_type}} <- {:type, parse_type(st)},
         {:scope, {:ok, scope}} <- {:scope, Agents.resolve_scope(org_id, scope_type, agent_ref)} do
      {:ok, Map.merge(scope, %{requester_id: to_string(scope.scope_id), source_agent: "mcp"})}
    else
      {:org, nil} -> {:error, "Organization '#{org_ref}' not found"}
      {:type, _} -> {:error, "scope_type must be one of: #{Enum.join(@valid, " | ")}"}
      {:scope, {:error, :persona_not_found}} -> {:error, "Persona '#{agent_ref}' not found"}
      {:scope, {:error, :agent_not_found}} -> {:error, "Agent '#{agent_ref}' not found in this org"}
      {:scope, other} -> {:error, "scope resolution failed: #{inspect(other)}"}
    end
  end

  defp parse_type(t) when t in @valid, do: {:ok, String.to_atom(t)}
  defp parse_type(_), do: :error

  @doc "Serialize a memory row to a plain map for tool results."
  def memory_view(m) do
    %{
      id: m.id,
      content: m.content,
      context: m.context,
      reflection: m.reflection,
      tangent: m.tangent,
      summary: m.summary,
      domain: m.domain,
      topic: m.topic,
      content_type: m.content_type && to_string(m.content_type),
      occurred_at: m.occurred_at && DateTime.to_iso8601(m.occurred_at),
      mood: %{valence: m.valence, arousal: m.arousal, dominance: m.dominance},
      hormones: %{cortisol: m.cortisol, dopamine: m.dopamine, oxytocin: m.oxytocin, serotonin: m.serotonin},
      salience: m.salience,
      decay_weight: m.decay_weight,
      recall_count: m.recall_count,
      resonance: Map.get(m, :resonance)
    }
  end
end
