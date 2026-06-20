defmodule NoizuPromptLingua.MCP.Projects.Tools.ProjectCreate do
  use Noizu.MCP.Server.Tool,
    name: "Project.Create",
    description: "Create a new project within an organization, owned by the given user.",
    hidden: true,
    category: "Projects"

  alias NoizuPromptLingua.MCP.{Args, Resolve}

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :name, :string, required: true, description: "Project name"
    field :slug, :string, required: true, description: "Unique URL slug (within the org)"
    field :description, :string, description: "Project description"
    field :owner_id, :string, required: true, description: "Owner user UUID"
  end

  @impl true
  def call(args, _ctx) do
    owner_id = Args.get(args, :owner_id)

    case Resolve.organization_id(Args.get(args, :organization)) do
      nil ->
        {:error, "Organization '#{Args.get(args, :organization)}' not found"}

      org_id ->
        attrs =
          args
          |> Args.take([:name, :slug, :description])
          |> Map.put(:organization_id, org_id)

        case NoizuPromptLingua.Projects.create_with_owner(attrs, owner_id) do
          {:ok, project} ->
            {:ok, %{id: project.id, name: project.name, slug: project.slug, status: project.status, organization_id: project.organization_id}}

          {:error, changeset} when is_struct(changeset, Ecto.Changeset) ->
            {:error, "Failed: #{inspect(changeset.errors)}"}

          {:error, reason} ->
            {:error, "Failed: #{inspect(reason)}"}
        end
    end
  end
end
