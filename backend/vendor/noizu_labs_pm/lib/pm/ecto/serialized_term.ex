defmodule Noizu.PM.Ecto.SerializedTerm do
  @moduledoc """
  Base64-encoded Erlang term-to-binary column type, used by `auth_providers`
  settings. Lifted verbatim from `NoizuPromptLingua.Ecto.SerializedTerm`.
  """
  use Ecto.Type

  @impl true
  def type, do: :string

  @impl true
  def equal?(a, b) do
    a == b
  end

  @impl true
  def embed_as(_format), do: :dump

  @impl true
  def cast(v) do
    {:ok, v}
  end

  @doc """
  Same as `cast/1` but raises `Ecto.CastError` on invalid arguments.
  """
  def cast!(v) do
    case cast(v) do
      {:ok, v} -> v
      _ -> raise ArgumentError, "Unsupported: #{inspect(v)}"
    end
  end

  @impl true
  def dump(nil) do
    {:ok, nil}
  end

  def dump(object) do
    binary = :erlang.term_to_binary(object)
    encoded = Base.encode64(binary)
    {:ok, encoded}
  end

  @impl true
  def load(nil), do: {:ok, nil}

  def load(v) do
    with {:ok, raw} <- Base.decode64(v) do
      {:ok, :erlang.binary_to_term(raw)}
    else
      _ -> {:error, :not_valid_base64}
    end
  end

  def load!(value) do
    case load(value) do
      {:ok, v} ->
        v

      :error ->
        raise ArgumentError,
              "Invalid value received from database. Expected nil or int: #{inspect(value)}"
    end
  end
end
