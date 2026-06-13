defmodule NoizuPromptLingua.Domains.Wiki.Tools.EditPage do
  use Noizu.MCP.Server.Tool, name: "Wiki.EditPage",
    description: "Update page content (creates new artifact revision).", hidden: true, category: "Wiki"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "page_id" => %{"type" => "string", "description" => "Page UUID"},
      "content" => %{"type" => "string", "description" => "Updated page body"},
      "title" => %{"type" => "string", "description" => "Updated title"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Updated tags"},
      "edit_message" => %{"type" => "string", "description" => "What changed (revision note)"}
    },
    "required" => ["page_id", "content"]
  }

  alias NoizuPromptLingua.Domains.Wiki

  @impl true
  def call(args, _ctx) do
    page_id = args["page_id"]
    case Wiki.edit_page(page_id, args) do
      {:ok, {page, revision}} -> {:ok, %{id: page.id, title: page.title, revision_number: revision.revision_number}}
      {:error, :not_found} -> {:error, "Page not found"}
      {:error, cs} -> {:error, "Failed: #{inspect(cs)}"}
    end
  end
end
