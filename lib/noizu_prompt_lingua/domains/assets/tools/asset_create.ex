defmodule NoizuPromptLingua.Domains.Assets.Tools.AssetCreate do
  use Noizu.MCP.Server.Tool, name: "Asset.Create",
    description: "Create an asset entry with prompt YAML.", hidden: true, category: "Assets"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "slug" => %{"type" => "string", "description" => "Unique slug"},
      "title" => %{"type" => "string", "description" => "Asset title"},
      "asset_type" => %{"type" => "string", "description" => "image, video, music, voice, component, html, diagram, document, svg, style_guide"},
      "prompt_yaml" => %{"type" => "string", "description" => "Full .media.prompt YAML content"},
      "quality" => %{"type" => "string", "description" => "low, medium, high"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}},
      "product_targets" => %{"type" => "array", "items" => %{"type" => "string"}},
      "project_id" => %{"type" => "string", "description" => "Project UUID"},
      "actor" => %{"type" => "string", "description" => "Creator persona"}
    },
    "required" => ["slug", "title", "asset_type", "prompt_yaml"]
  }

  alias NoizuPromptLingua.Domains.Assets

  @impl true
  def call(args, _ctx) do
    attrs = %{slug: args["slug"], title: args["title"], asset_type: args["asset_type"],
              prompt_yaml: args["prompt_yaml"], quality: args["quality"], tags: args["tags"],
              product_targets: args["product_targets"], project_id: args["project_id"]}
    case Assets.create(attrs, actor: args["actor"]) do
      {:ok, e} -> {:ok, %{id: e.id, slug: e.slug, title: e.title, asset_type: e.asset_type, status: e.status}}
      {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
    end
  end
end
