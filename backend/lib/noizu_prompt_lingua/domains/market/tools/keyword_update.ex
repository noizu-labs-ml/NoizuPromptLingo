defmodule NoizuPromptLingua.Domains.Market.Tools.KeywordUpdate do
  use Noizu.MCP.Server.Tool,
    name: "Keyword.Update",
    description: "Update fields/metrics on a keyword.",
    hidden: true,
    category: "Market.Keywords"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "id" => %{"type" => "string", "description" => "Keyword UUID"},
      "term" => %{"type" => "string", "description" => "Term"},
      "intent" => %{"type" => "string", "description" => "informational, commercial, transactional, navigational"},
      "volume" => %{"type" => "integer", "description" => "Monthly search volume"},
      "difficulty" => %{"type" => "integer", "description" => "Difficulty 0-100"},
      "cpc" => %{"type" => "number", "description" => "Cost per click"},
      "competition" => %{"type" => "number", "description" => "Competition index"},
      "competitor_id" => %{"type" => "string", "description" => "Competitor UUID"},
      "source" => %{"type" => "string", "description" => "manual, llm, import"},
      "metadata" => %{"type" => "object", "description" => "Metadata"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Tags"}
    },
    "required" => ["id"]
  }

  alias NoizuPromptLingua.Domains.Market
  alias NoizuPromptLingua.MCP.Args

  @fields ~w(term intent volume difficulty cpc competition competitor_id source metadata tags)a

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :id)

    case Market.update_keyword(id, Args.take(args, @fields)) do
      {:ok, k} -> {:ok, %{id: k.id, slug: k.slug, term: k.term, volume: k.volume, difficulty: k.difficulty}}
      {:error, :not_found} -> {:error, "Keyword '#{id}' not found"}
      {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end
end
