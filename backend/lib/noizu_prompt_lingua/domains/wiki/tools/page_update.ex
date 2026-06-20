defmodule NoizuPromptLingua.Domains.Wiki.Tools.PageUpdate do
  use Noizu.MCP.Server.Tool,
    name: "Wiki.PageUpdate",
    description: "Update a wiki page's title, slug, content, position, or parent.",
    hidden: true,
    category: "Wiki"

  input do
    field :page, :string, required: true, description: "Page UUID"
    field :title, :string, description: "New title"
    field :slug, :string, description: "New slug"
    field :content, :string, description: "New body (markdown)"
    field :position, :integer, description: "New sort position"
    field :parent, :string, description: "New parent page UUID (\"\" to clear)"
  end

  alias NoizuPromptLingua.Domains.Wiki
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :page)

    case Wiki.get_page(id) do
      nil ->
        {:error, "Page '#{id}' not found"}

      _page ->
        attrs =
          args
          |> Args.take([:title, :slug, :content, :position])
          |> put_parent(Args.get(args, :parent))

        case Wiki.update_page(id, attrs) do
          {:ok, updated} ->
            {:ok, %{id: updated.id, slug: updated.slug, title: updated.title, parent_id: updated.parent_id, position: updated.position}}

          {:error, :not_found} -> {:error, "Page '#{id}' not found"}
          {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
        end
    end
  end

  defp put_parent(attrs, nil), do: attrs
  defp put_parent(attrs, ""), do: Map.put(attrs, :parent_id, nil)
  defp put_parent(attrs, ref), do: Map.put(attrs, :parent_id, ref)
end
