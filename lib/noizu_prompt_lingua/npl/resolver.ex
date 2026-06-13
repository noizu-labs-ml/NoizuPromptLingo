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
    "pumps" => "pumps.yaml",
    "fences" => "fences.yaml"
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
      priority_filtered: false
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
            priority_filtered: boolean()
          }
  end

  defstruct [:npl_dir, cache: %{}]

  @type t :: %__MODULE__{npl_dir: String.t(), cache: map()}

  @spec new(String.t()) :: t()
  def new(npl_dir), do: %__MODULE__{npl_dir: npl_dir}

  @spec resolve(t(), Expression.t()) :: {:ok, [ResolvedComponent.t()]} | {:error, String.t()}
  def resolve(resolver, %Expression{} = expression) do
    with {:ok, resolver, components_map} <- process_additions(resolver, expression.additions),
         {:ok, resolver, components_map} <- process_subtractions(resolver, expression.subtractions, components_map) do
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
    new_map =
      Enum.reduce(subtractions, components_map, fn sub, map ->
        if sub.component == nil do
          Map.reject(map, fn {{section, _slug}, _comp} -> section == sub.section end)
        else
          key = {sub.section, sub.component}

          if Map.has_key?(map, key) do
            Map.delete(map, key)
          else
            Logger.warning(
              "Cannot subtract '#{sub.component}' from '#{sub.section}' - not in loaded set. Ignoring."
            )

            map
          end
        end
      end)

    {:ok, resolver, new_map}
  end

  defp build_ordered_result(resolver, additions, components_map) do
    {result, _seen} =
      Enum.reduce(additions, {[], MapSet.new()}, fn addition, {acc, seen} ->
        if addition.component == nil do
          case load_section(resolver, addition.section) do
            {:ok, _resolver, data} ->
              components_data = Map.get(data, "components", [])

              Enum.reduce(components_data, {acc, seen}, fn comp_data, {inner_acc, inner_seen} ->
                slug = Map.get(comp_data, "slug", Map.get(comp_data, "name", ""))
                key = {addition.section, slug}

                if Map.has_key?(components_map, key) and not MapSet.member?(inner_seen, key) do
                  {[components_map[key] | inner_acc], MapSet.put(inner_seen, key)}
                else
                  {inner_acc, inner_seen}
                end
              end)

            {:error, _} ->
              {acc, seen}
          end
        else
          key = {addition.section, addition.component}

          if Map.has_key?(components_map, key) and not MapSet.member?(seen, key) do
            {[components_map[key] | acc], MapSet.put(seen, key)}
          else
            {acc, seen}
          end
        end
      end)

    Enum.reverse(result)
  end

  defp resolve_single(resolver, %Component{} = component) do
    with {:ok, resolver, data} <- load_section(resolver, component.section) do
      components_data = Map.get(data, "components", [])

      if component.component == nil do
        resolved =
          Enum.map(components_data, fn comp_data ->
            resolve_component(component.section, comp_data, component.priority_max)
          end)

        {:ok, resolver, resolved}
      else
        slug_match = fn c ->
          Map.get(c, "slug", Map.get(c, "name", "")) == component.component
        end

        case Enum.find(components_data, slug_match) do
          nil ->
            available =
              components_data
              |> Enum.map(&Map.get(&1, "slug", Map.get(&1, "name", "")))
              |> Enum.filter(&(&1 != ""))
              |> Enum.join(", ")

            {:error,
             "Component '#{component.component}' not found in section '#{component.section}'. Available components: #{available}"}

          comp_data ->
            {:ok, resolver, [resolve_component(component.section, comp_data, component.priority_max)]}
        end
      end
    end
  end

  defp resolve_component(section, comp_data, priority_max) do
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
      priority_filtered: priority_filtered
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
