defmodule NoizuPromptLingua.Domains.Wiki.Tools.CreateSpace do
  use Noizu.MCP.Server.Tool, name: "Wiki.CreateSpace",
    description: "Create a wiki namespace.", hidden: true, category: "Wiki"

  input do
    field :slug, :string, required: true, description: "Unique space identifier"
    field :name, :string, required: true, description: "Display name"
    field :description, :string, description: "Space description"
  end

  alias NoizuPromptLingua.Domains.Wiki

  @impl true
  def call(args, _ctx) do
    attrs = %{slug: args[:slug] || args["slug"], name: args[:name] || args["name"], description: args[:description] || args["description"]}
    case Wiki.create_space(attrs) do
      {:ok, s} -> {:ok, %{id: s.id, slug: s.slug, name: s.name, created_at: s.inserted_at}}
      {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
    end
  end
end
