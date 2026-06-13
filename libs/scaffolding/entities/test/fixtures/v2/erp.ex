# To avoid interlocking code a master defimpl should be defined for all tables and entities as follows.
alias Noizu.Scaffolding.Test.Fixture.FooV2Entity
alias Noizu.Database.Scaffolding.Test.Fixture.FooV2Table

defimpl Noizu.ERP, for: [FooV2Entity, FooV2Table] do
 def id(o), do: Noizu.Scaffolding.V2.ERPResolver.id(o)
 def id_ok(o) do
  r = id(o)
  r && {:ok, r} || {:error, o}
 end

 def ref(o), do: Noizu.Scaffolding.V2.ERPResolver.ref(o)
 def ref_ok(o) do
  r = ref(o)
  r && {:ok, r} || {:error, o}
 end

 def sref(o), do: Noizu.Scaffolding.V2.ERPResolver.sref(o)
 def sref_ok(o) do
  r = sref(o)
  r && {:ok, r} || {:error, o}
 end

 def entity(o, options \\ nil), do: Noizu.Scaffolding.V2.ERPResolver.entity(o, options)
 def entity_ok(o, options \\ nil) do
  r = entity(o, options)
  r && {:ok, r} || {:error, o}
 end

 def entity!(o, options \\ nil), do: Noizu.Scaffolding.V2.ERPResolver.entity!(o, options)
 def entity_ok!(o, options \\ nil) do
  r = entity!(o, options)
  r && {:ok, r} || {:error, o}
 end

 def record(o, options \\ nil), do: Noizu.Scaffolding.V2.ERPResolver.record(o, options)
 def record!(o, options \\ nil), do: Noizu.Scaffolding.V2.ERPResolver.record!(o, options)
end

