# -------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
# -------------------------------------------------------------------------------

defprotocol Noizu.ERP do
  @moduledoc """
  The Entity Reference Protocol (ERP) is a key component in the Noizu framework, used for handling references to
  entities in a uniform and flexible manner. The protocol defines a standard set of functions that must be implemented by
  any type that adheres to the protocol. This allows for a consistent way to interact with different types of entities
  (e.g., database records, structs, etc.) without having to know their specific implementation details.

  ## Purpose
  The purpose of the ERP is to provide a consistent interface for working with references to entities. This allows a
  table to reference various other entity types in a generic way. It also provides a straight forward mechanism for
  handling references without knowing in advance if they have been expanded or their exact type.

  ## Usage:
  The ERP protocol is used whenever there is a need to reference an entity. This can be in the form of a ERP reference,
  a string reference, or the actual object. The protocol provides functions to convert between these different
  forms (i.e., `ref`, `sref`, `entity`, and `record`).
  This makes it easy to work with different types of references without having to know the specific
  details of the entity being referenced.

  The protocol also includes functions that return either just the value (`id`, `ref`, `sref`, `entity`, `record`)
  or the same but wrapped in an `{:ok, term}` or `{:error, details}` tuple
  for matching (`id_ok`, `ref_ok`, `sref_ok`, `entity_ok`, `entity_ok!`).

  This provides flexibility in handling both the normal and error cases.

  ## Why
  The ERP protocol is useful because it abstracts away the details of the entities being referenced. Making embedding,
  linking, urls, and other cases easy to implement in a generic way. Users can write code that doesn't care if it's being
  passed ref  tuples, ref strings, actual entities, ecto records etc. but can simply call the protocol to cast to the desired
  format and handle as needed for querying, processing, returning, linking, etc.

  ## Protocol
  It defines the following functions:
  - `id/1`: Retrieves the underlying id for a given ERP.
  - `id_ok/1`: Similar to `id/1` but returns the result in the form of `{:ok, value}` or `{:error, error}`.
  - `ref/1`: Casts the given argument to a ERP reference.
  - `ref_ok/1`: Similar to `ref/1` but returns the result in the form of `{:ok, value}` or `{:error, error}`.
  - `sref/1`: Casts the given argument to a ERP string reference.
  - `sref_ok/1`: Similar to `sref/1` but returns the result in the form of `{:ok, value}` or `{:error, error}`.
  - `record/1`: Converts the given argument to a persistence object. Options may be passed to coordinate actions like expanding embedded references.
  - `record!/1`: Similar to `record/1` but with a transaction wrapper if required.
  - `entity/1`: Converts the given argument to a scaffolding.struct object. Options may be passed to coordinate actions like expanding embedded references.
  - `entity_ok/1`: Similar to `entity/1` but returns the result in the form of `{:ok, value}` or `{:error, error}`.
  - `entity!/1`: Similar to `entity/1` but with a transaction wrapper if required.
  - `entity_ok!/1`: Similar to `entity_ok/1` but with a transaction wrapper if required.

  The protocol is designed with the `@fallback_to_any true` directive,
  which means it will fall back to the `Any` implementation if no specific
  implementation for the provided data type is found.
  """

  @fallback_to_any true

  # -------------------------------------------------
  # id/1
  # -------------------------------------------------
  @doc """
  Retrieves the underlying id for a given ERP reference.
  The argument can be a ERP reference, a string reference, or the actual object.
  """
  def id(erp_sref_ref_or_object)

  # -------------------------------------------------
  # id_ok/1
  # -------------------------------------------------
  @doc """
  Similar to `id/1` but returns the result in the form of `{:ok, value}` or `{:error, error}`.
  """
  def id_ok(erp_sref_ref_or_object)

  # -------------------------------------------------
  # ref/1
  # -------------------------------------------------
  @doc """
  Casts the given argument to a ERP reference.
  The argument can be a ERP reference, a string reference, or the actual object.
  """
  def ref(erp_sref_ref_or_object)

  # -------------------------------------------------
  # ref_ok/1
  # -------------------------------------------------
  @doc """
  Similar to `ref/1` but returns the result in the form of `{:ok, value}` or `{:error, error}`.
  """
  def ref_ok(erp_sref_ref_or_object)

  # -------------------------------------------------
  # sref/1
  # -------------------------------------------------
  @doc """
  Casts the given argument to a ERP string reference.
  The argument can be a ERP reference, a string reference, or the actual object.
  """
  def sref(erp_sref_ref_or_object)

  # -------------------------------------------------
  # sref_ok/1
  # -------------------------------------------------
  @doc """
  Similar to `sref/1` but returns the result in the form of `{:ok, value}` or `{:error, error}`.
  """
  def sref_ok(erp_sref_ref_or_object)

  # -------------------------------------------------
  # record/1
  # -------------------------------------------------
  @doc """
  Convert the given argument to a persistence object. Options may be passed to coordinate actions like expanding embedded references.
  """
  def record(erp_sref_ref_or_object, options \\ %{})

  # -------------------------------------------------
  # record!/1
  # -------------------------------------------------
  @doc """
  Similar to `record/1` but will execute mnesia functions immediately with out using an outer transaction wrapper.
  """
  def record!(erp_sref_ref_or_object, options \\ %{})

  # -------------------------------------------------
  # entity/1
  # -------------------------------------------------
  @doc """
  Convert the given argument to a scaffolding.struct object. Options may be passed to coordinate actions like expanding embedded references.
  """
  def entity(erp_sref_ref_or_object, options \\ %{})

  # -------------------------------------------------
  # entity_ok/1
  # -------------------------------------------------
  @doc """
  Similar to `entity/1` but returns the result in the form of `{:ok, value}` or `{:error, error}`.
  """
  def entity_ok(erp_sref_ref_or_object, options \\ %{})

  # -------------------------------------------------
  # entity!/1
  # -------------------------------------------------
  @doc """
  Similar to `entity/1` but will execute mnesia functions immediately with out using an outer transaction wrapper
  """
  def entity!(erp_sref_ref_or_object, options \\ %{})

  # -------------------------------------------------
  # entity_ok!/1
  # -------------------------------------------------
  @doc """
  Similar to `entity_ok/1` but with a transaction wrapper if required.
  """
  def entity_ok!(erp_sref_ref_or_object, options \\ %{})
end

# end defprotocol Noizu.ERP

# -------------------------------------------------------------------------------
# Useful default implementations
# -------------------------------------------------------------------------------
defimpl Noizu.ERP, for: List do
  @moduledoc """
  This module provides implementations of the `Noizu.ERP` protocol for `List` and `Tuple` types.
  """

  # -------------------------------------------------
  # id/1
  # -------------------------------------------------
  @doc """
  Retrieves the underlying id for each ERP reference in the given list.
  """
  @impl true
  def id(erp_sref_ref_or_object)

  def id(entities) do
    for obj <- entities do
      Noizu.ERP.id(obj)
    end
  end

  # end reference/1

  # -------------------------------------------------
  # id_ok/1
  # -------------------------------------------------
  @doc """
  Similar to `id/1` but returns the results in the form of `{:ok, value}` or `{:error, error}`.
  """
  @impl true
  def id_ok(erp_sref_ref_or_object)

  def id_ok(entities) do
    results =
      for obj <- entities do
        Noizu.ERP.id(obj)
      end
      |> Enum.filter(& &1)

    (length(results) == length(entities) && {:ok, results}) || {:missing, results}
  end

  # end reference/1

  # -------------------------------------------------
  # ref/1
  # -------------------------------------------------
  @doc """
  Casts each element in the given list to a ERP reference.
  """
  @impl true
  def ref(erp_sref_ref_or_object)

  def ref(entities) do
    for obj <- entities do
      Noizu.ERP.ref(obj)
    end
  end

  # end reference/1

  # -------------------------------------------------
  # ref_ok/1
  # -------------------------------------------------
  @doc """
  Similar to `ref/1` but returns the results in the form of `{:ok, value}` or `{:error, error}`.
  """
  @impl true
  def ref_ok(erp_sref_ref_or_object)

  def ref_ok(entities) do
    results =
      for obj <- entities do
        Noizu.ERP.ref(obj)
      end
      |> Enum.filter(& &1)

    (length(results) == length(entities) && {:ok, results}) || {:missing, results}
  end

  # end reference/1

  # -------------------------------------------------
  # sref/1
  # -------------------------------------------------
  @doc """
  Casts each element in the given list to a ERP string reference.
  """
  @impl true
  def sref(erp_sref_ref_or_object)

  def sref(entities) do
    for obj <- entities do
      Noizu.ERP.sref(obj)
    end
  end

  # end sref/1

  # -------------------------------------------------
  # sref_ok/1
  # -------------------------------------------------
  @doc """
  Similar to `sref/1` but returns the results in the form of `{:ok, value}` or `{:error, error}`.
  """
  @impl true
  def sref_ok(erp_sref_ref_or_object)

  def sref_ok(entities) do
    results =
      for obj <- entities do
        Noizu.ERP.sref(obj)
      end
      |> Enum.filter(& &1)

    (length(results) == length(entities) && {:ok, results}) || {:missing, results}
  end

  # end reference/1

  # -------------------------------------------------
  # record/2
  # -------------------------------------------------
  @doc """
  Converts each element in the given list to a persistence object. Options may be passed to coordinate actions like expanding embedded references.
  """
  @impl true
  def record(erp_sref_ref_or_object, options)

  def record(entities, options \\ nil) do
    for obj <- entities do
      Noizu.ERP.record(obj, options)
    end
  end

  # end record/2

  # -------------------------------------------------
  # record!/2
  # -------------------------------------------------
  @doc """
  Similar to `record/2` but with a transaction wrapper if required.
  """
  @impl true
  def record!(erp_sref_ref_or_object, options \\ nil)

  def record!(entities, options) do
    for obj <- entities do
      Noizu.ERP.record!(obj, options)
    end
  end

  # end record!/2

  # -------------------------------------------------
  # entity/2
  # -------------------------------------------------
  @doc """
  Converts each element in the given list to a scaffolding.struct object. Options may be passed to coordinate actions like expanding embedded references.
  """
  @impl true
  def entity(erp_sref_ref_or_object, options \\ nil)

  def entity(entities, options) do
    for obj <- entities do
      Noizu.ERP.entity(obj, options)
    end
  end

  # end entity/2

  # -------------------------------------------------
  # entity_ok/2
  # -------------------------------------------------
  @doc """
  Similar to `entity/2` but returns the results in the form of `{:ok, value}` or `{:error, error}`.
  """
  @impl true
  def entity_ok(erp_sref_ref_or_object, options \\ nil)

  def entity_ok(entities, options) do
    results =
      for obj <- entities do
        Noizu.ERP.entity(obj, options)
      end
      |> Enum.filter(& &1)

    (length(results) == length(entities) && {:ok, results}) || {:missing, results}
  end

  # end reference/1

  # -------------------------------------------------
  # entity!/2
  # -------------------------------------------------
  @doc """
  Similar to `entity/2` but with a transaction wrapper if required.
  """
  @impl true
  def entity!(erp_sref_ref_or_object, options \\ nil)

  def entity!(entities, options) do
    for obj <- entities do
      Noizu.ERP.entity!(obj, options)
    end
  end

  # end entity!/2

  # -------------------------------------------------
  # entity_ok!/2
  # -------------------------------------------------
  @doc """
  Similar to `entity_ok/2` but with a transaction wrapper if required.
  """
  @impl true
  def entity_ok!(erp_sref_ref_or_object, options \\ nil)

  def entity_ok!(entities, options) do
    results =
      for obj <- entities do
        Noizu.ERP.entity!(obj, options)
      end
      |> Enum.filter(& &1)

    (length(results) == length(entities) && {:ok, results}) || {:missing, results}
  end

  # end reference/1
end

# end defimpl EntityReferenceProtocol, for: List

defimpl Noizu.ERP, for: Tuple do
  @moduledoc """
  The Tuple implementation of the Noizu.ERP protocol provides the ability to work with tuples of ERP references. It provides the same functionality as the protocol but for each element in the tuple.
  """

  # -------------------------------------------------
  # id/1
  # -------------------------------------------------
  @doc """
  Retrieves the underlying id for a given ERP reference in the tuple.
  The argument can be a ERP reference, a string reference, or the actual object.
  """
  def id(erp_sref_ref_or_object)

  def id(obj) do
    case obj do
      {:ref, manager, identifier} when is_atom(manager) ->
        # if function_exported?(manager, :sref, 1) do
        manager.id(identifier)

      # end
      {:ext_ref, manager, identifier} when is_atom(manager) ->
        manager.id(identifier)
    end
  end

  # end id/1

  # -------------------------------------------------
  # id_ok/1
  # -------------------------------------------------
  @doc """
  Similar to `id/1` but returns the result in the form of `{:ok, value}` or `{:error, error}`.
  """
  @impl true
  def id_ok(erp_sref_ref_or_object)

  def id_ok(obj) do
    result = id(obj)
    (result && {:ok, result}) || {:error, obj}
  end

  # end id/1

  # -------------------------------------------------
  # ref/1
  # -------------------------------------------------
  @doc """
  Casts the given argument in the tuple to a ERP reference.
  The argument can be a ERP reference, a string reference, or the actual object.
  """
  @impl true
  def ref(erp_sref_ref_or_object)

  def ref(obj) do
    case obj do
      {:ref, manager, _identifier} when is_atom(manager) -> obj
      {:ext_ref, manager, _identifier} when is_atom(manager) -> obj
    end
  end

  # end ref/1

  # -------------------------------------------------
  # ref_ok/1
  # -------------------------------------------------
  @doc """
  Similar to `ref/1` but returns the result in the form of `{:ok, value}` or `{:error, error}`.
  """
  @impl true
  def ref_ok(erp_sref_ref_or_object)

  def ref_ok(obj) do
    result = ref(obj)
    (result && {:ok, result}) || {:error, obj}
  end

  # end ref/1

  # -------------------------------------------------
  # sref/1
  # -------------------------------------------------
  @doc """
  Casts the given argument in the tuple to a ERP string reference.
  The argument can be a ERP reference, a string reference, or the actual object.
  """
  @impl true
  def sref(erp_sref_ref_or_object)

  def sref(obj) do
    case obj do
      {:ref, manager, identifier} when is_atom(manager) ->
        # if function_exported?(manager, :sref, 1) do
        manager.sref(identifier)

      # end
      {:ext_ref, manager, identifier} when is_atom(manager) ->
        manager.sref(identifier)
    end
  end

  # end sref/1

  # -------------------------------------------------
  # sref_ok/1
  # -------------------------------------------------
  @doc """
  Similar to `sref/1` but returns the result in the form of `{:ok, value}` or `{:error, error}`.
  """
  @impl true
  def sref_ok(erp_sref_ref_or_object)

  def sref_ok(obj) do
    result = sref(obj)
    (result && {:ok, result}) || {:error, obj}
  end

  # end sref/1

  # -------------------------------------------------
  # record/2
  # -------------------------------------------------
  @doc """
  Converts the given argument in the tuple to a persistence object. Options may be passed to coordinate actions like expanding embedded references.
  """
  @impl true
  def record(erp_sref_ref_or_object, options \\ nil)

  def record(obj, options) do
    case obj do
      {:ref, manager, identifier} when is_atom(manager) ->
        # if function_exported?(manager, :entity, 2) do
        manager.record(identifier, options)

      # end
      {:ext_ref, manager, identifier} when is_atom(manager) ->
        manager.record(identifier, options)
    end
  end

  # end record/2

  # -------------------------------------------------
  # record!/2
  # -------------------------------------------------
  @doc """
  Similar to `record/2` but with a transaction wrapper if required.
  """
  @impl true
  def record!(erp_sref_ref_or_object, options \\ nil)

  def record!(obj, options) do
    case obj do
      {:ref, manager, identifier} when is_atom(manager) ->
        # if function_exported?(manager, :entity, 2) do
        manager.record!(identifier, options)

      # end
      {:ext_ref, manager, identifier} when is_atom(manager) ->
        manager.record!(identifier, options)
    end
  end

  # end record/2

  # -------------------------------------------------
  # entity/2
  # -------------------------------------------------
  @doc """
  Converts the given argument in the tuple to a scaffolding.struct object. Options may be passed to coordinate actions like expanding embedded references.
  """
  @impl true
  def entity(erp_sref_ref_or_object, options \\ nil)

  def entity(obj, options) do
    case obj do
      {:ref, manager, _identifier} when is_atom(manager) ->
        # if function_exported?(manager, :entity, 2) do
        manager.entity(obj, options)

      # end
      {:ext_ref, manager, _identifier} when is_atom(manager) ->
        manager.entity(obj, options)
    end
  end

  # end entity/2

  # -------------------------------------------------
  # entity_ok/2
  # -------------------------------------------------
  @doc """
  Similar to `entity/2` but returns the result in the form of `{:ok, value}` or `{:error, error}`.
  """
  @impl true
  def entity_ok(erp_sref_ref_or_object, options \\ nil)

  def entity_ok(obj, options) do
    result = entity(obj, options)
    (result && {:ok, result}) || {:error, obj}
  end

  # end entity_ok/1

  # -------------------------------------------------
  # entity!/2
  # -------------------------------------------------
  @doc """
  Similar to `entity/2` but with a transaction wrapper if required.
  """
  @impl true
  def entity!(erp_sref_ref_or_object, options \\ nil)

  def entity!(obj, options) do
    case obj do
      {:ref, manager, _identifier} when is_atom(manager) ->
        # if function_exported?(manager, :entity, 2) do
        manager.entity!(obj, options)

      # end
      {:ext_ref, manager, _identifier} when is_atom(manager) ->
        manager.entity!(obj, options)
    end
  end

  # end entity/2

  # -------------------------------------------------
  # entity_ok!/2
  # -------------------------------------------------
  @doc """
  Similar to `entity_ok/2` but with a transaction wrapper if required.
  """
  @impl true
  def entity_ok!(erp_sref_ref_or_object, options \\ nil)

  def entity_ok!(obj, options) do
    result = entity!(obj, options)
    (result && {:ok, result}) || {:error, obj}
  end

  # end entity_ok/1
end

# end defimpl EntityReferenceProtocol, for: Tuple
