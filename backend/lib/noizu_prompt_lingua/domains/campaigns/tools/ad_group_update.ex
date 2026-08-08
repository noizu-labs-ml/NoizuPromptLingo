defmodule NoizuPromptLingua.Domains.Campaigns.Tools.AdGroupUpdate do
  use Noizu.MCP.Server.Tool,
    name: "AdGroup.Update",
    description: "Update fields on an ad group.",
    hidden: true,
    category: "Campaigns.AdGroups"

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "id" => %{"type" => "string", "description" => "Ad group UUID"},
      "name" => %{"type" => "string", "description" => "Name"},
      "theme" => %{"type" => "string", "description" => "Theme"},
      "keywords" => %{
        "type" => "array",
        "items" => %{"type" => "string"},
        "description" => "Keyword terms"
      },
      "bid_cents" => %{"type" => "integer", "description" => "Default bid in cents"},
      "status" => %{"type" => "string", "description" => "active, paused, archived"},
      "metadata" => %{"type" => "object", "description" => "Metadata"}
    },
    "required" => ["id"]
  })

  alias NoizuPromptLingua.Domains.Campaigns
  alias NoizuPromptLingua.MCP.Args

  @fields ~w(name theme keywords bid_cents status metadata)a

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :id)

    case Campaigns.update_ad_group(id, Args.take(args, @fields)) do
      {:ok, g} -> {:ok, %{id: g.id, slug: g.slug, name: g.name, status: g.status}}
      {:error, :not_found} -> {:error, "Ad group '#{id}' not found"}
      {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end
end
