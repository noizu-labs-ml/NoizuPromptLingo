defmodule NoizuPromptLingua.Domains.Artifacts.Tools.ArtifactCreate do
  use Noizu.MCP.Server.Tool,
    name: "Artifact.Create",
    description: "Create a new artifact with its initial revision.",
    hidden: true,
    category: "Artifacts"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "kind" => %{"type" => "string", "description" => "Artifact kind: code, document, image, wiki, config, binary"},
      "title" => %{"type" => "string", "description" => "Artifact title"},
      "content" => %{"type" => "string", "description" => "Initial content (text or base64 for binary)"},
      "mime_type" => %{"type" => "string", "description" => "MIME type (e.g. text/markdown, image/png)"},
      "project_id" => %{"type" => "string", "description" => "Project UUID"},
      "metadata" => %{"type" => "object", "description" => "Additional metadata"}
    },
    "required" => ["kind", "title", "content"]
  }

  alias NoizuPromptLingua.Domains.Artifacts

  @impl true
  def call(args, _ctx) do
    attrs = %{
      kind: args["kind"],
      title: args["title"],
      content: args["content"],
      mime_type: args["mime_type"],
      project_id: args["project_id"]
    }

    case Artifacts.create(attrs) do
      {:ok, artifact} ->
        rev = hd(artifact.revisions)
        {:ok, %{
          id: artifact.id,
          revision_id: rev.id,
          kind: artifact.kind,
          title: artifact.title,
          created_at: artifact.inserted_at
        }}
      {:error, changeset} ->
        {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end
end
