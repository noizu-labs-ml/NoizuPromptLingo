# -------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2020 Noizu Labs, Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.CallerEntity do
  @moduledoc """
  The `Noizu.ElixirCore.CallerEntity` module provides a convenience structure for tracking API caller authentication levels. It supports the levels `:internal`, `:restricted`, `:system`, and `:admin`.

  ## Types
  - `t`: A structure representing the CallerEntity with fields `identifier` and `vsn`.

  ## Functions
  """

  @vsn 1.0
  @type t :: %__MODULE__{
          identifier: any,
          vsn: float
        }

  defstruct identifier: nil,
            vsn: @vsn

  defp to_atom("internal"), do: :internal
  defp to_atom("restricted"), do: :restricted
  defp to_atom("system"), do: :system
  defp to_atom("admin"), do: :admin

  @doc """
  Returns the identifier of the CallerEntity.

  ## Examples
  ```elixir
  iex> Noizu.ElixirCore.CallerEntity.id(%Noizu.ElixirCore.CallerEntity{identifier: :system})
  :system

  iex> Noizu.ElixirCore.CallerEntity.id({:ref, Noizu.ElixirCore.CallerEntity, :system})
  :system

  iex> Noizu.ElixirCore.CallerEntity.id("ref.noizu-caller.system")
  :system

  iex> Noizu.ElixirCore.CallerEntity.id(:system)
  :system
  ```

  # Code Review
  - The function could benefit from more detailed documentation.
  """
  @spec id(any) :: any
  def id(%__MODULE__{} = e), do: e.identifier
  def id({:ref, __MODULE__, identifier}), do: identifier
  def id("ref.noizu-caller." <> identifier), do: to_atom(identifier)
  def id(identifier) when is_atom(identifier), do: identifier

  @doc """
  Returns the reference tuple for the CallerEntity.

  ## Examples
  ```elixir
  iex> Noizu.ElixirCore.CallerEntity.ref(%Noizu.ElixirCore.CallerEntity{identifier: :system})
  {:ref, Noizu.ElixirCore.CallerEntity, :system}

  iex> Noizu.ElixirCore.CallerEntity.ref({:ref, Noizu.ElixirCore.CallerEntity, :system})
  {:ref, Noizu.ElixirCore.CallerEntity, :system}

  iex> Noizu.ElixirCore.CallerEntity.ref("ref.noizu-caller.system")
  {:ref, Noizu.ElixirCore.CallerEntity, :system}

  iex> Noizu.ElixirCore.CallerEntity.ref(:system)
  {:ref, Noizu.ElixirCore.CallerEntity, :system}
  ```

  # Code Review
  - The function could benefit from more detailed documentation.
  """
  @spec ref(any) :: tuple
  def ref(%__MODULE__{} = e), do: {:ref, __MODULE__, e.identifier}
  def ref({:ref, __MODULE__, identifier}), do: {:ref, __MODULE__, identifier}
  def ref("ref.noizu-caller." <> identifier), do: {:ref, __MODULE__, to_atom(identifier)}
  def ref(identifier) when is_atom(identifier), do: {:ref, __MODULE__, identifier}

  @doc """
  Returns the string reference for the CallerEntity.

  ## Examples
  ```elixir
  iex> Noizu.ElixirCore.CallerEntity.sref(%Noizu.ElixirCore.CallerEntity{identifier: :system})
  "ref.noizu-caller.system"

  iex> Noizu.ElixirCore.CallerEntity.sref({:ref, Noizu.ElixirCore.CallerEntity, :system})
  "ref.noizu-caller.system"

  iex> Noizu.ElixirCore.CallerEntity.sref("ref.noizu-caller.system")
  "ref.noizu-caller.system"

  iex> Noizu.ElixirCore.CallerEntity.sref(:system)
  "ref.noizu-caller.system"
  ```

  # Code Review
  - The function could benefit from more detailed documentation.
  """
  @spec sref(t) :: String.t()
  def sref(%__MODULE__{} = e), do: "ref.noizu-caller.#{e.identifier}"
  def sref({:ref, __MODULE__, identifier}), do: "ref.noizu-caller.#{identifier}"
  def sref("ref.noizu-caller." <> _identifier = sref), do: sref
  def sref(identifier) when is_atom(identifier), do: "ref.noizu-caller.#{identifier}"

  @doc """
  Returns the CallerEntity as an entity struct. Raises an error if the conversion fails.

  ## Examples
  ```elixir
  iex> Noizu.ElixirCore.CallerEntity.entity!(%Noizu.ElixirCore.CallerEntity{identifier: :system})
  %Noizu.ElixirCore.CallerEntity{identifier: :system}

  iex> Noizu.ElixirCore.CallerEntity.entity!({:ref, Noizu.ElixirCore.CallerEntity, :system})
  %Noizu.ElixirCore.CallerEntity{identifier: :system}

  iex> Noizu.ElixirCore.CallerEntity.entity!("ref.noizu-caller.system")
  %Noizu.ElixirCore.CallerEntity{identifier: :system}

  iex> Noizu.ElixirCore.CallerEntity.entity!(:system)
  %Noizu.ElixirCore.CallerEntity{identifier: :system}
  ```

  # Code Review
  - The function could benefit from more detailed documentation.
  """
  def entity(ref, options \\ %{})
  def entity({:ref, __MODULE__, identifier}, _options), do: %__MODULE__{identifier: identifier}
  def entity(%__MODULE__{} = e, _options), do: e

  def entity("ref.noizu-caller." <> identifier, _options),
    do: %__MODULE__{identifier: to_atom(identifier)}

  def entity(identifier, _options) when is_atom(identifier),
    do: %__MODULE__{identifier: identifier}

  @doc "Noizu.ERP handler"
  def entity!(ref, options \\ %{})
  def entity!({:ref, __MODULE__, identifier}, _options), do: %__MODULE__{identifier: identifier}
  def entity!(%__MODULE__{} = e, _options), do: e

  def entity!("ref.noizu-caller." <> identifier, _options),
    do: %__MODULE__{identifier: to_atom(identifier)}

  def entity!(identifier, _options) when is_atom(identifier),
    do: %__MODULE__{identifier: identifier}

  @doc """
  Returns the CallerEntity as a record.

  ## Examples
  ```elixir
  iex> Noizu.ElixirCore.CallerEntity.record(%Noizu.ElixirCore.CallerEntity{identifier: :system})
  %Noizu.ElixirCore.CallerEntity{identifier: :system}

  iex> Noizu.ElixirCore.CallerEntity.record({:ref, Noizu.ElixirCore.CallerEntity, :system})
  %Noizu.ElixirCore.CallerEntity{identifier: :system}

  iex> Noizu.ElixirCore.CallerEntity.record("ref.noizu-caller.system")
  %Noizu.ElixirCore.CallerEntity{identifier: :system}

  iex> Noizu.ElixirCore.CallerEntity.record(:system)
  %Noizu.ElixirCore.CallerEntity{identifier: :system}
  ```

  # Code Review
  - The function could benefit from more detailed documentation.
  """
  def record(ref, options \\ %{})
  def record({:ref, __MODULE__, identifier}, _options), do: %__MODULE__{identifier: identifier}
  def record(%__MODULE__{} = e, _options), do: e

  def record("ref.noizu-caller." <> identifier, _options),
    do: %__MODULE__{identifier: to_atom(identifier)}

  def record(identifier, _options) when is_atom(identifier),
    do: %__MODULE__{identifier: identifier}

  @doc "Noizu.ERP handler"
  def record!(ref, options \\ %{})
  def record!({:ref, __MODULE__, identifier}, _options), do: %__MODULE__{identifier: identifier}
  def record!(%__MODULE__{} = e, _options), do: e

  def record!("ref.noizu-caller." <> identifier, _options),
    do: %__MODULE__{identifier: to_atom(identifier)}

  def record!(identifier, _options) when is_atom(identifier),
    do: %__MODULE__{identifier: identifier}

  @doc """
  Returns the identifier of the CallerEntity as an `:ok` tuple or the original object as an `:error` tuple.

  ## Examples
  ```elixir
  iex> Noizu.ElixirCore.CallerEntity.id_ok(%Noizu.ElixirCore.CallerEntity{identifier: :system})
  {:ok, :system}
  ```

  # Code Review
  - The function could benefit from more detailed documentation.
  """
  def id_ok(o) do
    r = id(o)
    (r && {:ok, r}) || {:error, o}
  end

  @doc """
  Returns the reference tuple of the CallerEntity as an `:ok` tuple or the original object as an `:error` tuple.

  ## Examples
  ```elixir
  iex> Noizu.ElixirCore.CallerEntity.ref_ok(%Noizu.ElixirCore.CallerEntity{identifier: :system})
  {:ok, {:ref, Noizu.ElixirCore.CallerEntity, :system}}
  ```

  # Code Review
  - The function could benefit from more detailed documentation.
  """
  def ref_ok(o) do
    r = ref(o)
    (r && {:ok, r}) || {:error, o}
  end

  @doc """
  Returns the string reference of the CallerEntity as an `:ok` tuple or the original object as an `:error` tuple.

  ## Examples
  ```elixir
  iex> Noizu.ElixirCore.CallerEntity.sref_ok(%Noizu.ElixirCore.CallerEntity{identifier: :system})
  {:ok, "ref.noizu-caller.system"}
  ```

  # Code Review
  - The function could benefit from more detailed documentation.
  """
  def sref_ok(o) do
    r = sref(o)
    (r && {:ok, r}) || {:error, o}
  end

  @doc """
  Returns the CallerEntity as an entity struct as an `:ok` tuple or the original object as an `:error` tuple.

  ## Examples
  ```elixir
  iex> Noizu.ElixirCore.CallerEntity.entity_ok(%Noizu.ElixirCore.CallerEntity{identifier: :system})
  {:ok, %Noizu.ElixirCore.CallerEntity{identifier: :system}}
  ```

  # Code Review
  - The function could benefit from more detailed documentation.
  """
  def entity_ok(o, options \\ %{}) do
    r = entity(o, options)
    (r && {:ok, r}) || {:error, o}
  end

  @doc """
  Returns the CallerEntity as an entity struct as an `:ok` tuple or raises an error if the conversion fails.

  ## Examples
  ```elixir
  iex> Noizu.ElixirCore.CallerEntity.entity_ok!(%Noizu.ElixirCore.CallerEntity{identifier: :system})
  {:ok, %Noizu.ElixirCore.CallerEntity{identifier: :system}}
  ```

  # Code Review
  - The function could benefit from more detailed documentation.
  """
  def entity_ok!(o, options \\ %{}) do
    r = entity!(o, options)
    (r && {:ok, r}) || {:error, o}
  end

  defimpl Noizu.ERP, for: Noizu.ElixirCore.CallerEntity do
    def id(obj) do
      obj.identifier
    end

    # end sref/1

    def ref(obj) do
      {:ref, Noizu.ElixirCore.CallerEntity, obj.identifier}
    end

    # end ref/1

    def sref(obj) do
      "ref.noizu-caller.#{obj.identifier}"
    end

    # end sref/1

    def record(obj, _options \\ nil) do
      obj
    end

    # end record/2

    def record!(obj, _options \\ nil) do
      obj
    end

    # end record/2

    def entity(obj, _options \\ nil) do
      obj
    end

    # end entity/2

    def entity!(obj, _options \\ nil) do
      obj
    end

    # end defimpl EntityReferenceProtocol, for: Tuple

    def id_ok(o) do
      r = id(o)
      (r && {:ok, r}) || {:error, o}
    end

    def ref_ok(o) do
      r = ref(o)
      (r && {:ok, r}) || {:error, o}
    end

    def sref_ok(o) do
      r = sref(o)
      (r && {:ok, r}) || {:error, o}
    end

    def entity_ok(o, options \\ %{}) do
      r = entity(o, options)
      (r && {:ok, r}) || {:error, o}
    end

    def entity_ok!(o, options \\ %{}) do
      r = entity!(o, options)
      (r && {:ok, r}) || {:error, o}
    end
  end
end
