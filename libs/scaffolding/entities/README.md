Noizu Entities
==========================
Noizu Entity Scaffolding provides a mechanism to define extended
elixir structs with metadata for specifying access control, flagging sensitive data,
specifying json formatting, specifying text/geo/vector indexing, and per entity caching settings. 

It provides a streamlined standardized mechanism to configure ORM mapping 
between ecto, mnesia, redis and other persistence layers while reducing the amount of
boilerplate code needed while providing streamlined cache, security and indexing controls. 
Including support for multiple layers of cache/persistence.

It automatically hooks your entities up to support noizu_labs_context and noizu_labs_erp protocols. 

# Table of Contents
1. [Overview](#overview)
2. [Tasks](#tasks)
3. [Persistence](#persistence)
4. [Indexing](#indexing)
5. [Caching](#caching)
6. [Entity](#entity-definition) 
   1. Overview
   2. ERP
   3. Field Types
   4. Cache
   5. Index
   6. Annotation
      1. Access Control
      2. Sensitive Data
      3. Transient Data
      4. JSON Formatting
      5. Cache
      6. Index 
7. [Repo](#repo-definition)

# Overview
details pending

# Tasks
You can use the helpers to construct entities and related ecto classes. 
`mix nz.gen.entity my_entity store=ecto sref=my-entity field=biz:integer`
Generation is not perfect and some manual editing of ecto and entity may be required.


# Persistence
details pending

# Indexing
details pending

# Caching
details pending

# Entity Definition
details pending

# Repo Definition
details pending

# Declaring a Noizu Entity
Behind the scenes a Noizu.Entity is just a defstruct with meta data added. 
Below is simple declaration and the effective defstruct it generates. 

```elixir
defmodule MyApp.Entity.Bar do
    @vsn 1.0
    use Noizu.Entity 
    def_entity do
        identifier :integer
        field :name
        field :title, "Hello"
        field :description
    end
end
```

The above will generate a struct as below plus meta fields accessible by Noizu.Entity behavior defined methods. 
```elixir
defmodule MyApp.Entity.Bar do 
  defstruct [
      identifier: nil,
      name: nil,
      title: "Hello",
      description: nil,
      # Generated Fields
      vsn: 1.0, 
      meta: nil,
      __transient__: nil
  ] 
end
```

# JSON Formatting
You may add json formatting annotation to Noizu.Entities to define how an entity should be
displayed for different json formats (:admin, :client,...)
```
@json true 
@json :include
@json false
@json :omit
@json template: :omit
@json as: :apple, omit: false
@json for: [:breif, :apple], set: [as: :alias, omit: false]
```

details_pending


# Security/Access Control
You may add annotation to control required permissions to access/return an entity field, 
(:admin, :user, {:permission, name}, {:custom, {m,f,a})

```
@restrict :user
@restrict {m,f,a} # [entity, field, context] ++ a
@restrict :admin
@restrict {:group, group}
```
details_pending

# Indexing 
details_pending

# Cache
details_pending



# Extended Entity Declarations

## Transient Annotation
Transient fields (fields that should not be persisted to persistence layers/cache) can be annotated or placed in transient blocks.

```elixir
defmodule MyApp.Entity.Bar do
    @vsn 1.0
    use Noizu.Entity 
    def_entity do
        identifier :integer
        field :name
        
        @transient true
        field :transient_field
        
        field :peristed_field
                
        transient do 
          field :transient_field_2
          field :transient_field_3
        end
        
        field :peristed_field2
    end
end
```





## PII Annotation 
Flags with sensitive information can be marked by using pii blocks or via `@pii` annotation.
The resulting struct is unchanged but meta data tracks pii status and is used to alter inspect and logging output. 


```elixir
defmodule MyApp.Entity.Bar do
    @vsn 1.0
    use Noizu.Entity 
    def_entity do
        identifier :integer
        field :name
        
        @pii :sensitive
        field :passport
        
        pii() do 
         field :pii_sensitive_field
         field :pii_sensitive_field2 
        end
           
        pii(:low) do 
          field :pii_low_field
          field :pii_low_field2 
        end
        
    end
end
```
