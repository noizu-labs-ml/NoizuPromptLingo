defmodule Noizu.MCP.Schema do
  @moduledoc """
  JSON Schema validation (2020-12, MCP's default dialect) backed by `JSV`.

  Compiled schemas are cached in `:persistent_term`, keyed by a hash of the raw
  schema, so repeated tool calls don't pay the build cost.
  """

  @cache __MODULE__

  @doc """
  Validate `data` against a raw JSON Schema map (string keys).

  Returns `:ok` or `{:error, message}` where `message` is a human/model-readable
  summary of the violations.
  """
  @spec validate(map(), term()) :: :ok | {:error, String.t()}
  def validate(schema, data) when is_map(schema) do
    case JSV.validate(data, compiled!(schema)) do
      {:ok, _} -> :ok
      {:error, validation_error} -> {:error, format_error(validation_error)}
    end
  end

  @doc "Build (and cache) a compiled schema; raises on an invalid schema."
  @spec compiled!(map()) :: JSV.Root.t()
  def compiled!(schema) when is_map(schema) do
    key = {@cache, :erlang.phash2(schema)}

    case :persistent_term.get(key, nil) do
      nil ->
        root = JSV.build!(schema)
        :persistent_term.put(key, root)
        root

      root ->
        root
    end
  end

  @doc "Check that a schema itself is buildable. Returns `:ok` or `{:error, message}`."
  @spec check(map()) :: :ok | {:error, String.t()}
  def check(schema) when is_map(schema) do
    case JSV.build(schema) do
      {:ok, _} -> :ok
      {:error, error} -> {:error, Exception.message(error)}
    end
  end

  defp format_error(validation_error) do
    normalized = JSV.normalize_error(validation_error)

    (normalized[:details] || [])
    |> Enum.flat_map(fn detail ->
      location = detail[:instanceLocation]

      Enum.map(detail[:errors] || [], fn error ->
        at = if location in [nil, "", "#"], do: "", else: " at #{location}"
        "#{error[:message]}#{at}"
      end)
    end)
    |> case do
      [] -> "Input does not match the expected schema"
      messages -> Enum.join(messages, "; ")
    end
  end
end
