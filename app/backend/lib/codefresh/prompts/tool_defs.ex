defmodule Codefresh.Prompts.ToolDefs do
  @moduledoc """
  Adapter-agnostic tool / function-call schema definitions for prompt versions.

  Canonical shape:

      %{
        "tools" => [
          %{
            "name"        => "lookup_user",
            "description" => "Fetch a user record by id",
            "parameters"  => %{  # JSON Schema object
              "type"     => "object",
              "properties" => %{"user_id" => %{"type" => "string"}},
              "required" => ["user_id"]
            }
          },
          ...
        ]
      }

  The `parameters` value is passed through as JSON Schema; adapters map it to
  their native convention (OpenAI `tools[].function.parameters`, Anthropic
  `tools[].input_schema`, etc.).
  """

  @type tool :: %{
          required(String.t()) => String.t() | map()
        }

  @doc """
  Validate the canonical tool_defs shape. Returns `:ok` or
  `{:error, reason}` where reason identifies the first failing tool.

  Empty / missing tool list is valid (tools are optional on a prompt).
  """
  @spec validate(map()) :: :ok | {:error, term()}
  def validate(defs) when is_map(defs) do
    case Map.get(defs, "tools") || Map.get(defs, :tools) do
      nil -> :ok
      [] -> :ok
      list when is_list(list) -> validate_list(list, 0)
      _ -> {:error, :tools_must_be_list}
    end
  end

  def validate(_), do: {:error, :tool_defs_must_be_map}

  defp validate_list([], _), do: :ok

  defp validate_list([tool | rest], idx) do
    case validate_tool(tool) do
      :ok -> validate_list(rest, idx + 1)
      {:error, reason} -> {:error, {:tool_at_index, idx, reason}}
    end
  end

  defp validate_tool(tool) when is_map(tool) do
    with :ok <- require_string(tool, "name"),
         :ok <- require_string(tool, "description"),
         :ok <- require_params(tool) do
      :ok
    end
  end

  defp validate_tool(_), do: {:error, :tool_must_be_map}

  defp require_string(tool, key) do
    case Map.get(tool, key) || Map.get(tool, String.to_atom(key)) do
      s when is_binary(s) and byte_size(s) > 0 -> :ok
      nil -> {:error, {:missing, key}}
      _ -> {:error, {:not_a_string, key}}
    end
  end

  defp require_params(tool) do
    case Map.get(tool, "parameters") || Map.get(tool, :parameters) do
      nil -> :ok
      %{} = _map -> :ok
      _ -> {:error, {:parameters_must_be_object, tool["name"]}}
    end
  end

  @doc """
  Extract the list of declared tool names from a tool_defs map. Used by
  structural expectations to know what tool-call observations are meaningful.
  """
  def tool_names(defs) when is_map(defs) do
    case Map.get(defs, "tools") || Map.get(defs, :tools) do
      list when is_list(list) ->
        Enum.flat_map(list, fn t ->
          case Map.get(t, "name") || Map.get(t, :name) do
            s when is_binary(s) -> [s]
            _ -> []
          end
        end)

      _ ->
        []
    end
  end

  def tool_names(_), do: []
end
