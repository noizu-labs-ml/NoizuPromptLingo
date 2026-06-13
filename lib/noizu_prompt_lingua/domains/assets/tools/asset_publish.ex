defmodule NoizuPromptLingua.Domains.Assets.Tools.AssetPublish do
  use Noizu.MCP.Server.Tool, name: "Asset.Publish",
    description: "Set asset status to published.", hidden: true, category: "Assets"

  input do
    field :asset, :string, required: true, description: "Slug or UUID"
    field :actor, :string, description: "Actor persona"
  end

  alias NoizuPromptLingua.Domains.Assets

  @impl true
  def call(args, _ctx) do
    key = args[:asset] || args["asset"]
    case Assets.publish(key, actor: args[:actor] || args["actor"]) do
      {:ok, e} -> {:ok, %{id: e.id, slug: e.slug, status: "published"}}
      {:error, :not_found} -> {:error, "Asset not found"}
    end
  end
end
