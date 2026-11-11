defmodule NoizuPromptLingua.NPL.Resolver do
  @moduledoc false

  alias NoizuPromptLingua.NPL.Parser.{Component, Expression}

  require Logger

  @section_files %{
    "syntax" => "syntax.yaml",
    "declarations" => "declarations.yaml",
    "directives" => "directives.yaml",
    "prefixes" => "prefixes.yaml",
    "prompt-sections" => "prompt-sections.yaml",
    "special-sections" => "special-sections.yaml",
    "pumps" => "pumps.yaml"
  }

  defmodule ResolvedComponent do
    @moduledoc false
    defstruct [
      :section,
      :name,
      :slug,
      :brief,
      :description,
      syntax: [],
      examples: [],
      labels: [],
      require: [],
      priority_filtered: false,
      matched_alias: nil,
      content: nil
    ]

    @type t :: %__MODULE__{
            section: String.t(),
            name: String.t(),
            slug: String.t(),
            brief: String.t(),
            description: String.t(),
            syntax: [map()],
            examples: [map()],
            labels: [String.t()],
            require: [String.t()],
            priority_filtered: boolean(),
            matched_alias: String.t() | nil,
            content: String.t() | nil
          }
  end

  defstruct [:npl_dir, cache: %{}]

  @type t :: %__MODULE__{npl_dir: String.t(), cache: map()}

  @spec new(String.t()) :: t()
  def new(npl_dir), do: %__MODULE__{npl_dir: npl_dir}

  @spec resolve(t(), Expression.t()) :: {:ok, [ResolvedComponent.t()]} | {:error, String.t()}
  def resolve(resolver, %Expression{} = expression) do
    with {:ok, resolver, components_map} <- process_additions(resolver, expression.additions),
         {:ok, resolver, components_map} <-
           process_subtractions(resolver, expression.subtractions, components_map) do
      result = build_ordered_result(resolver, expression.additions, components_map)
      {:ok, result}
    end
  end

  defp process_additions(resolver, additions) do
    Enum.reduce_while(additions, {:ok, resolver, %{}}, fn addition, {:ok, res, map} ->
      case resolve_single(res, addition) do
        {:ok, res, resolved} ->
          new_map =
            Enum.reduce(resolved, map, fn comp, acc ->
              Map.put(acc, {comp.section, comp.slug}, comp)
            end)

          {:cont, {:ok, res, new_map}}

        {:error, _} = err ->
          {:halt, err}
      end
    end)
  end

  defp process_subtractions(resolver, subtractions, components_map) do
    {resolver, new_map} =
      Enum.reduce(subtractions, {resolver, components_map}, fn sub, {res, map} ->
        if sub.component == nil do
          {res, Map.reject(map, fn {{section, _slug}, _comp} -> section == sub.section end)}
        else
          {res, canonical} = canonical_component_id(res, sub.section, sub.component)
          key = {sub.section, canonical}

          if Map.has_key?(map, key) do
            {res, Map.delete(map, key)}
          else
            Logger.warning(
              "Cannot subtract '#{sub.component}' from '#{sub.section}' - not in loaded set. Ignoring."
            )

            {res, map}
          end
        end
      end)

    {:ok, resolver, new_map}
  end

  defp build_ordered_result(resolver, additions, components_map) do
    {result, _seen, _resolver} =
      Enum.reduce(additions, {[], MapSet.new(), resolver}, fn addition, {acc, seen, res} ->
        if addition.component == nil do
          case load_section(res, addition.section) do
            {:ok, res, data} ->
              components_data = Map.get(data, "components", [])

              Enum.reduce(components_data, {acc, seen, res}, fn comp_data,
                                                                {inner_acc, inner_seen, res} ->
                slug = Map.get(comp_data, "slug", Map.get(comp_data, "name", ""))
                key = {addition.section, slug}

                if Map.has_key?(components_map, key) and not MapSet.member?(inner_seen, key) do
                  {[components_map[key] | inner_acc], MapSet.put(inner_seen, key), res}
                else
                  {inner_acc, inner_seen, res}
                end
              end)

            {:error, _} ->
              {acc, seen, res}
          end
        else
          {res, canonical} = canonical_component_id(res, addition.section, addition.component)
          key = {addition.section, canonical}

          if Map.has_key?(components_map, key) and not MapSet.member?(seen, key) do
            {[components_map[key] | acc], MapSet.put(seen, key), res}
          else
            {acc, seen, res}
          end
        end
      end)

    Enum.reverse(result)
  end

  # Map an explicit-id term (canonical slug, component alias, or instructional
  # slug) to the canonical slug so addition/subtraction keys line up with the
  # resolved component map. Falls back to the id itself when nothing matches
  # (e.g. a missing section file, whose error surfaces elsewhere).
  defp canonical_component_id(resolver, section, id) do
    case load_section(resolver, section) do
      {:ok, res, data} ->
        entry =
          Enum.find(Map.get(data, "components", []), &id_matches?(&1, id)) ||
            Enum.find(Map.get(data, "instructional", []), &id_matches?(&1, id))

        if entry, do: {res, canonical_id(entry)}, else: {res, id}

      {:error, _} ->
        {resolver, id}
    end
  end

  defp resolve_single(resolver, %Component{} = component) do
    with {:ok, resolver, data} <- load_section(resolver, component.section) do
      components_data = Map.get(data, "components", [])
      instructional_data = Map.get(data, "instructional", [])

      if component.component == nil do
        # Whole-section load: `components` only. Instructional entries are
        # addressable by explicit id but deliberately excluded here (token
        # guard) so `pumps` never drags in the whole instruction corpus.
        resolved =
          Enum.map(components_data, fn comp_data ->
            resolve_component(component.section, comp_data, component.priority_max)
          end)

        {:ok, resolver, resolved}
      else
        wanted = component.component

        case Enum.find(components_data, &id_matches?(&1, wanted)) do
          nil ->
            case Enum.find(instructional_data, &id_matches?(&1, wanted)) do
              nil ->
                {:error,
                 not_found_message(component.section, wanted, components_data, instructional_data)}

              entry ->
                {:ok, resolver,
                 [resolve_instructional(component.section, entry, wanted, component.priority_max)]}
            end

          comp_data ->
            {:ok, resolver,
             [resolve_component(component.section, comp_data, component.priority_max, wanted)]}
        end
      end
    end
  end

  # Canonical id (slug, falling back to name) plus declared `aliases:`.
  defp id_matches?(entry, id) do
    canonical_id(entry) == id or id in aliases_of(entry)
  end

  defp canonical_id(entry) do
    Map.get(entry, "slug", Map.get(entry, "name", ""))
  end

  defp aliases_of(entry) do
    case Map.get(entry, "aliases", []) do
      list when is_list(list) -> list
      _ -> []
    end
  end

  defp not_found_message(section, wanted, components_data, instructional_data) do
    known =
      (components_data ++ instructional_data)
      |> Enum.map(&Map.get(&1, "slug", Map.get(&1, "name", "")))
      |> Enum.filter(&(&1 != ""))
      |> Enum.sort()
      |> Enum.join(", ")

    aliases =
      (components_data ++ instructional_data)
      |> Enum.flat_map(&aliases_of/1)
      |> Enum.sort()
      |> Enum.join(", ")

    base =
      "Component '#{wanted}' not found in section '#{section}'. Available components: #{known}"

    if aliases == "" do
      base
    else
      base <> ". Available aliases: #{aliases}"
    end
  end

  defp resolve_instructional(section, entry, wanted, _priority_max) do
    canonical = canonical_id(entry)

    %ResolvedComponent{
      section: section,
      name: Map.get(entry, "name", ""),
      slug: canonical,
      brief: Map.get(entry, "brief", ""),
      description: Map.get(entry, "description", ""),
      labels: Map.get(entry, "labels", []),
      examples: [],
      syntax: [],
      content: Map.get(entry, "content", ""),
      matched_alias: if(canonical != wanted, do: wanted, else: nil),
      priority_filtered: false
    }
  end

  defp resolve_component(section, comp_data, priority_max, wanted \\ nil) do
    examples = Map.get(comp_data, "examples", [])

    {filtered_examples, priority_filtered} =
      case priority_max do
        nil ->
          {examples, false}

        max when max < 0 ->
          {[], true}

        max ->
          filtered = Enum.filter(examples, fn ex -> Map.get(ex, "priority", 0) <= max end)
          {filtered, true}
      end

    %ResolvedComponent{
      section: section,
      name: Map.get(comp_data, "name", ""),
      slug: Map.get(comp_data, "slug", Map.get(comp_data, "name", "")),
      brief: Map.get(comp_data, "brief", ""),
      description: Map.get(comp_data, "description", ""),
      syntax: Map.get(comp_data, "syntax", []),
      examples: filtered_examples,
      labels: Map.get(comp_data, "labels", []),
      require: Map.get(comp_data, "require", []),
      priority_filtered: priority_filtered,
      matched_alias:
        if(wanted != nil and wanted != canonical_id(comp_data), do: wanted, else: nil)
    }
  end

  defp load_section(%__MODULE__{cache: cache} = resolver, section) do
    case Map.fetch(cache, section) do
      {:ok, data} ->
        {:ok, resolver, data}

      :error ->
        filename = Map.get(@section_files, section)

        if filename == nil do
          {:error, "Unknown section: '#{section}'"}
        else
          filepath = Path.join(resolver.npl_dir, filename)

          if File.exists?(filepath) do
            case YamlElixir.read_from_file(filepath) do
              {:ok, data} ->
                new_resolver = %{resolver | cache: Map.put(cache, section, data)}
                {:ok, new_resolver, data}

              {:error, reason} ->
                {:error, "Invalid YAML in #{filename}: #{inspect(reason)}"}
            end
          else
            {:error, "Section file not found: #{filename}. Expected at: #{filepath}"}
          end
        end
    end
  end
end
