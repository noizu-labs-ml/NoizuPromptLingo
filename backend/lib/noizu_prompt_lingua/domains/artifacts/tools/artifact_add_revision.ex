defmodule NoizuPromptLingua.Domains.Artifacts.Tools.ArtifactAddRevision do
  use Noizu.MCP.Server.Tool,
    name: "Artifact.AddRevision",
    description: "Append a new revision to an existing artifact.",
    hidden: true,
    category: "Artifacts"

  # Use a raw input_schema (mirroring Artifact.Create) rather than the typed `input do`
  # DSL: the typed-string path chokes on large content payloads (~10KB+ -> opaque "Tool
  # execution failed"), while Create's input_schema handles the same payload fine
  # (a2f06808). The deeper typed-input-DSL large-string bug is flagged to mcp-tooling.
  input_schema(%{
    "type" => "object",
    "properties" => %{
      "artifact_id" => %{"type" => "string", "description" => "Artifact UUID"},
      "content" => %{
        "type" => "string",
        "description" => "New content (text or base64 for binary)"
      },
      "note" => %{"type" => "string", "description" => "Revision note describing changes"}
    },
    "required" => ["artifact_id", "content"]
  })

  alias NoizuPromptLingua.Domains.Artifacts

  @impl true
  def call(args, _ctx) do
    artifact_id = args[:artifact_id] || args["artifact_id"]
    content = args[:content] || args["content"]
    note = args[:note] || args["note"]

    case Artifacts.add_revision(artifact_id, content, note) do
      {:ok, revision} ->
        {:ok,
         %{
           revision_id: revision.id,
           revision_number: revision.revision_number,
           created_at: revision.inserted_at
         }}

      {:error, changeset} ->
        {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end
end
