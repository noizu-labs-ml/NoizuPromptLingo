Amnesia Style Guide
--------------------------

The following are the current Noizu conventions and notes for Amnesia databases, repos and entity objects. Feel free to grab this document and modify
for your own uses to help onboard your fellow developers on how the project works and naming conventions expected by the framework.

This document has been modified from the (original)[https://github.com/noizu/ElixirScaffolding/blob/master/markdown/sample_conventions_doc.md]

# Version Control
We use a NoizuLabs, Inc. Amnesia friendly schema versioning [tool](https://github.com/noizu/MnesiaVersioning).
A versioning database `Noizu.MnesiaVersioning.Database` tracks which change sets have been applied. Change sets themselves (including rollback methods) are defined in `lib/__your_app__/versioning/schema_provider.ex` and related files.

@See [Noizu MnesiaVersioning](https://github.com/noizu/MnesiaVersioning) for more details on using this tool.

# Naming Convention

## Entity Tables
- Database Tables should be in singular form and end in the word Table. `UserTable` not `User` or `Users`

## Nesting
- Logical name spacing should use a period between levels.  `LogicalParent.LogicalChildTable`, e.g. `User.ExtendedInfoTable`

## Join Tables
- One to One Join Tables should be in singular form with a `2` to indicate this is a join table `User2PrimaryEmailTable` not `UsersPrimaryEmails` or `User.PrimaryEmail`, etc.
- One to Many Join Tables should be in singular-plural form with a `2` to indicate join.  `User2EmailsTable` not `UsersEmails`, or `UserEmail`
- Many to Many Join Tables should be in plural-plural form with a `2` to indicate join.
  `Users2GroupsTable`
  Nested parents can be dropped if no ambiguity will be present, nesting periods should be removed `UserGroup2GroupRolesTable` not `User.Group2Group.RolesTable`

## Table Types
In general most tables should use :set or :ordered_set table type. The exception would be EAV, and Audit tables where the `:bag` type is preferred. The heavily leveraged Noizu ElxirScaffolding framework works best with numeric primary key based :set/:ordered_set tables.

@see (Noizu ElixirScaffolding Framework)[https://github.com/noizu/ElixirScaffolding]

# Coding Conventions

## Date Time
Date time entries should be stored as the elixir native `DateTime` type when possible. For efficient range searches the underlying DateTime objects may be converted to `Unix Epoch` time stamps and or `{year, month, day, hour, minute, second}` tuples or a combination of both but should when possible remain as standard DateTime object in any actual entity object.

E.g.

```
 %__YOUR_APP___.Foo{
   identifier: 1234,
   created_on: date_time_object
 }

 %__YOUR_APP___.Database.FooTable{
   identifier: 1234,
   created_on: foo.created_on |> DateTime.to_unix(),
   entity: foo
 }
```

All `Unix Epoch` should be stored in UTC time. for tuples the actual time_zone should be indicated as the first param `{:utc, year, month, ...}`

## Identifiers

Identifier fields should be named :identifier not nmid, nmaid, id, appengine_id, etc. and when possible should be numeric to avoid the need to override default noizu elixir scaffolding behaviour.

## Entity References

The Noizu ElixirScaffolding framework relies heavily on what we call *Entity References.* Entity references are tupples that include an indicator that this tuple is a reference, a module that can obtain an object from it's persistence layer/source and an identifier. A entity reference for a User object for example may look like `{:ref, __YOUR_APP___.User, 1234}`, The underlying object may then be obtained using the `Noizu.EntityReferenceProtocol.entity!` method.

E.g. `Noizu.EntityReferenceProtocol.entity!({:ref, __YOUR_APP___.User, 1234}) -> %User{identifier: 1234, ...}`

### SREF

 For passing data to non tuple supporting environments such as javascript and appengine the Noizu.EntityReferenceProtocol provides a sref implementation that converts refs to string format. `{:ref, __YOUR_APP___.User, 1234}` in sref format for example would become `"ref.user.1234"`. Behind the scenes entities provide their sref prefix `user` as a `use` argument when extending the `Noizu.Scaffolding.EntityBehaviour`.

 e.g.
 ```
 defmodule __YOUR_APP___.User do
    use Noizu.Scaffolding.EntityBehaviour,
      mnesia_table: __YOUR_APP___.Database.UserTable,
      sref_module: "user"    
 end
 ```

 The Noizu.Scaffolding.EntityBehaviour behaviour provides the default sref implementation to convert objects into sref format. However to convert sref strings back into ref, entity or record format the implementer must provide a defimple of the Noizu.EntityReferenceProtocol protocol for the bitstring type. Below is one possible implementation.

```
  defimpl Noizu.ERP, for: BitString do
    @module_lookup(%{
      __YOUR_APP___.User.sref_module() => __YOUR_APP___.User
      __YOUR_APP___.User.Location.sref_module() => __YOUR_APP___.User.Location
    })

    def lookup_module(sref_module) do
      Map.get(@module_lookup, sref_module, UnsupportedModule)
    end

    # Note - this encoding does not support ref strings that include periods in their module ref string or identifier.
    def ref(sref) do
      ["ref", m_str, id_str] = String.split(sref, ".")
      m = lookup_module(m_str)
      m.ref(id_str)      
    end
    def sref(sref), do: sref
    def entity(sref, options \\ nil), do: Noizu.ERP.entity(ref(sref), options)
    def entity!(sref, options \\ nil), do: Noizu.ERP.entity!(ref(sref), options)
    def record(sref, options \\ nil), do: Noizu.ERP.record(ref(sref), options)
    def record!(sref, options \\ nil), do: Noizu.ERP.record!(ref(sref), options)
  end

  defimpl Noizu.ERP, for: UnsupportedModule do
    def ref(_item), do: raise "UnsupportedModule"
    def sref(_item), do: raise "UnsupportedModule"
    def entity(_item, _options \\ nil), do: raise "UnsupportedModule"
    def entity!(_item, _options \\ nil), do: raise "UnsupportedModule"
    def record(_item, _options \\ nil), do: raise "UnsupportedModule"
    def record!(_item, _options \\ nil), do: raise "UnsupportedModule"
  end
```

### The Noizu.EntityReferenceProtocol

@see (Noizu ElixirScaffolding Framework)[https://github.com/noizu/ElixirScaffolding] for more details.

```
defprotocol Noizu.ERP do
  @doc "Cast to noizu reference object"
  def ref(obj)

  @doc "Cast to noizu string reference object"
  def sref(obj)

  @doc "Convert to persistence object. Options may be passed to coordinate actions like expanding embedded references."
  def record(obj, options \\ %{})

  @doc "Convert to persistence object Options may be passed to coordinate actions like expanding embedded references. (With transaction wrapper if required)"
  def record!(obj, options \\ %{})

  @doc "Convert to scaffolding.struct object. Options may be passed to coordinate actions like expanding embedded references."
  def entity(obj, options \\ %{})

  @doc "Convert to scaffolding.struct object Options may be passed to coordinate actions like expanding embedded references. (With transaction wrapper if required)"
  def entity!(obj, options \\ %{})
end # end defprotocol Noizu.ERP
```


### External References

External references (entities owned by remote apis, such as firebase for example) follow slighlty different conventions. And generally will look like
{:ext_ref, InterfaceForExternalStore, external_identifier} where InterfaceForExternalStore is a module that implements the relevant Noizu.EntityReferenceProtocol methods for communicating with the remote store.

### Entity Reference Naming Conventionts

When entities reference other entities as fields you will generally want to add a `_ref` suffix to those fields. If an entity has a foriegn key reference to a user record for example that field could be named `user_ref` or simple `owner_ref`.

Standardized naming convention makes the like of boiler plate code maintenance and scaffolding more straight forward.

`@see https://github.com/noizu/elixir_scaffolding for more details. `

## Embedded Structures
Generally tables will include nested objects that represent the actual record type. Any fields on the mnesia table itself are generally duplicates of data inside of the nested entity, exposed for indexing. Most tables will simple contain an identifier and entity field with all actual data inside of the entity object.

The primary Embedded object should be put in a field named  `entity:`

Even if a database does not require an embedded object (aka when it is very simple etc.) if should still follow this convention to make future expansion more straight forward and avoid the need for custom boilerplate scaffolding code. If absolutely necessary the deftable entry itself can implement the Noizu.Scaffolding.EntityBehaviour and EntityReferenceProtocol protocol.

The main exceptions being vary large list like tables such as Audit, EAV or Join tables.

`@see https://github.com/noizu/elixir_scaffolding for more details.`

## Audit Tables & EAV Tables

In a few places we use Audit and EAV tables. Although the tables and structs are different the underlying logic is generic.

```

  #-----------------------------------------------------------------------------
  # General Audit History Table
  #-----------------------------------------------------------------------------
  deftable AuditHistoryTable, [:entity, :time, :editor, :reason, :event], type: :bag, index: [], fragmentation: [number: 10, copying: %{disk!: 1}] do
    @type t :: %AuditHistoryTable{
      entity: Types.entity_reference,
      time: Types.unix_epoch,
      editor: Types.entity_reference,
      reason: String.t|:nil,
      event: tuple # e.g. {:event_name, {:type_specific_details}}
    }
  end

  #-----------------------------------------------------------------------------
  # Sparse Matrix
  #-----------------------------------------------------------------------------
  deftable EntityAttributeValueTable, [:entity, :attribute, :value], type: :bag, index: [:attribute], fragmentation: [number: 10, copying: %{disk!: 1}] do
    @type t :: %EntityAttributeValueTable{
        entity: Types.entiy_reference,
        attribute: atom|String.t,
        value: integer|atom|float|String.t|any
    }
  end
```

We use the :bag table types for audit tables so that we may quickly insert new records, as long as we follow conventions we can easily filter for records for specific entities or users  {:ref, User, identifier} etc.

Likewise we can get pretty flexible with our EAV tables.
For example we can put :tags all into a single MapSet
```
%EntityAttributeValueTable{
 entity: {:ref, User, 1234},
 attributes: :tags,
 value: MapSet.new(["banana", "apple"])
}
```
or in individual entries depending on how we plan on searching for records.

```
%EntityAttributeValueTable{
 entity: {:ref, Users, 1234},
 attributes: :tags,
 value: "banana"
}
%EntityAttributeValueTable{
 entity: {:ref, Users, 1234},
 attributes: :tags,
 value: "apple"
}
```
