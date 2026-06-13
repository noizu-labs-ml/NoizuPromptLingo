#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.UnsupportedModule do
  @type t :: %__MODULE__{
    reference: any,
  }

  defstruct [
    reference: nil,
  ]

  @behaviour Noizu.Scaffolding.EntityBehaviour

  def id(item), do: throw "UnsupportedModule #{inspect item}"
  def ref(item), do: throw "UnsupportedModule #{inspect item}"
  def sref(item), do: throw "UnsupportedModule #{inspect item}"
  def entity(item, _options), do: throw "UnsupportedModule #{inspect item}"
  def entity!(item, _options), do: throw "UnsupportedModule #{inspect item}"
  def record(item, _options), do: throw "UnsupportedModule #{inspect item}"
  def record!(item, _options), do: throw "UnsupportedModule #{inspect item}"
  def as_record(item, _options), do: throw "UnsupportedModule #{inspect item}"
  def sref_module(), do: "unsupported-module"
  def has_permission(_,_,_,_), do: false
  def has_permission!(_,_,_,_), do: false
  def compress(entity), do: entity
  def compress(entity, _options), do: entity
  def expand(entity), do: entity
  def expand(entity, _options), do: entity
  def from_json(json, _options), do: throw "UnsupportedModule #{inspect json}"
  def repo(), do: __MODULE__


  def id_ok(o) do
    r = id(o)
    r && {:ok, r} || {:error, o}
  end
  def ref_ok(o) do
    r = ref(o)
    r && {:ok, r} || {:error, o}
  end
  def sref_ok(o) do
    r = sref(o)
    r && {:ok, r} || {:error, o}
  end
  def entity_ok(o, options \\ %{}) do
    r = entity(o, options)
    r && {:ok, r} || {:error, o}
  end
  def entity_ok!(o, options \\ %{}) do
    r = entity!(o, options)
    r && {:ok, r} || {:error, o}
  end


end

defimpl Noizu.ERP, for: Noizu.Scaffolding.UnsupportedModule do
  def id(_item), do: throw "UnsupportedModule"
  def ref(_item), do: throw "UnsupportedModule"
  def sref(_item), do: throw "UnsupportedModule"
  def entity(_item, _options \\ nil), do: throw "UnsupportedModule"
  def entity!(_item, _options \\ nil), do: throw "UnsupportedModule"
  def record(_item, _options \\ nil), do: throw "UnsupportedModule"
  def record!(_item, _options \\ nil), do: throw "UnsupportedModule"


  def id_ok(o) do
    r = id(o)
    r && {:ok, r} || {:error, o}
  end
  def ref_ok(o) do
    r = ref(o)
    r && {:ok, r} || {:error, o}
  end
  def sref_ok(o) do
    r = sref(o)
    r && {:ok, r} || {:error, o}
  end
  def entity_ok(o, options \\ %{}) do
    r = entity(o, options)
    r && {:ok, r} || {:error, o}
  end
  def entity_ok!(o, options \\ %{}) do
    r = entity!(o, options)
    r && {:ok, r} || {:error, o}
  end
end
