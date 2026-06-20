defmodule NoizuPromptLingua.Domains.Assets.Tools.AssetArchive do
  use Noizu.MCP.Server.Tool, name: "Asset.Archive",
    description: "Archive an asset entry.", hidden: true, category: "Assets"

  input do
    field :asset, :string, required: true, description: "Slug or UUID"
    field :actor, :string, description: "Actor persona"
  end

  alias NoizuPromptLingua.Domains.Assets

  @impl true
  def call(args, _ctx) do
    key = args[:asset] || args["asset"]
    case Assets.archive(key, actor: args[:actor] || args["actor"]) do
      {:ok, e} -> {:ok, %{id: e.id, slug: e.slug, status: "archived"}}
      {:error, :not_found} -> {:error, "Asset not found"}
    end
  end
end
