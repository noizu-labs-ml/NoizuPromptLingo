defmodule NoizuPromptLingua.Domains.Wiki.Tools.AttachmentList do
  use Noizu.MCP.Server.Tool,
    name: "Wiki.AttachmentList",
    description: "List attachments on a wiki page.",
    hidden: true,
    category: "Wiki",
    annotations: [read_only_hint: true]

  input do
    field :page, :string, required: true, description: "Page UUID"
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
        attachments = Wiki.list_attachments(page.id)

        {:ok,
         %{
           attachments:
             Enum.map(attachments, fn a ->
               %{
                 id: a.id,
                 filename: a.filename,
                 mime_type: a.mime_type,
                 url: a.url,
                 byte_size: a.byte_size
               }
             end),
           count: length(attachments)
         }}
    end
  end
end
