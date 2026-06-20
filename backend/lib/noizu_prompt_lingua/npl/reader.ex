defmodule NoizuPromptLingua.NPL.Reader do
  @moduledoc """
  Read-only introspection over the NPL convention YAML files.

  Where `NoizuPromptLingua.NPL.Loader` / `Definition` produce formatted
  markdown for agents, this module returns the raw convention structure as
  plain maps so the web UI can browse, filter, and search conventions.
  """

  @section_files %{
    "syntax" => "syntax.yaml",
    "declarations" => "declarations.yaml",
    "directives" => "directives.yaml",
    "prefixes" => "prefixes.yaml",
    "prompt-sections" => "prompt-sections.yaml",
    "special-sections" => "special-sections.yaml",
    "pumps" => "pumps.yaml",
    "fences" => "fences.yaml"
  }

  @type component_summary :: %{
          section: String.t(),
          name: String.t(),
          slug: String.t(),
          friendly_name: String.t() | nil,
          brief: String.t(),
          labels: [String.t()],
          category: String.t() | nil
        }

  @type component_detail :: %{
          section: String.t(),
          name: String.t(),
          slug: String.t(),
          friendly_name: String.t() | nil,
          brief: String.t(),
          description: String.t(),
          purpose: String.t(),
          category: String.t() | nil,
          labels: [String.t()],
          require: [String.t()],
          syntax: [map()],
          examples: [map()]
        }

  @spec sections() :: {:ok, [map()]} | {:error, String.t()}
  def sections do
    order = NoizuPromptLingua.NPL.section_order()

    list =
      order
      |> Enum.map(fn section ->
        case read_section(section) do
          {:ok, data} ->
            components = Map.get(data, "components", [])

            %{
              section: section,
              title: Map.get(data, "title") || humanize(section),
              name: Map.get(data, "name", section),
              slug: Map.get(data, "slug", section),
              brief: String.trim(Map.get(data, "brief", "")),
              description: String.trim(Map.get(data, "description", "")),
              component_count: length(components),
              category_count: length(Map.get(data, "categories", []))
            }

          {:error, _} ->
            %{
              section: section,
              title: humanize(section),
              name: section,
              slug: section,
              brief: "",
              description: "",
              component_count: 0,
              category_count: 0
            }
        end
      end)

    {:ok, list}
  end

  @doc """
  List component summaries across all (or one) sections.
  Summaries exclude heavy example/thread payloads — use `component/2` for detail.
  """
  @spec components(String.t() | nil) :: {:ok, [component_summary()]} | {:error, String.t()}
  def components(section_filter \\ nil) do
    sections =
      if section_filter && section_filter != "" do
        [section_filter]
      else
        NoizuPromptLingua.NPL.section_order()
      end

    list =
      sections
      |> Enum.flat_map(fn section ->
        case read_section(section) do
          {:ok, data} ->
            data
            |> Map.get("components", [])
            |> Enum.map(&to_summary(section, &1))

          {:error, _} ->
            []
        end
      end)

    {:ok, list}
  end

  @spec component(String.t(), String.t()) :: {:ok, component_detail()} | {:error, :not_found}
  def component(section, slug) do
    with {:ok, data} <- read_section(section) do
      components = Map.get(data, "components", [])

      case Enum.find(components, fn c ->
             Map.get(c, "slug", Map.get(c, "name", "")) == slug
           end) do
        nil ->
          {:error, :not_found}

        comp ->
          {:ok, to_detail(section, comp)}
      end
    end
  end

  @doc """
  The full label taxonomy from npl.yaml (scope/function/domain/priority/etc.).
  """
  @spec labels() :: {:ok, map()} | {:error, String.t()}
  def labels do
    npl_path = Path.join(NoizuPromptLingua.NPL.conventions_dir(), "npl.yaml")

    case YamlElixir.read_from_file(npl_path) do
      {:ok, data} ->
        npl = Map.get(data, "/npl", %{})
        taxonomy = get_in(npl, ["labels", "taxonomy"]) || %{}
        {:ok, taxonomy}

      {:error, reason} ->
        {:error, "Failed to load npl.yaml: #{inspect(reason)}"}
    end
  end

  @doc """
  Convenience for the MCP detail lookup and the controller: a flat list of
  {section, slug, name} triples for fast client-side search indexes.
  """
  @spec index() :: {:ok, [map()]}
  def index do
    {:ok, summaries} = components(nil)

    {:ok,
     Enum.map(summaries, fn s ->
       %{
         section: s.section,
         slug: s.slug,
         name: s.name,
         friendly_name: s.friendly_name,
         brief: s.brief,
         labels: s.labels,
         category: s.category
       }
     end)}
  end

  # ---------------------------------------------------------------------------
  # Internal helpers
  # ---------------------------------------------------------------------------

  defp read_section(section) do
    case Map.get(@section_files, section) do
      nil ->
        {:error, "Unknown section: '#{section}'"}

      filename ->
        filepath = Path.join(NoizuPromptLingua.NPL.conventions_dir(), filename)

        if File.exists?(filepath) do
          YamlElixir.read_from_file(filepath)
        else
          {:error, "Section file not found: #{filepath}"}
        end
    end
  end

  defp to_summary(section, comp) do
    %{
      section: section,
      name: Map.get(comp, "name", ""),
      slug: Map.get(comp, "slug", Map.get(comp, "name", "")),
      friendly_name: Map.get(comp, "friendly-name"),
      brief: String.trim(Map.get(comp, "brief", "")),
      labels: Map.get(comp, "labels", []),
      category: Map.get(comp, "category")
    }
  end

  defp to_detail(section, comp) do
    examples =
      comp
      |> Map.get("examples", [])
      |> Enum.map(&normalize_example/1)

    %{
      section: section,
      name: Map.get(comp, "name", ""),
      slug: Map.get(comp, "slug", Map.get(comp, "name", "")),
      friendly_name: Map.get(comp, "friendly-name"),
      brief: String.trim(Map.get(comp, "brief", "")),
      description: String.trim(Map.get(comp, "description", "")),
      purpose: String.trim(Map.get(comp, "purpose", "")),
      category: Map.get(comp, "category"),
      labels: Map.get(comp, "labels", []),
      require: normalize_requires(Map.get(comp, "require", [])),
      syntax: normalize_syntax(Map.get(comp, "syntax", [])),
      examples: examples
    }
  end

  defp normalize_syntax(syntax) when is_list(syntax) do
    Enum.map(syntax, fn syn ->
      %{
        name: Map.get(syn, "name", ""),
        syntax: Map.get(syn, "syntax", ""),
        description: String.trim(Map.get(syn, "description", ""))
      }
    end)
  end

  defp normalize_syntax(_), do: []

  defp normalize_requires(requires) when is_list(requires) do
    Enum.map(requires, fn
      r when is_binary(r) -> r
      r -> to_string(r)
    end)
  end

  defp normalize_requires(_), do: []

  defp normalize_example(ex) do
    %{
      name: Map.get(ex, "name", Map.get(ex, "title", "")),
      brief: String.trim(Map.get(ex, "brief", "")),
      description: String.trim(Map.get(ex, "description", "")),
      priority: Map.get(ex, "priority", 0),
      example: Map.get(ex, "example", ""),
      thread: normalize_thread(Map.get(ex, "thread", [])),
      labels: Map.get(ex, "labels", []),
      covers: Map.get(ex, "covers", [])
    }
  end

  defp normalize_thread(thread) when is_list(thread) do
    Enum.map(thread, fn msg ->
      %{
        role: Map.get(msg, "role", ""),
        message: Map.get(msg, "message", "")
      }
    end)
  end

  defp normalize_thread(_), do: []

  defp humanize(section) do
    section
    |> String.replace("-", " ")
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
