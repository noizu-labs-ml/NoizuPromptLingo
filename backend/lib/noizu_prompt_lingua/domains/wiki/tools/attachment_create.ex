defmodule NoizuPromptLingua.Domains.Wiki.Tools.AttachmentCreate do
  use Noizu.MCP.Server.Tool,
    name: "Wiki.AttachmentCreate",
    description: "Attach a file reference (filename + URL) to a wiki page.",
    hidden: true,
    category: "Wiki"

  input do
    field :page, :string, required: true, description: "Page UUID"
    field :filename, :string, required: true, description: "File name"
    field :url, :string, description: "URL or media reference"
    field :mime_type, :string, description: "MIME type"
    field :byte_size, :integer, description: "Size in bytes"
  end

  alias NoizuPromptLingua.Domains.Wiki
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    page_id = Args.get(args, :page)

    case Wiki.get_page(page_id) do
      nil ->
        {:error, "Page '#{page_id}' not found"}

      page ->
        attrs = %{
          page_id: page.id,
          filename: Args.get(args, :filename),
          url: Args.get(args, :url),
          mime_type: Args.get(args, :mime_type),
          byte_size: Args.get(args, :byte_size)
        }

        case Wiki.create_attachment(attrs) do
          {:ok, attachment} ->
            {:ok,
             %{
               id: attachment.id,
               filename: attachment.filename,
               url: attachment.url,
               mime_type: attachment.mime_type
             }}

          {:error, changeset} ->
            {:error, "Failed: #{inspect(changeset.errors)}"}
        end
    end
  end
end
