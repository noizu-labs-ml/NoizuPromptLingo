defmodule NoizuPromptLingua.Domains.Assets.Tools.AssetCreate do
  use Noizu.MCP.Server.Tool,
    name: "Asset.Create",
    description: "Create an asset entry with prompt YAML.",
    hidden: true,
    category: "Assets"

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "organization" => %{
        "type" => "string",
        "description" => "Organization slug or UUID (required)"
      },
      "project" => %{"type" => "string", "description" => "Optional project slug or UUID"},
      "slug" => %{"type" => "string", "description" => "Slug, unique within the organization"},
      "title" => %{"type" => "string", "description" => "Asset title"},
      "asset_type" => %{
        "type" => "string",
        "description" =>
          "image, video, music, voice, component, html, diagram, document, svg, style_guide"
      },
      "prompt_yaml" => %{"type" => "string", "description" => "Full .media.prompt YAML content"},
      "quality" => %{"type" => "string", "description" => "low, medium, high"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}},
      "product_targets" => %{"type" => "array", "items" => %{"type" => "string"}},
      "actor" => %{"type" => "string", "description" => "Creator persona"}
    },
    "required" => ["organization", "slug", "title", "asset_type", "prompt_yaml"]
  })

  alias NoizuPromptLingua.Domains.Assets
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    case Resolve.scope(Args.get(args, :organization), Args.get(args, :project)) do
      {:ok, org_id, project_id} ->
        attrs = %{
          organization_id: org_id,
          project_id: project_id,
          slug: args["slug"],
          title: args["title"],
          asset_type: args["asset_type"],
          prompt_yaml: args["prompt_yaml"],
          quality: args["quality"],
          tags: args["tags"],
          product_targets: args["product_targets"]
        }

        case Assets.create(attrs, actor: args["actor"]) do
          {:ok, e} ->
            {:ok,
             %{id: e.id, slug: e.slug, title: e.title, asset_type: e.asset_type, status: e.status}}

          {:error, cs} ->
            {:error, "Failed: #{inspect(cs.errors)}"}
        end

      {:error, :org_not_found} ->
        {:error, "Organization not found"}

      {:error, :project_not_found} ->
        {:error, "Project not found"}

      {:error, :project_not_in_org} ->
        {:error, "Project does not belong to this organization"}
    end
  end
end
