defmodule NoizuPromptLingua.NPL.ConventionFormatter do
  @moduledoc false

  @spec format_convention(String.t(), keyword()) :: String.t()
  def format_convention(convention, opts \\ []) do
    conventions_dir = Keyword.get(opts, :conventions_dir, conventions_dir())
    components = Keyword.get(opts, :components, nil)
    rendered_components = Keyword.get(opts, :rendered_components, nil)
    component_priority = Keyword.get(opts, :component_priority, 0)
    example_priority = Keyword.get(opts, :example_priority, 0)
    flags = Keyword.get(opts, :flags, %{})
    heading_offset = Keyword.get(opts, :heading_offset, 0)

    yaml_path = Path.join(conventions_dir, "#{convention}.yaml")

    case YamlElixir.read_from_file(yaml_path) do
      {:ok, data} ->
        do_format(data, convention, components, rendered_components, component_priority, example_priority, flags, heading_offset)

      {:error, _} ->
        "\nFORMAT CONVENTION #{convention}\n(Error: File not found at #{yaml_path})\n"
    end
  end

  defp do_format(data, _convention, component_names_list, rendered_components, component_priority, example_priority, flags, heading_offset) do
    component_names = if component_names_list, do: MapSet.new(component_names_list), else: nil

    title = Map.get(data, "title") || Map.get(data, "name", "")
    description = String.trim(Map.get(data, "description", ""))
    brief = String.trim(Map.get(data, "brief", ""))
    purpose = String.trim(Map.get(data, "purpose", ""))
    categories = Map.get(data, "categories", [])
    all_components = Map.get(data, "components", [])

    use_xml = Map.get(flags, "xml", false) || Map.get(flags, :xml, false)
    use_concise = Map.get(flags, "concise", true) && Map.get(flags, :concise, true)

    description = if use_concise and brief != "", do: brief, else: description

    h = heading_offset

    rendered_set = if rendered_components, do: MapSet.new(rendered_components), else: nil

    rendering_names =
      all_components
      |> Enum.filter(fn c ->
        name = Map.get(c, "name", "")
        priority = Map.get(c, "priority", 0)

        (component_names == nil or MapSet.member?(component_names, name)) and
          priority <= component_priority and
          (rendered_set == nil or not MapSet.member?(rendered_set, name))
      end)
      |> Enum.map(&Map.get(&1, "name", ""))
      |> MapSet.new()

    known_components =
      if rendered_set do
        MapSet.union(rendering_names, rendered_set)
      else
        rendering_names
      end

    categories_section =
      categories
      |> Enum.map(fn cat ->
        format_category(cat, all_components, rendering_names, known_components, example_priority, use_concise, use_xml, h)
      end)
      |> Enum.reject(&(&1 == ""))
      |> Enum.join("")

    purpose_section = if purpose != "", do: "\n```purpose\n#{purpose}\n```", else: ""
    title_header = heading(1, h)

    "\n#{title_header} #{title}\n\n#{description}\n#{purpose_section}\n\n#{categories_section}\n"
  end

  defp format_category(cat, all_components, rendering_names, known_components, example_priority, use_concise, use_xml, h) do
    cat_name = Map.get(cat, "name", "")
    cat_title = Map.get(cat, "title", cat_name)
    cat_desc = String.trim(Map.get(cat, "description", ""))

    cat_components =
      Enum.filter(all_components, fn c ->
        Map.get(c, "category") == cat_name and MapSet.member?(rendering_names, Map.get(c, "name", ""))
      end)

    if cat_components == [] do
      ""
    else
      cat_header = heading(3, h)
      comp_header = heading(4, h)

      cat_examples = find_minimal_example_set(cat, cat_components, example_priority, known_components)

      components_text =
        Enum.map(cat_components, fn comp ->
          format_component_section(comp, comp_header, example_priority, use_concise, use_xml, h)
        end)
        |> Enum.join("")

      examples_text = format_category_examples(cat_examples, cat_title, use_concise, use_xml, h)

      "#{cat_header} #{cat_title}\n\n#{cat_desc}\n\n#{components_text}#{examples_text}"
    end
  end

  defp format_component_section(comp, comp_header, example_priority, use_concise, use_xml, h) do
    comp_heading = Map.get(comp, "friendly-name") || Map.get(comp, "name", "")
    comp_brief = String.trim(Map.get(comp, "brief", ""))
    comp_desc = String.trim(Map.get(comp, "description", ""))
    comp_syntaxes = Map.get(comp, "syntax", [])
    comp_examples = Map.get(comp, "examples", [])

    comp_desc = if use_concise and comp_brief != "", do: comp_brief, else: comp_desc

    filtered_examples =
      Enum.filter(comp_examples, fn ex -> Map.get(ex, "priority", 0) <= example_priority end)

    result = "#{comp_header} #{comp_heading}\n\n#{comp_desc}\n\n"

    result =
      if comp_syntaxes != [] do
        syntax_text =
          if not use_concise, do: "#{heading(5, h)} Syntax\n\n", else: ""

        syntax_body =
          Enum.map(comp_syntaxes, fn syn ->
            syn_syntax = Map.get(syn, "syntax", "")
            syn_desc = Map.get(syn, "description", "")

            desc_lines =
              syn_desc
              |> String.split("\n")
              |> Enum.filter(&(&1 != ""))
              |> Enum.map(&": #{&1}")
              |> Enum.join("\n")

            desc_part = if desc_lines != "", do: "#{desc_lines}\n", else: ""
            "\"#{syn_syntax}\"\n#{desc_part}\n"
          end)
          |> Enum.join("")

        result <> syntax_text <> syntax_body
      else
        result
      end

    result =
      if filtered_examples != [] do
        examples_header = if not use_concise, do: "#{heading(5, h)} Examples\n\n", else: ""

        examples_body =
          Enum.map(filtered_examples, fn ex ->
            format_example(ex, use_concise, use_xml, h)
          end)
          |> Enum.join("")

        result <> examples_header <> examples_body
      else
        result
      end

    result <> "\n"
  end

  defp format_example(ex, use_concise, use_xml, h) do
    ex_example = String.trim(Map.get(ex, "example", ""))
    ex_thread = Map.get(ex, "thread", [])

    if use_concise do
      snippet = if ex_example != "", do: format_snippet(ex_example, use_xml) <> "\n\n", else: ""
      thread = if ex_thread != [], do: format_thread(ex_thread, use_xml) <> "\n\n", else: ""
      snippet <> thread
    else
      ex_title = Map.get(ex, "title") || Map.get(ex, "brief", "")
      ex_description = String.trim(Map.get(ex, "description", ""))
      ex_purpose = String.trim(Map.get(ex, "purpose", ""))

      header = "#{heading(6, h)} #{ex_title}\n\n#{ex_description}\n\n```purpose\n#{ex_purpose}\n```\n\n"
      snippet = if ex_example != "", do: format_snippet(ex_example, use_xml) <> "\n\n", else: ""
      thread = if ex_thread != [], do: format_thread(ex_thread, use_xml) <> "\n\n", else: ""
      header <> snippet <> thread
    end
  end

  defp format_category_examples([], _cat_title, _use_concise, _use_xml, _h), do: ""

  defp format_category_examples(cat_examples, cat_title, _use_concise, use_xml, h) do
    examples_header = heading(4, h)

    body =
      Enum.map(cat_examples, fn ex ->
        ex_brief = Map.get(ex, "brief", "")
        ex_thread = Map.get(ex, "thread", [])
        ex_example = Map.get(ex, "example", "")

        brief_text = if ex_brief != "", do: "**#{ex_brief}**\n\n", else: ""
        snippet = if ex_example != "" and is_binary(ex_example), do: format_snippet(String.trim(ex_example), use_xml) <> "\n\n", else: ""
        thread = if ex_thread != [], do: format_thread(ex_thread, use_xml) <> "\n\n", else: ""
        brief_text <> snippet <> thread
      end)
      |> Enum.join("")

    "#{examples_header} #{cat_title} Examples\n\n#{body}\n"
  end

  defp format_snippet(content, true) do
    "<npl-example>\n<snippet>\n#{content}\n</snippet>\n</npl-example>"
  end

  defp format_snippet(content, false) do
    backticks = max(count_backticks(content) + 2, 3)
    fence = String.duplicate("`", backticks)
    indented = content |> String.split("\n") |> Enum.map(&"  #{&1}") |> Enum.join("\n")
    "#{fence}example\nsnippet: |\n#{indented}\n#{fence}"
  end

  defp format_thread(messages, true) do
    body =
      Enum.map(messages, fn msg ->
        role = Map.get(msg, "role", "")
        message = String.trim(Map.get(msg, "message", ""))
        "<msg role=\"#{role}\">\n#{message}\n</msg>"
      end)
      |> Enum.join("\n")

    "<npl-example>\n<thread>\n#{body}\n</thread>\n</npl-example>"
  end

  defp format_thread(messages, false) do
    all_text = Enum.map(messages, &Map.get(&1, "message", "")) |> Enum.join("\n")
    backticks = max(count_backticks(all_text) + 2, 3)
    fence = String.duplicate("`", backticks)

    body =
      Enum.map(messages, fn msg ->
        role = Map.get(msg, "role", "")
        message = String.trim(Map.get(msg, "message", ""))
        indented = message |> String.split("\n") |> Enum.map(&"    #{&1}") |> Enum.join("\n")
        "  role: #{role}\n  message: |\n#{indented}"
      end)
      |> Enum.join("\n")

    "#{fence}example\nthread\n#{body}\n#{fence}"
  end

  defp count_backticks(text) do
    text
    |> String.split("\n")
    |> Enum.reduce(0, fn line, max_count ->
      case Regex.run(~r/^(`+)/, line) do
        [_, backticks] -> max(String.length(backticks), max_count)
        _ -> max_count
      end
    end)
  end

  defp find_minimal_example_set(cat, cat_components, example_priority, known_components) do
    cat_component_names = MapSet.new(Enum.map(cat_components, &Map.get(&1, "name", "")))
    cat_examples = Map.get(cat, "examples", [])

    if cat_examples != [] do
      find_minimal_from(cat_examples, cat_components, cat_component_names, example_priority, known_components)
    else
      all_examples =
        Enum.flat_map(cat_components, fn comp ->
          Map.get(comp, "examples", [])
          |> Enum.filter(fn ex -> Map.get(ex, "priority", 0) <= example_priority end)
        end)

      thread_examples = Enum.filter(all_examples, &(Map.get(&1, "thread", []) != []))
      examples = if thread_examples != [], do: thread_examples, else: all_examples

      find_minimal_from_coverage(examples, cat_components, cat_component_names, known_components)
    end
  end

  defp find_minimal_from(cat_examples, cat_components, cat_component_names, example_priority, known_components) do
    example_coverage =
      cat_examples
      |> Enum.filter(fn ex -> Map.get(ex, "priority", 0) <= example_priority end)
      |> Enum.map(fn ex ->
        covered = get_example_coverage(ex, cat_components)
        {ex, covered}
      end)
      |> Enum.filter(fn {_ex, covered} -> MapSet.size(covered) > 0 end)
      |> Enum.sort_by(fn {ex, covered} ->
        {-MapSet.size(covered), unknown_count(ex, known_components)}
      end)

    greedy_set_cover(example_coverage, cat_component_names)
  end

  defp find_minimal_from_coverage(examples, cat_components, cat_component_names, known_components) do
    example_coverage =
      examples
      |> Enum.map(fn ex ->
        covered = get_example_coverage(ex, cat_components)
        {ex, covered}
      end)
      |> Enum.filter(fn {_ex, covered} -> MapSet.size(covered) > 0 end)
      |> Enum.sort_by(fn {ex, covered} ->
        {-MapSet.size(covered), Map.get(ex, "priority", 0), unknown_count(ex, known_components)}
      end)

    greedy_set_cover(example_coverage, cat_component_names)
  end

  defp greedy_set_cover(example_coverage, target_names) do
    {selected, _covered} =
      Enum.reduce_while(example_coverage, {[], MapSet.new()}, fn {ex, covered}, {acc, covered_so_far} ->
        newly_covered = MapSet.difference(covered, covered_so_far)

        if MapSet.size(newly_covered) > 0 do
          new_covered = MapSet.union(covered_so_far, covered)
          new_acc = [ex | acc]

          if MapSet.subset?(target_names, new_covered) or length(new_acc) >= 3 do
            {:halt, {new_acc, new_covered}}
          else
            {:cont, {new_acc, new_covered}}
          end
        else
          {:cont, {acc, covered_so_far}}
        end
      end)

    Enum.reverse(selected)
  end

  defp get_example_coverage(example, cat_components) do
    covers = Map.get(example, "covers", [])
    cat_component_names = MapSet.new(Enum.map(cat_components, &Map.get(&1, "name", "")))

    if covers != [] do
      covers |> MapSet.new() |> MapSet.intersection(cat_component_names)
    else
      labels = Map.get(example, "labels", [])

      Enum.reduce(labels, MapSet.new(), fn label, acc ->
        Enum.reduce(cat_components, acc, fn comp, inner_acc ->
          comp_syntaxes = Map.get(comp, "syntax", [])

          if Enum.any?(comp_syntaxes, &(Map.get(&1, "syntax") == label)) do
            MapSet.put(inner_acc, Map.get(comp, "name", ""))
          else
            inner_acc
          end
        end)
      end)
    end
  end

  defp unknown_count(_ex, nil), do: 0

  defp unknown_count(ex, known_components) do
    full_covers = Map.get(ex, "covers", []) |> MapSet.new()
    MapSet.size(MapSet.difference(full_covers, known_components))
  end

  defp heading(level, offset), do: String.duplicate("#", level + offset)

  defp conventions_dir do
    NoizuPromptLingua.NPL.conventions_dir()
  end
end
