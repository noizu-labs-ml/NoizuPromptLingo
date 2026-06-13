defmodule DirenvConfig.Path do
  @type segment ::
          {:key, String.t()}
          | {:index, integer()}
          | :wildcard
          | :length

  @spec parse(String.t()) :: [segment()]
  def parse(path) when is_binary(path) do
    if path == "" do
      []
    else
      path
      |> String.split(".")
      |> parse_tokens([], false)
    end
  end

  defp parse_tokens([], acc, _has_prev), do: Enum.reverse(acc)

  defp parse_tokens([token | rest], acc, has_prev) do
    if token == "length" and has_prev do
      parse_tokens(rest, [:length | acc], true)
    else
      segments = parse_token(token)
      parse_tokens(rest, Enum.reverse(segments) ++ acc, true)
    end
  end

  defp parse_token(token) do
    case :binary.match(token, "[") do
      :nomatch ->
        [{:key, token}]

      {pos, _} ->
        key_part = binary_part(token, 0, pos)
        bracket_part = binary_part(token, pos, byte_size(token) - pos)

        key_segments = if key_part != "", do: [{:key, key_part}], else: []
        bracket_segments = parse_brackets(bracket_part)

        key_segments ++ bracket_segments
    end
  end

  defp parse_brackets(""), do: []

  defp parse_brackets(rest) do
    case :binary.match(rest, "[") do
      :nomatch ->
        []

      {open, _} ->
        {close, _} = :binary.match(rest, "]")
        inner = binary_part(rest, open + 1, close - open - 1)

        segment =
          case inner do
            "*" -> :wildcard
            _ -> {:index, String.to_integer(inner)}
          end

        remaining = binary_part(rest, close + 1, byte_size(rest) - close - 1)
        [segment | parse_brackets(remaining)]
    end
  end

  @spec get(term(), String.t()) :: {:ok, term()} | :error
  def get(root, path) do
    segments = parse(path)
    get_segments(root, segments)
  end

  defp get_segments(current, []), do: {:ok, current}

  defp get_segments(current, [{:key, key} | rest]) when is_map(current) do
    case Map.fetch(current, key) do
      {:ok, child} -> get_segments(child, rest)
      :error -> :error
    end
  end

  defp get_segments(current, [{:index, idx} | rest]) when is_list(current) do
    case resolve_index(idx, length(current)) do
      {:ok, resolved} -> get_segments(Enum.at(current, resolved), rest)
      :error -> :error
    end
  end

  defp get_segments(current, [:wildcard | rest]) when is_list(current) do
    collected =
      current
      |> Enum.map(fn elem -> get_segments(elem, rest) end)
      |> Enum.filter(fn
        {:ok, _} -> true
        :error -> false
      end)
      |> Enum.map(fn {:ok, v} -> v end)

    {:ok, collected}
  end

  defp get_segments(current, [:length]) when is_list(current), do: {:ok, length(current)}
  defp get_segments(current, [:length]) when is_map(current), do: {:ok, map_size(current)}

  defp get_segments(_current, _segments), do: :error

  @spec set(term(), String.t(), term()) :: {:ok, term()} | {:error, term()}
  def set(root, path, value) do
    segments = parse(path)
    set_segments(root, segments, value)
  end

  defp set_segments(_current, [], value), do: {:ok, value}

  defp set_segments(current, [{:key, key} | rest], value) do
    map = if is_map(current), do: current, else: %{}

    case set_segments(Map.get(map, key), rest, value) do
      {:ok, child} -> {:ok, Map.put(map, key, child)}
      {:error, _} = err -> err
    end
  end

  defp set_segments(current, [{:index, idx} | rest], value) do
    list = if is_list(current), do: current, else: []
    len = length(list)

    resolved =
      if idx < 0 do
        r = len + idx
        if r < 0 or r >= len, do: :error, else: {:ok, r}
      else
        {:ok, idx}
      end

    case resolved do
      :error ->
        {:error, :index_out_of_bounds}

      {:ok, r} ->
        # Extend list with nils if needed
        extended =
          if r >= len do
            list ++ List.duplicate(nil, r - len + 1)
          else
            list
          end

        case set_segments(Enum.at(extended, r), rest, value) do
          {:ok, child} -> {:ok, List.replace_at(extended, r, child)}
          {:error, _} = err -> err
        end
    end
  end

  defp set_segments(_current, [:wildcard | _rest], _value), do: {:error, :not_supported}
  defp set_segments(_current, [:length | _rest], _value), do: {:error, :not_supported}

  @spec delete(term(), String.t()) :: {:ok, term()} | :error
  def delete(root, path) do
    segments = parse(path)
    delete_segments(root, segments)
  end

  defp delete_segments(_current, []), do: :error

  defp delete_segments(current, [{:key, key}]) when is_map(current) do
    {:ok, Map.delete(current, key)}
  end

  defp delete_segments(current, [{:index, idx}]) when is_list(current) do
    case resolve_index(idx, length(current)) do
      {:ok, resolved} -> {:ok, List.delete_at(current, resolved)}
      :error -> :error
    end
  end

  defp delete_segments(current, [{:key, key} | rest]) when is_map(current) do
    case Map.fetch(current, key) do
      {:ok, child} ->
        case delete_segments(child, rest) do
          {:ok, updated} -> {:ok, Map.put(current, key, updated)}
          :error -> :error
        end

      :error ->
        :error
    end
  end

  defp delete_segments(current, [{:index, idx} | rest]) when is_list(current) do
    case resolve_index(idx, length(current)) do
      {:ok, resolved} ->
        child = Enum.at(current, resolved)

        case delete_segments(child, rest) do
          {:ok, updated} -> {:ok, List.replace_at(current, resolved, updated)}
          :error -> :error
        end

      :error ->
        :error
    end
  end

  defp delete_segments(_current, _segments), do: :error

  defp resolve_index(idx, len) when idx < 0 do
    resolved = len + idx
    if resolved < 0 or resolved >= len, do: :error, else: {:ok, resolved}
  end

  defp resolve_index(idx, len) do
    if idx < 0 or idx >= len, do: :error, else: {:ok, idx}
  end
end
