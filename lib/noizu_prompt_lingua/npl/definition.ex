defmodule NoizuPromptLingua.NPL.Definition do
  @moduledoc false

  alias NoizuPromptLingua.NPL.ConventionFormatter

  defstruct [:conventions_dir, :version, :description, :concepts, :section_order, :dep_graph, :convention_components]

  @type t :: %__MODULE__{}

  @spec new(String.t() | nil) :: {:ok, t()} | {:error, String.t()}
  def new(conventions_dir \\ nil) do
    conventions_dir = conventions_dir || NoizuPromptLingua.NPL.conventions_dir()

    npl_path = Path.join(conventions_dir, "npl.yaml")

    case YamlElixir.read_from_file(npl_path) do
      {:ok, data} ->
        npl = Map.get(data, "/npl", %{})
        raw_version = Map.get(npl, "version", "1.0")

        version =
          cond do
            is_float(raw_version) -> :erlang.float_to_binary(raw_version, decimals: 1)
            true -> to_string(raw_version)
          end

        {:ok,
         %__MODULE__{
           conventions_dir: conventions_dir,
           version: version,
           description: String.trim(Map.get(npl, "description", "")),
           concepts: Map.get(npl, "concepts", []),
           section_order: get_in(npl, ["section_order", "components"]) || [],
           dep_graph: nil,
           convention_components: nil
         }}

      {:error, reason} ->
        {:error, "Failed to load npl.yaml: #{inspect(reason)}"}
    end
  end

  @spec format(t(), keyword()) :: String.t()
  def format(%__MODULE__{} = defn, opts \\ []) do
    components = Keyword.get(opts, :components, nil)
    rendered = Keyword.get(opts, :rendered, nil)
    component_priority = Keyword.get(opts, :component_priority, 0)
    example_priority = Keyword.get(opts, :example_priority, 0)
    extension = Keyword.get(opts, :extension, false)
    flags = Keyword.get(opts, :flags, %{})

    version = defn.version

    {open_marker, close_marker} =
      if extension do
        {"⌜extend:NPL@#{version}⌝", "⌞extend:NPL@#{version}⌟"}
      else
        {"⌜NPL@#{version}⌝", "⌞NPL@#{version}⌟"}
      end

    rendered_keys = if rendered, do: parse_rendered_specs(rendered), else: MapSet.new()

    conv_map =
      if components == nil do
        nil
      else
        parse_component_specs(components, component_priority, example_priority)
      end

    conv_map =
      if conv_map != nil do
        resolve_dependencies(defn, conv_map, rendered_keys)
      else
        conv_map
      end

    result = "#{open_marker}\n# Noizu Prompt Lingua (NPL)\n#{defn.description}\n\n"

    result =
      result <>
        "## Core Concepts\n\n" <>
        Enum.map_join(defn.concepts, "", fn concept ->
          name = Map.get(concept, "name", "")
          desc = String.trim(Map.get(concept, "description", ""))
          "**#{name}**\n: #{desc}\n\n"
        end)

    conventions_to_render = build_render_list(defn, conv_map, component_priority, example_priority)

    result =
      Enum.reduce(conventions_to_render, result, fn {conv_name, conv_components, cp, ep}, acc ->
        conv_rendered =
          rendered_keys
          |> Enum.filter(&String.starts_with?(&1, "#{conv_name}."))
          |> Enum.map(fn key ->
            [_conv, comp] = String.split(key, ".", parts: 2)
            comp
          end)
          |> MapSet.new()

        rendered_set = if MapSet.size(conv_rendered) > 0, do: MapSet.to_list(conv_rendered), else: nil

        section =
          ConventionFormatter.format_convention(conv_name,
            conventions_dir: defn.conventions_dir,
            components: conv_components,
            rendered_components: rendered_set,
            component_priority: cp,
            example_priority: ep,
            flags: flags,
            heading_offset: 1
          )

        acc <> section
      end)

    result <> "\n#{close_marker}\n"
  end

  defp build_render_list(defn, nil, component_priority, example_priority) do
    Enum.map(defn.section_order, fn conv ->
      {conv, nil, component_priority, example_priority}
    end)
  end

  defp build_render_list(defn, conv_map, _component_priority, _example_priority) do
    {ordered, rendered_convs} =
      Enum.reduce(defn.section_order, {[], MapSet.new()}, fn conv, {acc, seen} ->
        case Map.fetch(conv_map, conv) do
          {:ok, {comp_names, cp, ep}} ->
            {[{conv, comp_names, cp, ep} | acc], MapSet.put(seen, conv)}

          :error ->
            {acc, seen}
        end
      end)

    extras =
      conv_map
      |> Enum.reject(fn {conv, _} -> MapSet.member?(rendered_convs, conv) end)
      |> Enum.map(fn {conv, {comp_names, cp, ep}} -> {conv, comp_names, cp, ep} end)

    Enum.reverse(ordered) ++ extras
  end

  defp parse_component_specs(specs, default_cp, default_ep) do
    Enum.reduce(specs, %{}, fn spec, acc ->
      {raw, cp, ep} = extract_spec(spec, default_cp, default_ep)
      raw = String.trim(raw)

      if raw == "*" do
        acc
      else
        {convention, comps} =
          if String.contains?(raw, ":") do
            [conv, comp_str] = String.split(raw, ":", parts: 2)
            conv = String.trim(conv)
            comp_str = String.trim(comp_str)

            if comp_str == "*" do
              {conv, nil}
            else
              comps = comp_str |> String.split(",") |> Enum.map(&String.trim/1) |> Enum.filter(&(&1 != ""))
              {conv, comps}
            end
          else
            {raw, nil}
          end

        case Map.fetch(acc, convention) do
          {:ok, {existing_comps, existing_cp, existing_ep}} ->
            merged =
              cond do
                existing_comps == nil or comps == nil -> nil
                true -> existing_comps ++ comps
              end

            Map.put(acc, convention, {merged, max(existing_cp, cp), max(existing_ep, ep)})

          :error ->
            Map.put(acc, convention, {comps, cp, ep})
        end
      end
    end)
  end

  defp parse_rendered_specs(specs) do
    Enum.reduce(specs, MapSet.new(), fn spec, acc ->
      {raw, _cp, _ep} = extract_spec(spec, 0, 0)
      raw = String.trim(raw)

      if String.contains?(raw, ":") do
        [convention, comp_str] = String.split(raw, ":", parts: 2)
        convention = String.trim(convention)

        comp_str
        |> String.split(",")
        |> Enum.map(&String.trim/1)
        |> Enum.filter(&(&1 != ""))
        |> Enum.reduce(acc, fn comp, inner_acc ->
          MapSet.put(inner_acc, "#{convention}.#{comp}")
        end)
      else
        acc
      end
    end)
  end

  defp extract_spec(%{spec: spec, component_priority: cp, example_priority: ep}, _default_cp, _default_ep) do
    {spec, cp, ep}
  end

  defp extract_spec(spec, default_cp, default_ep) when is_binary(spec) do
    {spec, default_cp, default_ep}
  end

  defp load_dependency_graph(%__MODULE__{dep_graph: graph} = defn) when graph != nil, do: defn

  defp load_dependency_graph(%__MODULE__{} = defn) do
    {dep_graph, convention_components} =
      Enum.reduce(defn.section_order, {%{}, %{}}, fn conv_name, {dg, cc} ->
        yaml_path = Path.join(defn.conventions_dir, "#{conv_name}.yaml")

        case YamlElixir.read_from_file(yaml_path) do
          {:ok, data} ->
            comps = Map.get(data, "components", [])
            comp_names = Enum.map(comps, &Map.get(&1, "name", ""))

            new_dg =
              Enum.reduce(comps, dg, fn c, acc ->
                key = "#{conv_name}.#{Map.get(c, "name", "")}"
                Map.put(acc, key, Map.get(c, "require", []))
              end)

            {new_dg, Map.put(cc, conv_name, comp_names)}

          {:error, _} ->
            {dg, cc}
        end
      end)

    %{defn | dep_graph: dep_graph, convention_components: convention_components}
  end

  defp resolve_dependencies(defn, conv_map, rendered_keys) do
    defn = load_dependency_graph(defn)

    expanded =
      Map.new(conv_map, fn {conv, {comps, cp, ep}} ->
        actual = if comps == nil, do: Map.get(defn.convention_components, conv, []), else: comps
        {conv, {actual, cp, ep}}
      end)

    {included, priorities} =
      Enum.reduce(expanded, {MapSet.new(), %{}}, fn {conv, {comps, cp, ep}}, {inc, pri} ->
        Enum.reduce(comps, {inc, pri}, fn comp, {inner_inc, inner_pri} ->
          key = "#{conv}.#{comp}"

          new_pri =
            case Map.fetch(inner_pri, key) do
              {:ok, {old_cp, old_ep}} -> Map.put(inner_pri, key, {max(old_cp, cp), max(old_ep, ep)})
              :error -> Map.put(inner_pri, key, {cp, ep})
            end

          {MapSet.put(inner_inc, key), new_pri}
        end)
      end)

    {included, priorities} = walk_dependencies(defn.dep_graph, included, priorities, rendered_keys)

    Enum.reduce(included, %{}, fn key, acc ->
      [conv, comp] = String.split(key, ".", parts: 2)
      {cp, ep} = Map.get(priorities, key, {0, 0})

      case Map.fetch(acc, conv) do
        {:ok, {existing_comps, existing_cp, existing_ep}} ->
          Map.put(acc, conv, {[comp | existing_comps], max(existing_cp, cp), max(existing_ep, ep)})

        :error ->
          Map.put(acc, conv, {[comp], cp, ep})
      end
    end)
  end

  defp walk_dependencies(dep_graph, included, priorities, rendered_keys) do
    new_included = included
    new_priorities = priorities

    {changed, new_included, new_priorities} =
      Enum.reduce(MapSet.to_list(included), {false, new_included, new_priorities}, fn key, {ch, inc, pri} ->
        reqs = Map.get(dep_graph, key, [])
        {cp, ep} = Map.get(pri, key, {0, 0})

        Enum.reduce(reqs, {ch, inc, pri}, fn req, {inner_ch, inner_inc, inner_pri} ->
          cond do
            MapSet.member?(rendered_keys, req) ->
              {inner_ch, inner_inc, inner_pri}

            not MapSet.member?(inner_inc, req) ->
              {true, MapSet.put(inner_inc, req), Map.put(inner_pri, req, {cp, ep})}

            true ->
              {old_cp, old_ep} = Map.get(inner_pri, req, {0, 0})
              new_cp = max(old_cp, cp)
              new_ep = max(old_ep, ep)

              if new_cp > old_cp or new_ep > old_ep do
                {true, inner_inc, Map.put(inner_pri, req, {new_cp, new_ep})}
              else
                {inner_ch, inner_inc, inner_pri}
              end
          end
        end)
      end)

    if changed do
      walk_dependencies(dep_graph, new_included, new_priorities, rendered_keys)
    else
      {new_included, new_priorities}
    end
  end
end
