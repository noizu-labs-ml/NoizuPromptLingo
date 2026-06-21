defmodule NoizuPromptLingua.Domains.Markdown do
  @moduledoc """
  Cloud-deployable markdown utilities (ports the deprecated PRD-017 tools):

    * `convert/2` — turn a URL, raw HTML, or passthrough markdown into Markdown.
      URLs are fetched with `Req`; HTML is converted with a Floki tree walk. When
      a `JINA_API_KEY` is configured, URL conversion can be delegated to the Jina
      Reader service for higher-fidelity rendering (parity with the old build),
      otherwise it falls back to the pure-Elixir converter.

    * `view/2` — filter/collapse a Markdown document by heading selector. Supports
      a `"parent > child"` path, a bare heading name, an `"h2"` level selector,
      `bare` (extract-only) vs context mode, and depth-based collapsing.

  Neither function touches the database — these are pure transforms over the
  supplied content, so the tools are safe to run in any deployment.
  """

  require Logger

  @jina_endpoint "https://r.jina.ai/"

  # ── Conversion ────────────────────────────────────────────────────────────

  @doc """
  Convert `source` to Markdown.

  `type` is one of `:url`, `:html`, or `:markdown` (passthrough). When omitted or
  `:auto`, the type is inferred: an `http(s)://` string is a URL, a string with
  HTML tags is HTML, anything else is treated as already-markdown.

  Returns `{:ok, %{markdown: md, source_type: type, via: :jina | :floki | :passthrough}}`
  or `{:error, reason}`.
  """
  def convert(source, opts \\ []) when is_binary(source) do
    case resolve_type(source, opts[:type] || :auto) do
      :url -> convert_url(source, opts)
      :html -> {:ok, %{markdown: html_to_markdown(source), source_type: :html, via: :floki}}
      :markdown -> {:ok, %{markdown: source, source_type: :markdown, via: :passthrough}}
    end
  end

  defp resolve_type(source, :auto) do
    cond do
      Regex.match?(~r/^https?:\/\//i, String.trim(source)) -> :url
      Regex.match?(~r/<\/?[a-z][\s\S]*>/i, source) -> :html
      true -> :markdown
    end
  end

  defp resolve_type(_source, type) when type in [:url, :html, :markdown], do: type

  defp convert_url(url, opts) do
    if jina_key() && opts[:jina] != false do
      case convert_url_via_jina(url) do
        {:ok, md} -> {:ok, %{markdown: md, source_type: :url, via: :jina}}
        {:error, _} -> convert_url_via_floki(url)
      end
    else
      convert_url_via_floki(url)
    end
  end

  defp convert_url_via_floki(url) do
    case Req.get(url, redirect: true, retry: :transient, max_retries: 2) do
      {:ok, %{status: status, body: body}} when status in 200..299 ->
        html = if is_binary(body), do: body, else: inspect(body)
        {:ok, %{markdown: html_to_markdown(html), source_type: :url, via: :floki}}

      {:ok, %{status: status}} ->
        {:error, "Fetch failed: HTTP #{status}"}

      {:error, reason} ->
        {:error, "Fetch failed: #{inspect(reason)}"}
    end
  end

  defp convert_url_via_jina(url) do
    headers = [{"accept", "text/plain"}, {"authorization", "Bearer #{jina_key()}"}]

    case Req.get(@jina_endpoint <> url, headers: headers, retry: :transient, max_retries: 1) do
      {:ok, %{status: status, body: body}} when status in 200..299 and is_binary(body) ->
        {:ok, body}

      other ->
        {:error, other}
    end
  end

  defp jina_key, do: System.get_env("JINA_API_KEY")

  @doc "Convert an HTML string to Markdown via a Floki tree walk."
  def html_to_markdown(html) when is_binary(html) do
    case Floki.parse_document(html) do
      {:ok, doc} ->
        doc
        |> drop_noise()
        |> body_or_all()
        |> render_nodes()
        |> collapse_blanks()
        |> String.trim()

      _ ->
        # Not parseable as a document — strip tags as a last resort.
        html |> Floki.parse_fragment() |> elem(1) |> Floki.text()
    end
  end

  defp drop_noise(doc),
    do: Floki.filter_out(doc, "script, style, noscript, template, svg, iframe, head")

  defp body_or_all(doc) do
    case Floki.find(doc, "body") do
      [] -> doc
      body -> body
    end
  end

  # Walk a list of Floki nodes, concatenating their markdown.
  defp render_nodes(nodes) when is_list(nodes),
    do: nodes |> Enum.map(&render_node/1) |> Enum.join("")

  defp render_nodes(node), do: render_node(node)

  defp render_node(text) when is_binary(text), do: normalize_ws(text)
  defp render_node({:comment, _}), do: ""

  defp render_node({tag, _attrs, children}) when tag in ~w(h1 h2 h3 h4 h5 h6) do
    level = tag |> String.trim_leading("h") |> String.to_integer()
    "\n\n" <> String.duplicate("#", level) <> " " <> inline(children) <> "\n\n"
  end

  defp render_node({"p", _attrs, children}), do: "\n\n" <> inline(children) <> "\n\n"
  defp render_node({"br", _attrs, _children}), do: "  \n"
  defp render_node({"hr", _attrs, _children}), do: "\n\n---\n\n"

  defp render_node({tag, _attrs, children}) when tag in ~w(strong b),
    do: "**" <> inline(children) <> "**"

  defp render_node({tag, _attrs, children}) when tag in ~w(em i),
    do: "_" <> inline(children) <> "_"

  defp render_node({"code", _attrs, children}) do
    text = Floki.text(children)
    if String.contains?(text, "\n"), do: "\n```\n" <> text <> "\n```\n", else: "`" <> text <> "`"
  end

  defp render_node({"pre", _attrs, children}) do
    "\n\n```\n" <> String.trim_trailing(Floki.text(children)) <> "\n```\n\n"
  end

  defp render_node({"a", attrs, children}) do
    href = attr(attrs, "href")
    label = inline(children)

    cond do
      label == "" -> ""
      is_nil(href) or href == "" -> label
      true -> "[" <> label <> "](" <> href <> ")"
    end
  end

  defp render_node({"img", attrs, _children}) do
    src = attr(attrs, "src")
    alt = attr(attrs, "alt") || ""
    if src, do: "![" <> alt <> "](" <> src <> ")", else: ""
  end

  defp render_node({"ul", _attrs, children}), do: "\n" <> render_list(children, "- ") <> "\n"

  defp render_node({"ol", _attrs, children}), do: "\n" <> render_ordered(children) <> "\n"

  defp render_node({"li", _attrs, children}), do: inline(children)

  defp render_node({"blockquote", _attrs, children}) do
    inner = render_nodes(children) |> String.trim()

    quoted =
      inner
      |> String.split("\n")
      |> Enum.map(&("> " <> &1))
      |> Enum.join("\n")

    "\n\n" <> quoted <> "\n\n"
  end

  defp render_node({"table", _attrs, children}), do: "\n\n" <> render_table(children) <> "\n\n"

  # Default: transparently render children of unknown/structural tags.
  defp render_node({_tag, _attrs, children}), do: render_nodes(children)

  # Inline rendering collapses surrounding whitespace.
  defp inline(children), do: children |> render_nodes() |> normalize_ws() |> String.trim()

  defp render_list(children, marker) do
    children
    |> Enum.filter(&match?({"li", _, _}, &1))
    |> Enum.map(fn {"li", _, c} -> marker <> inline(c) end)
    |> Enum.join("\n")
  end

  defp render_ordered(children) do
    children
    |> Enum.filter(&match?({"li", _, _}, &1))
    |> Enum.with_index(1)
    |> Enum.map(fn {{"li", _, c}, i} -> "#{i}. " <> inline(c) end)
    |> Enum.join("\n")
  end

  defp render_table(children) do
    rows =
      children
      |> Floki.find("tr")
      |> Enum.map(fn {_t, _a, cells} ->
        cells
        |> Enum.filter(&match?({tag, _, _} when tag in ["td", "th"], &1))
        |> Enum.map(fn {_tag, _a, c} -> inline(c) end)
      end)
      |> Enum.reject(&(&1 == []))

    case rows do
      [] ->
        ""

      [header | body] ->
        sep = Enum.map(header, fn _ -> "---" end)
        [header, sep | body] |> Enum.map(&("| " <> Enum.join(&1, " | ") <> " |")) |> Enum.join("\n")
    end
  end

  defp attr(attrs, name) do
    Enum.find_value(attrs, fn
      {^name, v} -> v
      _ -> nil
    end)
  end

  defp normalize_ws(text), do: Regex.replace(~r/[ \t\r\n]+/, text, " ")

  defp collapse_blanks(md), do: Regex.replace(~r/\n{3,}/, md, "\n\n")

  # ── Viewing / filtering ─────────────────────────────────────────────────

  @doc """
  Filter/collapse a Markdown document.

  Options:
    * `:filter` — heading selector: `"Parent > Child"`, a bare `"Heading"`,
      `"Parent > *"` (children), or `"h2"` (all level-2 headings).
    * `:bare` — when true, return only the matched section(s); otherwise return
      the full document with non-matched sibling sections collapsed (📦 marker).
    * `:depth` — globally collapse headings deeper than this level (1-6).
    * `:filter_inner_depth` — within matched sections, collapse deeper than this.

  Returns `{:ok, %{markdown: md, matched: count}}`.
  """
  def view(markdown, opts \\ []) when is_binary(markdown) do
    sections = parse_sections(markdown)
    filter = opts[:filter]
    bare = opts[:bare] in [true, "true"]
    depth = to_int(opts[:depth])
    inner_depth = to_int(opts[:filter_inner_depth])

    {sections, matched} = apply_filter(sections, filter)

    rendered =
      sections
      |> render_sections(bare: bare, depth: depth, inner_depth: inner_depth, has_filter: !!filter)
      |> String.trim()

    {:ok, %{markdown: rendered, matched: matched}}
  end

  # Parse markdown into a flat list of %{level, text, slug, lines, matched}
  # records, where `lines` holds the body content under each heading.
  defp parse_sections(markdown) do
    lines = String.split(markdown, "\n")

    {sections, current} =
      Enum.reduce(lines, {[], nil}, fn line, {acc, cur} ->
        case heading_match(line) do
          {level, text} ->
            acc = if cur, do: [cur | acc], else: acc
            {acc, %{level: level, text: text, slug: slugify(text), lines: [], matched: false}}

          nil ->
            case cur do
              nil ->
                # Preamble before any heading — synthesize a level-0 holder.
                {acc, %{level: 0, text: nil, slug: nil, lines: [line], matched: false}}

              %{lines: ls} = c ->
                {acc, %{c | lines: ls ++ [line]}}
            end
        end
      end)

    sections = if current, do: [current | sections], else: sections
    Enum.reverse(sections)
  end

  defp heading_match(line) do
    case Regex.run(~r/^(#{1,6})\s+(.*)$/, line) do
      [_, hashes, text] -> {String.length(hashes), String.trim(text)}
      _ -> nil
    end
  end

  defp apply_filter(sections, nil), do: {sections, length(Enum.filter(sections, & &1.text))}

  defp apply_filter(sections, filter) do
    {sections, count} =
      Enum.map_reduce(sections, 0, fn section, count ->
        if section_matches?(section, filter) do
          {%{section | matched: true}, count + 1}
        else
          {section, count}
        end
      end)

    {sections, count}
  end

  # Selector forms: "h2" (level), "a > b" (path tail), "a > *" (children of a),
  # bare "name" (heading name match).
  defp section_matches?(%{text: nil}, _filter), do: false

  defp section_matches?(section, filter) do
    filter = String.trim(filter)

    cond do
      Regex.match?(~r/^h[1-6]$/i, filter) ->
        section.level == (filter |> String.trim_leading("hH") |> String.to_integer())

      String.contains?(filter, ">") ->
        target = filter |> String.split(">") |> List.last() |> String.trim()
        target == "*" or slugify(target) == section.slug

      true ->
        slugify(filter) == section.slug
    end
  end

  defp render_sections(sections, opts) do
    bare = opts[:bare]
    has_filter = opts[:has_filter]

    sections
    |> Enum.map(fn section ->
      cond do
        section.text == nil ->
          if bare and has_filter, do: "", else: Enum.join(section.lines, "\n")

        has_filter and bare and not section.matched ->
          ""

        has_filter and not bare and not section.matched ->
          collapse_marker(section)

        true ->
          render_section(section, opts)
      end
    end)
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("\n\n")
  end

  defp render_section(section, opts) do
    depth = opts[:depth]
    inner = opts[:inner_depth]
    limit = inner || depth

    heading = String.duplicate("#", section.level) <> " " <> section.text

    cond do
      is_integer(limit) and section.level > limit ->
        collapse_marker(section)

      true ->
        body = section.lines |> Enum.join("\n") |> String.trim_trailing()
        if body == "", do: heading, else: heading <> "\n" <> body
    end
  end

  defp collapse_marker(%{level: level, text: text}) do
    String.duplicate("#", max(level, 1)) <> " " <> (text || "") <> " 📦"
  end

  defp slugify(nil), do: nil

  defp slugify(text) do
    text
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/u, "")
    |> String.replace(~r/\s+/, "-")
    |> String.replace(~r/-+/, "-")
    |> String.trim("-")
  end

  defp to_int(nil), do: nil
  defp to_int(n) when is_integer(n), do: n
  defp to_int(s) when is_binary(s), do: (Integer.parse(s) |> elem(0))
end
