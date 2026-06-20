defmodule NoizuPromptLingua.MCP.Organizations.Tools.OrganizationUpdate do
  use Noizu.MCP.Server.Tool,
    name: "Organization.Update",
    description: "Update an organization's name or slug.",
    hidden: true,
    category: "Organizations"

  alias NoizuPromptLingua.MCP.{Args, Resolve}

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :name, :string, description: "New name"
    field :slug, :string, description: "New slug"
  end

  @impl true
  def call(args, _ctx) do
    ref = Args.get(args, :organization)
    attrs = Args.take(args, [:name, :slug])

    case Resolve.organization_id(ref) do
      nil ->
        {:error, "Organization '#{ref}' not found"}

      id ->
        case NoizuPromptLingua.Organizations.update_organization(id, attrs) do
          {:ok, org} -> {:ok, %{id: org.id, name: org.name, slug: org.slug}}
          {:error, :not_found} -> {:error, "Organization '#{ref}' not found"}
          {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
        end
    end
  end
end
