defmodule NoizuPromptLingua.Domains.Market.Tools.CompetitorUpdate do
  use Noizu.MCP.Server.Tool,
    name: "Competitor.Update",
    description: "Update fields on a competitor.",
    hidden: true,
    category: "Market.Competitors"

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "id" => %{"type" => "string", "description" => "Competitor UUID"},
      "name" => %{"type" => "string", "description" => "Name"},
      "website" => %{"type" => "string", "description" => "Website"},
      "description" => %{"type" => "string", "description" => "Description"},
      "tier" => %{"type" => "string", "description" => "direct, indirect, or aspirational"},
      "strengths" => %{
        "type" => "array",
        "items" => %{"type" => "string"},
        "description" => "Strengths"
      },
      "weaknesses" => %{
        "type" => "array",
        "items" => %{"type" => "string"},
        "description" => "Weaknesses"
      },
      "metadata" => %{"type" => "object", "description" => "Metadata"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Tags"},
      "status" => %{"type" => "string", "description" => "active or archived"}
    },
    "required" => ["id"]
  })

  alias NoizuPromptLingua.Domains.Market
  alias NoizuPromptLingua.MCP.Args

  @fields ~w(name website description tier strengths weaknesses metadata tags status)a

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :id)

    case Market.update_competitor(id, Args.take(args, @fields)) do
      {:ok, c} -> {:ok, %{id: c.id, slug: c.slug, name: c.name, status: c.status}}
      {:error, :not_found} -> {:error, "Competitor '#{id}' not found"}
      {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end
end
