defmodule Noizu.Scaffolding.V2.ERPResolver do
  def id(o), do: o.__struct__.erp_handler().id(o)
  def id_ok(o) do
    r = id(o)
    r && {:ok, r} || {:error, o}
  end

  def ref(o), do: o.__struct__.erp_handler().ref(o)
  def ref_ok(o) do
    r = ref(o)
    r && {:ok, r} || {:error, o}
  end

  def sref(o), do: o.__struct__.erp_handler().sref(o)
  def sref_ok(o) do
    r = sref(o)
    r && {:ok, r} || {:error, o}
  end

  def entity(o, options \\ %{}), do: o.__struct__.erp_handler().entity(o, options)
  def entity_ok(o, options \\ nil) do
    r = entity(o, options)
    r && {:ok, r} || {:error, o}
  end

  def entity!(o, options \\ %{}), do: o.__struct__.erp_handler().entity!(o, options)
  def entity_ok!(o, options \\ nil) do
    r = entity!(o, options)
    r && {:ok, r} || {:error, o}
  end

  def record(o, options \\ %{}), do: o.__struct__.erp_handler().record(o, options)
  def record!(o, options \\ %{}), do: o.__struct__.erp_handler().record!(o, options)
end