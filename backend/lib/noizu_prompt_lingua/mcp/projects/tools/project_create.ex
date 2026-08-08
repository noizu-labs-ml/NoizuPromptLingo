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

    field :client, :string,
      description: "Optional client slug or UUID under the organization"

    field :owner_id, :string,
      description: "Owner user UUID (defaults to the authenticated caller)"
  end

  @impl true
  def call(args, ctx) do
    org_ref = Args.get(args, :organization)
    client_ref = Args.get(args, :client)
    slug = Args.get(args, :slug)
    owner_id = Args.get(args, :owner_id) || Resolve.current_user_id(ctx)

    with {:owner, owner_id} when is_binary(owner_id) <- {:owner, owner_id},
         {:org, org_id} when not is_nil(org_id) <- {:org, Resolve.organization_id(org_ref)},
         {:client, client_id} <- resolve_client(org_id, client_ref) do
      attrs =
        args
        |> Args.take([:name, :slug, :description])
        |> Map.put(:organization_id, org_id)
        |> then(fn m -> if client_id, do: Map.put(m, :client_id, client_id), else: m end)

      case NoizuPromptLingua.Projects.create_with_owner(attrs, owner_id) do
        {:ok, project} ->
          {:ok,
           %{
             id: project.id,
             name: project.name,
             slug: project.slug,
             status: project.status,
             organization_id: project.organization_id,
             client_id: Map.get(project, :client_id)
           }}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:error, format_create_error(changeset, slug)}

        {:error, reason} ->
          {:error, "Failed to create project: #{inspect(reason)}"}
      end
    else
      {:owner, _} -> {:error, "owner_id is required and could not be derived from the auth token"}
      {:org, _} -> {:error, "Organization '#{org_ref}' not found"}
      {:client, :not_found} -> {:error, "Client '#{client_ref}' not found in organization"}
    end
  rescue
    e in [Ecto.ConstraintError, Postgrex.Error] ->
      {:error, "Failed to create project: #{Exception.message(e)}"}

    e ->
      {:error, "Project.Create exception: #{Exception.message(e)}"}
  catch
    kind, reason ->
      {:error, "Project.Create #{kind}: #{inspect(reason)}"}
  end

  defp format_create_error(%Ecto.Changeset{} = cs, slug) do
    cond do
      Keyword.has_key?(cs.errors, :slug) ->
        "Project slug '#{slug}' already exists in this organization"

      true ->
        "Failed to create project: #{inspect(cs.errors)}"
    end
  end

  defp resolve_client(_org_id, nil), do: {:client, nil}
  defp resolve_client(_org_id, ""), do: {:client, nil}

  defp resolve_client(org_id, client_ref) do
    case NoizuPromptLingua.Clients.resolve(org_id, client_ref) do
      nil -> {:client, :not_found}
      c -> {:client, c.id}
    end
  end
end
