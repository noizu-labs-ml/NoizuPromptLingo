defmodule DocPointers do
  @moduledoc """
  Doc-pointer hieroglyphic code generator and manager.

  Generates UUIDv5-derived 4-character hieroglyphic tokens for durable,
  code-stable cross-document references. Managed via MCP tools or the
  programmatic API.
  """

  alias DocPointers.{UUID5, Hieroglyph, Pointer, Store}

  @doc """
  Generate a new doc-pointer for a source location.
  Returns `{:ok, %Pointer{}}` or `{:error, reason}`.
  """
  def generate(file_path, function_name, description, opts \\ []) do
    class = Keyword.get(opts, :class)
    line = Keyword.get(opts, :line)
    salt = Keyword.get(opts, :salt)
    name_override = Keyword.get(opts, :name_override)

    base_name = name_override || UUID5.build_annotation_name(file_path, function_name)

    case find_unique_token(base_name, salt, 0) do
      {:ok, uuid_string, token} ->
        pointer =
          Pointer.new(%{
            uuid: uuid_string,
            token: token,
            file_path: file_path,
            class: class,
            function: function_name,
            line: line,
            description: description
          })

        Store.put(pointer)
        {:ok, pointer}

      {:error, _} = err ->
        err
    end
  end

  defp find_unique_token(_base_name, _salt, attempt) when attempt >= 10_000 do
    {:error, :max_attempts}
  end

  defp find_unique_token(base_name, salt, attempt) do
    name = UUID5.build_name(base_name, salt, attempt)
    uuid_bytes = UUID5.generate(name)
    uuid_string = UUID5.to_string(uuid_bytes)
    token = Hieroglyph.encode(uuid_bytes)

    if Store.token_exists?(token) do
      find_unique_token(base_name, salt, attempt + 1)
    else
      {:ok, uuid_string, token}
    end
  end
end
