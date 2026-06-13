defmodule NoizuPromptLingua.Domains.Wiki.Tools.WikiAttach do
  use Noizu.MCP.Server.Tool, name: "Wiki.Attach",
    description: "Attach file or artifact to a wiki page.", hidden: true, category: "Wiki"

  input do
    field :page_id, :string, required: true, description: "Page UUID"
    field :artifact_type, :string, description: "artifact (default), url, file"
    field :url, :string, description: "URL if artifact_type is url"
    field :description, :string, description: "Description"
  end

  alias NoizuPromptLingua.Services.Attach

  @impl true
  def call(args, _ctx) do
    page_id = args[:page_id] || args["page_id"]
    attrs = %{artifact_type: args[:artifact_type] || args["artifact_type"] || "artifact",
              url: args[:url] || args["url"], description: args[:description] || args["description"]}
    case Attach.add("wiki_page", page_id, attrs) do
      {:ok, att} -> {:ok, %{id: att.id, page_id: page_id, artifact_type: att.artifact_type}}
      {:error, cs} -> {:error, "Failed: #{inspect(cs)}"}
    end
  end
end
