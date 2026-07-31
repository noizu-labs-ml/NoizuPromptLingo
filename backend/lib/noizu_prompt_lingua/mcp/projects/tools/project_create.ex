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

    field :owner_id, :string,
      description: "Owner user UUID (defaults to the authenticated caller)"
  end

  @impl true
  def call(args, ctx) do
    org_ref = Args.get(args, :organization)
    owner_id = Args.get(args, :owner_id) || Resolve.current_user_id(ctx)

    with {:owner, owner_id} when is_binary(owner_id) <- {:owner, owner_id},
         {:org, org_id} when not is_nil(org_id) <- {:org, Resolve.organization_id(org_ref)} do
      attrs =
        args
        |> Args.take([:name, :slug, :description])
        |> Map.put(:organization_id, org_id)

      case NoizuPromptLingua.Projects.create_with_owner(attrs, owner_id) do
        {:ok, project} ->
          {:ok,
           %{
             id: project.id,
             name: project.name,
             slug: project.slug,
             status: project.status,
             organization_id: project.organization_id
           }}

        {:error, changeset} when is_struct(changeset, Ecto.Changeset) ->
          {:error, "Failed: #{inspect(changeset.errors)}"}

        {:error, reason} ->
          {:error, "Failed: #{inspect(reason)}"}
      end
    else
      {:owner, _} -> {:error, "owner_id is required and could not be derived from the auth token"}
      {:org, _} -> {:error, "Organization '#{org_ref}' not found"}
    end
  end
end
