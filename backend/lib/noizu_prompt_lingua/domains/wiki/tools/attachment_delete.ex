defmodule NoizuPromptLingua.Domains.Wiki.Tools.AttachmentDelete do
  use Noizu.MCP.Server.Tool,
    name: "Wiki.AttachmentDelete",
    description: "Delete a wiki page attachment.",
    hidden: true,
    category: "Wiki"

  input do
    field :attachment, :string, required: true, description: "Attachment UUID"
  end

  alias NoizuPromptLingua.Domains.Wiki
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :attachment)

    case Wiki.delete_attachment(id) do
      {:ok, _} -> {:ok, %{deleted: true, id: id}}
      {:error, :not_found} -> {:error, "Attachment '#{id}' not found"}
      {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end
end
