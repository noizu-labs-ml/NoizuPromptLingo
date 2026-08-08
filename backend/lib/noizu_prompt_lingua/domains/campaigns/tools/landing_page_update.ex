defmodule NoizuPromptLingua.Domains.Campaigns.Tools.LandingPageUpdate do
  use Noizu.MCP.Server.Tool,
    name: "LandingPage.Update",
    description: "Update fields on a landing page.",
    hidden: true,
    category: "Campaigns.LandingPages"

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "id" => %{"type" => "string", "description" => "Landing page UUID"},
      "title" => %{"type" => "string", "description" => "Title"},
      "path" => %{"type" => "string", "description" => "URL path"},
      "headline" => %{"type" => "string", "description" => "Hero headline"},
      "campaign_id" => %{"type" => "string", "description" => "Campaign UUID"},
      "domain_name_id" => %{"type" => "string", "description" => "Domain name UUID"},
      "status" => %{"type" => "string", "description" => "draft, generating, published, archived"},
      "metadata" => %{"type" => "object", "description" => "Metadata"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Tags"}
    },
    "required" => ["id"]
  })

  alias NoizuPromptLingua.Domains.Campaigns
  alias NoizuPromptLingua.MCP.Args

  @fields ~w(title path headline campaign_id domain_name_id status metadata tags)a

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :id)

    case Campaigns.update_landing_page(id, Args.take(args, @fields)) do
      {:ok, p} -> {:ok, %{id: p.id, slug: p.slug, title: p.title, status: p.status}}
      {:error, :not_found} -> {:error, "Landing page '#{id}' not found"}
      {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end
end
