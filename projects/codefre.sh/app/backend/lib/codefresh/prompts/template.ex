defmodule Codefresh.Prompts.Template do
  @moduledoc """
  Parses and validates `{{var_name}}` placeholders in prompt bodies.

  Rules:

    * Variable names match `[A-Za-z_][A-Za-z0-9_]*`
    * Surrounding whitespace inside `{{ ... }}` is allowed
    * A declared variable that never appears in the body is a warning (still valid)
    * An `{{extracted}}` variable with no declaration fails validation on publish
  """

  @var_regex ~r/\{\{\s*([A-Za-z_][A-Za-z0-9_]*)\s*\}\}/
  @block_regex ~r/\{%\s*(if|for|endif|endfor)\b([^%]*?)%\}/
  @for_head_regex ~r/^\s*([A-Za-z_][A-Za-z0-9_]*)\s+in\s+([A-Za-z_][A-Za-z0-9_]*)\s*$/

  @doc """
  Returns the set of unique variable names referenced by the body — including
  names used by `{{var}}`, `{% if var %}`, and the *collection* side of
  `{% for x in list %}`. Loop-local iteration names (the `x`) are excluded.
  """
  def extract_vars(body) when is_binary(body) do
    simple =
      @var_regex
      |> Regex.scan(body, capture: :all_but_first)
      |> List.flatten()

    block_vars = extract_block_vars(body)

    loop_locals = extract_loop_locals(body)

    simple
    |> Enum.concat(block_vars)
    |> Enum.reject(&(&1 in loop_locals))
    |> MapSet.new()
  end

  defp extract_block_vars(body) do
    @block_regex
    |> Regex.scan(body)
    |> Enum.flat_map(fn
      [_, "if", rest] ->
        name = rest |> String.trim() |> String.split() |> List.first()
        if valid_ident?(name), do: [name], else: []

      [_, "for", rest] ->
        case Regex.run(@for_head_regex, rest) do
          [_, _local, list] -> [list]
          _ -> []
        end

      _ ->
        []
    end)
  end

  defp extract_loop_locals(body) do
    @block_regex
    |> Regex.scan(body)
    |> Enum.flat_map(fn
      [_, "for", rest] ->
        case Regex.run(@for_head_regex, rest) do
          [_, local, _] -> [local]
          _ -> []
        end

      _ ->
        []
    end)
    |> MapSet.new()
  end

  defp valid_ident?(nil), do: false
  defp valid_ident?(s) when is_binary(s), do: Regex.match?(~r/^[A-Za-z_][A-Za-z0-9_]*$/, s)

  @doc """
  Validate declared vars against vars found in the body.

  Returns `:ok` or `{:error, {:undeclared_vars, [name, ...]}}`.
  """
  def validate(body, declared_vars) when is_binary(body) and is_map(declared_vars) do
    extracted = extract_vars(body)
    declared_keys = declared_vars |> Map.keys() |> Enum.map(&to_string/1) |> MapSet.new()

    undeclared = MapSet.difference(extracted, declared_keys)

    if MapSet.size(undeclared) == 0 do
      :ok
    else
      {:error, {:undeclared_vars, Enum.sort(MapSet.to_list(undeclared))}}
    end
  end

  @doc """
  Render a prompt body. Handles `{{var}}` substitution plus minimal control flow:

    * `{% if name %}...{% endif %}` — emitted only when `name` binds truthy
    * `{% for x in list %}...{% endfor %}` — iterates over `list` with `x` as the
      loop-local name; body within the loop can use `{{x}}`

  Missing bindings fall back to declared defaults; required-and-unbound returns
  `{:error, {:missing_required_vars, [...]}}`. Blocks can nest; parsing is
  left-associative.
  """
  def render(body, declared_vars, bindings \\ %{}) do
    bindings_s = stringify_keys(bindings)

    missing_required =
      for {name, spec} <- declared_vars,
          required?(spec),
          not Map.has_key?(bindings_s, to_string(name)),
          is_nil(default_of(spec)),
          do: to_string(name)

    if missing_required != [] do
      {:error, {:missing_required_vars, Enum.sort(missing_required)}}
    else
      {:ok, render_blocks(body, declared_vars, bindings_s)}
    end
  end

  # Render control-flow blocks then simple substitution.
  defp render_blocks(body, declared_vars, bindings) do
    body
    |> expand_blocks(declared_vars, bindings)
    |> substitute_vars(declared_vars, bindings)
  end

  defp expand_blocks(body, declared_vars, bindings) do
    # Greedy but balanced: find the first {% if %} or {% for %}, find its matching
    # close, recurse on the inner body, then continue.
    case find_first_block(body) do
      nil ->
        body

      {:if, pre, var, inner, post} ->
        rendered_inner =
          if truthy?(Map.get(bindings, var)),
            do: expand_blocks(inner, declared_vars, bindings),
            else: ""

        pre <> rendered_inner <> expand_blocks(post, declared_vars, bindings)

      {:for, pre, local, list_name, inner, post} ->
        list = Map.get(bindings, list_name) || []

        rendered_items =
          list
          |> List.wrap()
          |> Enum.map(fn item ->
            inner_bindings = Map.put(bindings, local, item)

            expand_blocks(inner, declared_vars, inner_bindings)
            |> substitute_vars(declared_vars, inner_bindings)
          end)
          |> Enum.join("")

        pre <> rendered_items <> expand_blocks(post, declared_vars, bindings)
    end
  end

  # Scans for the first top-level {% if %} or {% for %} and returns its parts.
  defp find_first_block(body) do
    case Regex.run(~r/\{%\s*(if|for)\b([^%]*?)%\}/, body, return: :index) do
      nil ->
        nil

      [{open_start, open_len}, {_kw_s, _kw_l}, _rest_pos] ->
        open_end = open_start + open_len

        inner_tag =
          binary_part(body, open_start + 2, open_len - 4)
          |> String.trim()

        kw =
          inner_tag
          |> String.split()
          |> List.first()

        rest =
          inner_tag
          |> String.trim_leading(kw)
          |> String.trim()

        case find_matching_close(body, open_end, kw) do
          nil ->
            nil

          {close_start, close_end} ->
            pre = binary_part(body, 0, open_start)
            inner = binary_part(body, open_end, close_start - open_end)
            post = binary_part(body, close_end, byte_size(body) - close_end)

            case kw do
              "if" ->
                var = rest |> String.trim() |> String.split() |> List.first()
                if valid_ident?(var), do: {:if, pre, var, inner, post}, else: nil

              "for" ->
                case Regex.run(@for_head_regex, rest) do
                  [_, local, list_name] -> {:for, pre, local, list_name, inner, post}
                  _ -> nil
                end
            end
        end
    end
  end

  # Finds the byte-index span of the matching endif/endfor, honoring nesting.
  defp find_matching_close(body, from, kw) do
    close_kw = "end" <> kw
    scan_for_match(body, from, kw, close_kw, 1)
  end

  defp scan_for_match(body, from, open_kw, close_kw, depth) do
    slice = binary_part(body, from, byte_size(body) - from)

    case Regex.run(
           ~r/\{%\s*(#{open_kw}|#{close_kw})\b[^%]*?%\}/,
           slice,
           return: :index
         ) do
      nil ->
        nil

      [{s, l}, _] ->
        tag = binary_part(slice, s, l)
        is_open = String.contains?(tag, open_kw) and not String.contains?(tag, close_kw)

        new_depth = if is_open, do: depth + 1, else: depth - 1
        abs_start = from + s
        abs_end = abs_start + l

        if new_depth == 0 do
          {abs_start, abs_end}
        else
          scan_for_match(body, abs_end, open_kw, close_kw, new_depth)
        end
    end
  end

  defp substitute_vars(body, declared_vars, bindings) do
    Regex.replace(@var_regex, body, fn _, var ->
      case Map.get(bindings, var) do
        nil ->
          to_string(
            default_of(
              Map.get(declared_vars, var) || Map.get(declared_vars, String.to_atom(var)) ||
                %{}
            ) || ""
          )

        val ->
          to_string(val)
      end
    end)
  end

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(""), do: false
  defp truthy?([]), do: false
  defp truthy?(%{} = m) when map_size(m) == 0, do: false
  defp truthy?(_), do: true

  defp required?(%{"required" => true}), do: true
  defp required?(%{required: true}), do: true
  defp required?(_), do: false

  defp default_of(%{"default" => d}), do: d
  defp default_of(%{default: d}), do: d
  defp default_of(_), do: nil

  defp stringify_keys(m) do
    for {k, v} <- m, into: %{}, do: {to_string(k), v}
  end
end
