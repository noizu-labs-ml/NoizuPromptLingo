defmodule NoizuPromptLingua.Domains.Markdown.Tools.Convert do
  use Noizu.MCP.Server.Tool,
    name: "Markdown.Convert",
    description:
      "Convert a web page (URL), an HTML string, or raw content into Markdown. Type is auto-detected unless specified. URLs are fetched server-side; when a JINA_API_KEY is configured, URL conversion uses the Jina Reader service and otherwise falls back to a built-in HTML-to-Markdown converter.",
    annotations: [read_only_hint: true, open_world_hint: true],
    category: "Markdown"

  input do
    field :source, :string, required: true, description: "A URL, an HTML string, or raw content"

    field :type, :enum,
      values: [:auto, :url, :html, :markdown],
      default: :auto,
      description: "Source type. :auto infers from the input. :markdown passes through unchanged."
  end

  alias NoizuPromptLingua.Domains.Markdown
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    source = Args.get(args, :source)
    type = Args.get(args, :type) |> normalize_type()

    case Markdown.convert(source, type: type) do
      {:ok, %{markdown: md, source_type: st, via: via}} ->
        {:ok, %{markdown: md, source_type: to_string(st), via: to_string(via)}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp normalize_type(nil), do: :auto
  defp normalize_type(t) when is_atom(t), do: t
  defp normalize_type(t) when is_binary(t), do: String.to_existing_atom(t)
end
