defmodule NoizuPromptLingua.Domains.Wiki.Tools.CreatePage do
  use Noizu.MCP.Server.Tool, name: "Wiki.CreatePage",
    description: "Create a page in a space.", hidden: true, category: "Wiki"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "space_id" => %{"type" => "string", "description" => "Space UUID"},
      "slug" => %{"type" => "string", "description" => "Page slug (unique within space)"},
      "title" => %{"type" => "string", "description" => "Page title"},
      "content" => %{"type" => "string", "description" => "Page body (markdown)"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Tag strings"},
      "parent_page_id" => %{"type" => "string", "description" => "Parent page UUID"}
    },
    "required" => ["space_id", "slug", "title", "content"]
  }

  alias NoizuPromptLingua.Domains.Wiki

  @impl true
  def call(args, _ctx) do
    attrs = %{space_id: args["space_id"], slug: args["slug"], title: args["title"],
              content: args["content"], tags: args["tags"], parent_page_id: args["parent_page_id"]}
    case Wiki.create_page(attrs) do
      {:ok, page} -> {:ok, %{id: page.id, slug: page.slug, title: page.title, artifact_id: page.artifact_id, created_at: page.inserted_at}}
      {:error, cs} -> {:error, "Failed: #{inspect(cs)}"}
    end
  end
end
