defmodule NoizuPromptLingua.MCP.Organizations.Tools.OrganizationCreate do
  use Noizu.MCP.Server.Tool,
    name: "Organization.Create",
    description: "Create a new organization owned by the given user.",
    hidden: true,
    category: "Organizations"

  alias NoizuPromptLingua.MCP.Args

  input do
    field :name, :string, required: true, description: "Organization name"
    field :slug, :string, required: true, description: "Unique URL slug"
    field :owner_id, :string, required: true, description: "Owner user UUID"
  end

  @impl true
  def call(args, _ctx) do
    owner_id = Args.get(args, :owner_id)
    attrs = Args.take(args, [:name, :slug])

    case NoizuPromptLingua.Organizations.create_organization_with_owner(attrs, owner_id) do
      {:ok, org} ->
        {:ok, %{id: org.id, name: org.name, slug: org.slug}}

      {:error, changeset} when is_struct(changeset, Ecto.Changeset) ->
        {:error, "Failed: #{inspect(changeset.errors)}"}

      {:error, reason} ->
        {:error, "Failed: #{inspect(reason)}"}
    end
  end
end
