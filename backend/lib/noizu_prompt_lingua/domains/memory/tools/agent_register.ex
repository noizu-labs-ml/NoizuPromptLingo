defmodule NoizuPromptLingua.Domains.Memory.Tools.AgentRegister do
  @moduledoc false
  use Noizu.MCP.Server.Tool,
    name: "Memory.AgentRegister",
    description:
      "Register a memory-owning agent identity (the weego orchestrator or a team-member sub-agent). " <>
        "`call_sign` is optional — a memorable one is generated if omitted. Personas are NOT registered " <>
        "here (they own memory directly).",
    category: "Memory.Agents"

  input do
    field :organization, :string,
      required: true,
      description: "Organization slug or UUID (required)"

    field :kind, :string, required: true, description: "weego | team_member"

    field :call_sign, :string,
      description: "Desired call sign (unique per org); auto-generated if omitted"

    field :display_name, :string, description: "Human-readable label"
    field :persona, :string, description: "Optional persona slug/uuid to link this agent to"
  end

  alias NoizuPromptLingua.MCP.{Args, Resolve}
  alias NoizuPromptLingua.Domains.{Personas}
  alias NoizuPromptLingua.Domains.Memory.Agents

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)
    kind = Args.get(args, :kind)

    with {:org, org_id} when not is_nil(org_id) <- {:org, Resolve.organization_id(org_ref)},
         {:kind, k} when k in [:weego, :team_member] <- {:kind, parse_kind(kind)} do
      persona_id =
        case Args.get(args, :persona) do
          nil ->
            nil

          ref ->
            case Personas.resolve(org_id, ref) do
              nil -> nil
              p -> p.id
            end
        end

      opts = [
        call_sign: Args.get(args, :call_sign),
        display_name: Args.get(args, :display_name),
        persona_id: persona_id
      ]

      case Agents.register(org_id, k, opts) do
        {:ok, cs} ->
          {:ok,
           %{
             id: cs.id,
             call_sign: cs.call_sign,
             kind: to_string(cs.kind),
             organization_id: cs.organization_id
           }}

        {:error, changeset} ->
          {:error, "register failed: #{inspect(changeset.errors)}"}
      end
    else
      {:org, nil} -> {:error, "Organization '#{org_ref}' not found"}
      {:kind, _} -> {:error, "kind must be weego | team_member"}
    end
  end

  defp parse_kind("weego"), do: :weego
  defp parse_kind("team_member"), do: :team_member
  defp parse_kind(_), do: :invalid
end
