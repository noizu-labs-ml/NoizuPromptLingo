defmodule NoizuPromptLingua.Domains.Personas.Tools.PersonaList do
  use Noizu.MCP.Server.Tool, name: "Persona.List",
    description:
      "List personas. With a project, returns the effective list: that project's " <>
      "personas plus org-level (no-project) personas. Without a project, lists all " <>
      "personas in the organization.",
    hidden: true, category: "Personas", annotations: [read_only_hint: true]

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :project, :string, description: "Optional project slug or UUID. When set, org-level personas are included in the effective list."
    field :status, :string, description: "active or archived"
    field :tag, :string
  end

  alias NoizuPromptLingua.Domains.Personas
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    case Resolve.scope(Args.get(args, :organization), Args.get(args, :project)) do
      {:ok, org_id, project_id} ->
        opts =
          [organization_id: org_id]
          |> put_opt(:project_id, project_id)
          |> maybe_effective(project_id)
          |> put_opt(:status, Args.get(args, :status))
          |> put_opt(:tag, Args.get(args, :tag))

        personas = Personas.list(opts)
        {:ok, %{count: length(personas), personas: Enum.map(personas, fn p ->
          %{id: p.id, slug: p.slug, name: p.name, role: p.role, status: p.status,
            tags: p.tags, project_id: p.project_id,
            scope: if(is_nil(p.project_id), do: "org", else: "project")}
        end)}}

      {:error, :org_not_found} -> {:error, "Organization not found"}
      {:error, _} -> {:error, "Invalid project"}
    end
  end

  defp put_opt(opts, _k, nil), do: opts
  defp put_opt(opts, k, v), do: Keyword.put(opts, k, v)

  # When scoped to a project, fold in org-level personas (effective list).
  defp maybe_effective(opts, nil), do: opts
  defp maybe_effective(opts, _project_id), do: Keyword.put(opts, :include_org_level, true)
end
