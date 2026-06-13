defmodule Derobot.Ecto.SerializedTerm do
  use Ecto.Type

  def type, do: :binary

  def cast(term), do: {:ok, term}
  def load(nil), do: {:ok, nil}
  def load(binary) when is_binary(binary), do: {:ok, :erlang.binary_to_term(binary)}
  def dump(nil), do: {:ok, nil}
  def dump(term), do: {:ok, :erlang.term_to_binary(term)}
end
