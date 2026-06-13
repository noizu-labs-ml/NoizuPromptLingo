# elixir-weaviate

Elixir client for Weaviate vector database. Full CRUD, GraphQL queries, class DSL, batch operations.

## Installation
```elixir
{:noizu_weaviate, github: "noizu-labs/elixir-weaviate"}
```

## Configuration
```elixir
config :noizu_weaviate,
  weaviate_api_key: "your_api_key",
  endpoint: "http://localhost:8080"  # default
```

## Defining a Schema (Class DSL)

```elixir
defmodule MyApp.Product do
  use Noizu.Weaviate.Class

  weaviate_class("Product") do
    description "A product in the catalog"
    property :name, :string
    property :price, :number
    property :description, :text
    property :category, :string
  end
end
```

## CRUD Operations

```elixir
# Create
{:ok, response} = Noizu.Weaviate.Api.Objects.create(object)

# Read
{:ok, response} = Noizu.Weaviate.Api.Objects.get(class_name, object_id)

# Update
{:ok, response} = Noizu.Weaviate.Api.Objects.update(updated_object)

# Delete
{:ok, response} = Noizu.Weaviate.Api.Objects.delete(class_name, object_id)
```

## Batch Operations

```elixir
# Batch create
{:ok, response} = Noizu.Weaviate.Api.Batch.create(objects)

# Batch delete
{:ok, response} = Noizu.Weaviate.Api.Batch.delete(class_name, filters)
```

## GraphQL Queries

```elixir
# Get query
query = Noizu.Weaviate.GraphQL.Get.new("Product")
|> Noizu.Weaviate.GraphQL.Get.with_fields([:name, :price, :description])
|> Noizu.Weaviate.GraphQL.Where.add_filter(%{
  path: ["category"],
  operator: "Equal",
  valueString: "electronics"
})
|> Noizu.Weaviate.GraphQL.Additional.with_additional([:id, :certainty, :distance])

{:ok, results} = Noizu.Weaviate.GraphQL.execute(query)
```

### GroupBy
```elixir
query = Noizu.Weaviate.GraphQL.Get.new("Product")
|> Noizu.Weaviate.GraphQL.GroupBy.group_by("category", 10)
```

## Schema Management

```elixir
# Create class from module definition
{:ok, _} = Noizu.Weaviate.Api.Schema.create(MyApp.Product)

# List all classes
{:ok, schema} = Noizu.Weaviate.Api.Schema.get()

# Delete class
{:ok, _} = Noizu.Weaviate.Api.Schema.delete("Product")
```

## Other APIs

```elixir
Noizu.Weaviate.Api.Meta.get()              # Instance metadata
Noizu.Weaviate.Api.Nodes.get()             # Cluster node info
Noizu.Weaviate.Api.Auth.liveness()         # Health check
Noizu.Weaviate.Api.Backups.create(params)  # Backup
Noizu.Weaviate.Api.Classification.create(params)  # Classification task
```

## Key Concepts
1. Class DSL maps Elixir modules to Weaviate schemas
2. GraphQL builder provides type-safe query construction
3. Batch operations for bulk insert/delete
4. Vector search via nearVector, nearText, hybrid queries
5. Uses Finch for HTTP, Jason for JSON
