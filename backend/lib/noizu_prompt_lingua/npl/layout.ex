defmodule NoizuPromptLingua.NPL.Layout do
  @moduledoc false

  alias NoizuPromptLingua.NPL.Resolver.ResolvedComponent

  @type strategy :: :yaml_order | :classic | :grouped

  @spec format([ResolvedComponent.t()], strategy()) :: String.t()
  def format([], _strategy), do: ""
  def format(components, :yaml_order), do: format_yaml_order(components)
  def format(components, :classic), do: format_classic(components)
  def format(components, :grouped), do: format_grouped(components)
  def format(components, _), do: format_yaml_order(components)

  defp format_yaml_order(components) do
    components
    |> Enum.map(&format_component/1)
    |> Enum.join("\n\n")
  end

  defp format_classic(components) do
    components
    |> Enum.group_by(fn comp ->
      case comp.labels do
        [first | _] -> first
        [] -> "uncategorized"
      end
    end)
    |> Enum.sort_by(fn {cat, _} -> cat end)
    |> Enum.map(fn {category, comps} ->
      header = "## #{title_case(category)}"
      body = Enum.map(comps, &format_component/1) |> Enum.join("\n\n")
      "#{header}\n\n#{body}"
    end)
    |> Enum.join("\n\n")
  end

  defp format_grouped(components) do
    components
    |> Enum.group_by(& &1.section)
    |> Enum.map(fn {section_name, comps} ->
      title = section_name |> String.replace("-", " ") |> title_case()
      header = "## #{title}"
      body = Enum.map(comps, &format_component/1) |> Enum.join("\n\n")
      "#{header}\n\n#{body}"
    end)
    |> Enum.join("\n\n")
  end

  defp format_component(%ResolvedComponent{} = comp) do
    parts = []

    parts =
      if comp.slug != "" do
        ["### #{comp.name} (`#{comp.slug}`)" | parts]
      else
        ["### #{comp.name}" | parts]
      end

    parts = if comp.brief != "", do: ["*#{comp.brief}*" | parts], else: parts
    parts = if comp.description != "", do: [comp.description | parts], else: parts

    parts =
      if comp.syntax != [] do
        syntax_lines =
          Enum.map(comp.syntax, fn syn ->
            text = Map.get(syn, "syntax", Map.get(syn, "name", ""))
            "- `#{text}`"
          end)

        ["**Syntax:**\n#{Enum.join(syntax_lines, "\n")}" | parts]
      else
        parts
      end

    parts =
      if comp.examples != [] do
        examples_text = format_examples(comp.examples)
        ["**Examples:**\n#{examples_text}" | parts]
      else
        parts
      end

    parts =
      if comp.labels != [] do
        labels_str = Enum.map(comp.labels, &"`#{&1}`") |> Enum.join(", ")
        ["*Labels: #{labels_str}*" | parts]
      else
        parts
      end

    parts =
      if comp.require != [] do
        requires_str = Enum.map(comp.require, &"`#{&1}`") |> Enum.join(", ")
        ["*Requires: #{requires_str}*" | parts]
      else
        parts
      end

    parts
    |> Enum.reverse()
    |> Enum.join("\n\n")
  end

  defp format_examples(examples) do
    Enum.map(examples, fn ex ->
      name = Map.get(ex, "name", "Example")
      brief = Map.get(ex, "brief", "")
      priority = Map.get(ex, "priority", 0)

      if brief != "" do
        "- **#{name}**: #{brief} (priority #{priority})"
      else
        "- **#{name}** (priority #{priority})"
      end
    end)
    |> Enum.join("\n")
  end

  defp title_case(str) do
    str
    |> String.split(~r/[\s_-]+/)
    |> Enum.map(fn word ->
      case String.split_at(word, 1) do
        {first, rest} -> String.upcase(first) <> rest
      end
    end)
    |> Enum.join(" ")
  end
end
