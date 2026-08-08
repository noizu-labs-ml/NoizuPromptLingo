defmodule NoizuPromptLingua.Domains.Assets.Tools.AssetUpdate do
  use Noizu.MCP.Server.Tool,
    name: "Asset.Update",
    description: "Update prompt YAML, title, tags, quality.",
    hidden: true,
    category: "Assets"

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "asset" => %{"type" => "string", "description" => "Slug or UUID"},
      "title" => %{"type" => "string"},
      "prompt_yaml" => %{"type" => "string"},
      "quality" => %{"type" => "string"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}},
      "product_targets" => %{"type" => "array", "items" => %{"type" => "string"}},
      "actor" => %{"type" => "string"}
    },
    "required" => ["asset"]
  })

  alias NoizuPromptLingua.Domains.Assets

  @impl true
  def call(args, _ctx) do
    key = args["asset"]

    attrs =
      Enum.reduce(~w(title prompt_yaml quality tags product_targets), %{}, fn k, acc ->
        if v = args[k], do: Map.put(acc, String.to_atom(k), v), else: acc
      end)

    case Assets.update(key, attrs, actor: args["actor"]) do
      {:ok, e} -> {:ok, %{id: e.id, slug: e.slug, title: e.title, status: e.status}}
      {:error, :not_found} -> {:error, "Asset not found"}
      {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
    end
  end
end
