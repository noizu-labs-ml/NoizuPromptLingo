defmodule DocPointers.UUID5 do
  @namespace <<0x64, 0xE9, 0x40, 0x8C, 0x37, 0xA7, 0x5F, 0x92,
               0x88, 0x93, 0xF1, 0x49, 0xCB, 0xDE, 0x01, 0xC0>>

  def namespace, do: @namespace

  @doc """
  Generate a UUIDv5 binary from a name string using the doc-pointers namespace.
  Returns raw 16-byte binary.
  """
  def generate(name, namespace \\ @namespace) do
    <<a::48, _v::4, b::12, _var::2, c::62, _rest::binary>> =
      :crypto.hash(:sha, namespace <> name)

    <<a::48, 5::4, b::12, 2::2, c::62>>
  end

  @doc """
  Format a 16-byte UUID binary as a lowercase hyphenated string.
  """
  def to_string(<<a::32, b::16, c::16, d::16, e::48>>) do
    [a, b, c, d, e]
    |> Enum.zip([8, 4, 4, 4, 12])
    |> Enum.map_join("-", fn {val, width} ->
      val
      |> Integer.to_string(16)
      |> String.downcase()
      |> String.pad_leading(width, "0")
    end)
  end

  @doc """
  Parse a hyphenated UUID string into a 16-byte binary.
  """
  def from_string(uuid_string) when is_binary(uuid_string) do
    uuid_string
    |> String.replace("-", "")
    |> Base.decode16!(case: :mixed)
  end

  @doc """
  Build the name string for doc-pointer generation.
  Default format: `doc-pointers:{name}[:{salt}][:{attempt}]`
  """
  def build_name(name, salt \\ nil, attempt \\ 0) do
    parts = ["doc-pointers", name]
    parts = if salt && salt != "", do: parts ++ [salt], else: parts
    parts = if attempt > 0, do: parts ++ [Integer.to_string(attempt)], else: parts
    Enum.join(parts, ":")
  end

  @doc """
  Build the annotation-style name: `{file_path}::{function_name}`
  """
  def build_annotation_name(file_path, function_name) do
    "#{file_path}::#{function_name}"
  end
end
