defmodule NoizuPromptLingua.Domains.Wiki.Tools.SpaceCreate do
  use Noizu.MCP.Server.Tool,
    name: "Wiki.SpaceCreate",
    description: "Create a wiki space in an organization (optionally scoped to a project).",
    hidden: true,
    category: "Wiki"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :name, :string, required: true, description: "Space name"
    field :slug, :string, description: "URL slug (auto-derived from name when omitted)"
    field :description, :string, description: "Space description"
    field :project, :string, description: "Optional project slug or UUID to scope this space to"
  end

  alias NoizuPromptLingua.Domains.Wiki
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)
    project_ref = Args.get(args, :project)

    with {:org, org_id} when not is_nil(org_id) <- {:org, Resolve.organization_id(org_ref)},
         {:ok, project_id} <- Resolve.project_in_org(project_ref, org_id) do
      attrs = %{
        organization_id: org_id,
        project_id: project_id,
        name: Args.get(args, :name),
        slug: Args.get(args, :slug),
        description: Args.get(args, :description)
      }

      case Wiki.create_space(attrs) do
        {:ok, space} ->
          {:ok, %{id: space.id, slug: space.slug, name: space.name, organization_id: space.organization_id, project_id: space.project_id}}

        {:error, changeset} ->
          {:error, "Failed: #{inspect(changeset.errors)}"}
      end
    else
      {:org, nil} -> {:error, "Organization '#{org_ref}' not found"}
      {:error, :project_not_found} -> {:error, "Project '#{project_ref}' not found"}
      {:error, :project_not_in_org} -> {:error, "Project '#{project_ref}' does not belong to this organization"}
    end
  end
end
