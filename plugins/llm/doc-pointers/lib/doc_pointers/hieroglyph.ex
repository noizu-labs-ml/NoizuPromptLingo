defmodule DocPointers.Hieroglyph do
  @token_ranges [
    {0x10980, 0x1099F},
    {0x13000, 0x1342F},
    {0x13460, 0x143FF},
    {0x14400, 0x1467F}
  ]

  @token_size Enum.reduce(@token_ranges, 0, fn {s, e}, acc -> acc + (e - s + 1) end)
  @token_length 4

  def token_size, do: @token_size

  @doc """
  Encode a 16-byte UUID binary into a 4-character hieroglyph token.
  """
  def encode(<<number::unsigned-big-128>>) do
    {_, digits} =
      Enum.reduce(1..@token_length, {number, []}, fn _, {n, acc} ->
        index = rem(n, @token_size)
        {div(n, @token_size), [char_from_index(index) | acc]}
      end)

    IO.iodata_to_binary(digits)
  end

  @doc """
  Wrap a token in doc-pointer bracket markers.
  """
  def marker(token), do: "⟦#{token}⟧"

  @doc """
  Format a declaration line: ⟦TOKEN⟧ Name :: Description
  """
  def declaration(token, name, description) do
    "⟦#{token}⟧ #{name} :: #{description}"
  end

  defp char_from_index(index) do
    Enum.reduce_while(@token_ranges, index, fn {start, finish}, remaining ->
      size = finish - start + 1

      if remaining < size do
        {:halt, <<(start + remaining)::utf8>>}
      else
        {:cont, remaining - size}
      end
    end)
  end
end
