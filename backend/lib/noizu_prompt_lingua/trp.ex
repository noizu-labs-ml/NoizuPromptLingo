defmodule NoizuPromptLingua.TRP do
  @moduledoc """
  Resource facade over the TRP shared-key API: read-through ETS cache
  (definitions 300s / entities 30s per spec §5), write-bust on NPL's own
  writes, fail-soft to stale cache on transport errors, 429/5xx handled in
  `NoizuPromptLingua.TRP.Client`.

  Read returns: shaped value | `nil` (404) | `{:error, term()}`.
  Write returns: `{:ok, shaped}` | `{:error, term()}`.
  """

  alias NoizuPromptLingua.TRP.{Cache, Client, Error, Shapes}

  @definitions_ttl 300_000
  @entity_ttl 30_000

  # ── Organizations ─────────────────────────────────────────────

  def list_organizations do
    cached_get([:orgs, :list], @entity_ttl, fn ->
      with {:ok, json} <- get("/api/v1/organizations") do
        Enum.map(unwrap_list(json, :organizations), &Shapes.organization/1)
      end
    end)
  end

  def get_organization(id) do
    cached_get([:org, id], @entity_ttl, fn ->
      with {:ok, json} <- get("/api/v1/organizations/#{id}") do
        Shapes.organization(unwrap_one(json, :organization))
      end
    end)
  end

  def find_organization_by_slug(slug) do
    with list when is_list(list) <- list_organizations() do
      Enum.find(list, &(&1.slug == slug))
    end
  end

  # ── Projects ──────────────────────────────────────────────────

  def list_projects(org_id, opts \\ []) do
    key = [:projects_list, org_id, normalize(opts)]

    cached_get(key, @entity_ttl, fn ->
      with {:ok, json} <-
             get("/api/v1/organizations/#{org_id}/projects", query_opts(opts)) do
        Enum.map(unwrap_list(json, :projects), &Shapes.project/1)
      end
    end)
  end

  def get_project(org_id, id) do
    cached_get([:project, org_id, id], @entity_ttl, fn ->
      with {:ok, json} <- get("/api/v1/organizations/#{org_id}/projects/#{id}") do
        Shapes.project(unwrap_one(json, :project))
      end
    end)
  end

  def create_project(org_id, attrs) do
    with {:ok, json} <-
           Client.request(:post, "/api/v1/organizations/#{org_id}/projects",
             json: %{project: attrs}
           ) do
      bust_projects(org_id)
      {:ok, Shapes.project(unwrap_one(json, :project))}
    end
  end

  def update_project(org_id, id, attrs) do
    with {:ok, json} <-
           Client.request(:patch, "/api/v1/organizations/#{org_id}/projects/#{id}",
             json: %{project: attrs}
           ) do
      bust_projects(org_id)
      {:ok, Shapes.project(unwrap_one(json, :project))}
    end
  end

  def delete_project(org_id, id) do
    case Client.request(:delete, "/api/v1/organizations/#{org_id}/projects/#{id}") do
      {:ok, _} ->
        bust_projects(org_id)
        {:ok, nil}

      other ->
        not_found(other)
    end
  end

  # ── Items ─────────────────────────────────────────────────────

  def list_items(org_id, opts \\ []) do
    key = [:items_list, org_id, normalize(opts)]

    cached_get(key, @entity_ttl, fn ->
      with {:ok, json} <-
             get("/api/v1/organizations/#{org_id}/items", query_opts(opts)) do
        # TRP's wire order is `inserted_at asc, id asc` (spec §4.6, pinned for
        # pagination safety); NPL re-sorts here for legacy parity — pm_core
        # lists were `inserted_at desc` — so web/MCP consumers see the same
        # ordering as before the cutover. NB: limit/offset still windows the
        # TRP asc page; a deep page re-sorts only that window.
        rows = Enum.map(unwrap_list(json, :items), &Shapes.item/1)
        Enum.sort_by(rows, &{&1.inserted_at, &1.id}, :desc)
      end
    end)
  end

  @doc "`id_or_key` accepts a UUID or human key `PREFIX-NNN` (spec §4.3)."
  def get_item(org_id, id_or_key) do
    cached_get([:item, org_id, id_or_key], @entity_ttl, fn ->
      with {:ok, json} <- get("/api/v1/organizations/#{org_id}/items/#{id_or_key}") do
        Shapes.item(unwrap_one(json, :item))
      end
    end)
  end

  def create_item(org_id, attrs) do
    with {:ok, json} <-
           Client.request(:post, "/api/v1/organizations/#{org_id}/items", json: %{item: attrs}) do
      bust_items(org_id)
      {:ok, Shapes.item(unwrap_one(json, :item))}
    end
  end

  def update_item(org_id, id, attrs) do
    with {:ok, json} <-
           Client.request(:patch, "/api/v1/organizations/#{org_id}/items/#{id}",
        json: %{item: attrs}
      ) do
      bust_items(org_id)
      {:ok, Shapes.item(unwrap_one(json, :item))}
    end
  end

  # ── Type Definitions ──────────────────────────────────────────

  def list_types(org_id, project_id \\ nil) do
    key = [:types_list, org_id, project_id]

    cached_get(key, @definitions_ttl, fn ->
      with {:ok, json} <-
             get("/api/v1/organizations/#{org_id}/definitions/types",
               project_id: project_id
             ) do
        Enum.map(unwrap_list(json, :types), &Shapes.type_definition/1)
      end
    end)
  end

  def get_type(org_id, id) do
    cached_get([:type, org_id, id], @definitions_ttl, fn ->
      with {:ok, json} <-
             get("/api/v1/organizations/#{org_id}/definitions/types/#{id}") do
        Shapes.type_definition(unwrap_one(json, :type))
      end
    end)
  end

  def create_type(org_id, attrs) do
    with {:ok, json} <-
           Client.request(:post, "/api/v1/organizations/#{org_id}/definitions/types",
             json: %{type: attrs}
           ) do
      bust_definitions(org_id)
      {:ok, Shapes.type_definition(unwrap_one(json, :type))}
    end
  end

  def update_type(org_id, id, attrs) do
    with {:ok, json} <-
           Client.request(:patch, "/api/v1/organizations/#{org_id}/definitions/types/#{id}",
             json: %{type: attrs}
           ) do
      bust_definitions(org_id)
      {:ok, Shapes.type_definition(unwrap_one(json, :type))}
    end
  end

  @doc "Soft delete (TRP sets deleted_at). Returns `{:error, :not_found}` on 404."
  def delete_type(org_id, id) do
    case Client.request(:delete, "/api/v1/organizations/#{org_id}/definitions/types/#{id}") do
      {:ok, _} ->
        bust_definitions(org_id)
        {:ok, nil}

      other ->
        not_found(other)
    end
  end

  @doc """
  REPLACE a type's field association set — `update_type` with a `fields` body
  (spec §4.4: "replaces the full association set"). TRP's POST
  `…/types/:id/fields` takes a single `field_id`, so bulk changes ride update.
  """
  def set_type_fields(org_id, type_id, fields) when is_list(fields) do
    update_type(org_id, type_id, %{fields: fields})
  end

  @doc "DELETE `…/types/:id/fields/:field_id`."
  def remove_type_field(org_id, type_id, field_id) do
    case Client.request(
           :delete,
           "/api/v1/organizations/#{org_id}/definitions/types/#{type_id}/fields/#{field_id}"
         ) do
      {:ok, _} ->
        bust_definitions(org_id)
        {:ok, nil}

      other ->
        not_found(other)
    end
  end

  # ── Field Definitions ─────────────────────────────────────────

  def list_fields(org_id, project_id \\ nil) do
    key = [:fields_list, org_id, project_id]

    cached_get(key, @definitions_ttl, fn ->
      with {:ok, json} <-
             get("/api/v1/organizations/#{org_id}/definitions/fields",
               project_id: project_id
             ) do
        Enum.map(unwrap_list(json, :fields), &Shapes.field_definition/1)
      end
    end)
  end

  def get_field(org_id, id) do
    cached_get([:field, org_id, id], @definitions_ttl, fn ->
      with {:ok, json} <-
             get("/api/v1/organizations/#{org_id}/definitions/fields/#{id}") do
        Shapes.field_definition(unwrap_one(json, :field))
      end
    end)
  end

  def create_field(org_id, attrs) do
    with {:ok, json} <-
           Client.request(:post, "/api/v1/organizations/#{org_id}/definitions/fields",
             json: %{field: attrs}
           ) do
      bust_definitions(org_id)
      {:ok, Shapes.field_definition(unwrap_one(json, :field))}
    end
  end

  def update_field(org_id, id, attrs) do
    with {:ok, json} <-
           Client.request(:patch, "/api/v1/organizations/#{org_id}/definitions/fields/#{id}",
             json: %{field: attrs}
           ) do
      bust_definitions(org_id)
      {:ok, Shapes.field_definition(unwrap_one(json, :field))}
    end
  end

  def delete_field(org_id, id) do
    case Client.request(:delete, "/api/v1/organizations/#{org_id}/definitions/fields/#{id}") do
      {:ok, _} ->
        bust_definitions(org_id)
        {:ok, nil}

      other ->
        not_found(other)
    end
  end

  # ── Internals ─────────────────────────────────────────────────

  @doc """
  Read-through cache with write-bust support and fail-soft stale fallback
  (spec §5) — delegated to `Cache.cached_get/3`.
  """
  defdelegate cached_get(key, ttl, fetch), to: Cache

  # GET with 404 folded to nil per the facade contract (reads return nil on 404).
  defp get(path, query \\ [])

  defp get(path, []) do
    case Client.request(:get, path) do
      {:ok, json} -> {:ok, json}
      {:error, %Error{status: 404}} -> nil
      {:error, _} = err -> err
    end
  end

  defp get(path, query) do
    query =
      query
      |> List.wrap()
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Map.new()

    case Client.request(:get, path, query: query) do
      {:ok, json} -> {:ok, json}
      {:error, %Error{status: 404}} -> nil
      {:error, _} = err -> err
    end
  end

  defp bust_items(org_id) do
    Cache.bust_prefix([:items_list, org_id])
    Cache.bust_prefix([:item, org_id])
  end

  defp bust_projects(org_id) do
    Cache.bust_prefix([:projects_list, org_id])
    Cache.bust_prefix([:project, org_id])
  end

  defp bust_definitions(org_id) do
    Cache.bust_prefix([:types_list, org_id])
    Cache.bust_prefix([:type, org_id])
    Cache.bust_prefix([:fields_list, org_id])
    Cache.bust_prefix([:field, org_id])
  end

  defp query_opts(opts) do
    opts
    |> Keyword.take([
      :project_id,
      :status,
      :item_type,
      :priority,
      :assignee,
      :queue_id,
      :parent_id,
      :stage_id,
      :iteration_id,
      :limit,
      :offset
    ])
    |> Enum.reject(fn {_k, v} -> is_nil(v) or (is_list(v) and v == []) end)
    |> case do
      [] -> []
      q -> q
    end
  end

  # Deterministic cache keys: sort opts so [a: 1, b: 2] == [b: 2, a: 1].
  defp normalize(opts), do: Enum.sort(opts)

  # Envelope tolerance (spec §4.6: meta may or may not be present).
  defp unwrap_list(json, key) when is_map(json) do
    case Map.get(json, key) do
      list when is_list(list) -> list
      _ -> Enum.find(Map.values(json), &is_list/1) || []
    end
  end

  defp unwrap_list(_, _), do: []

  defp unwrap_one(json, key) when is_map(json) do
    case Map.get(json, key) do
      m when is_map(m) -> m
      _ -> Enum.find(Map.values(json), &is_map/1) || %{}
    end
  end

  defp unwrap_one(_, _), do: %{}

  defp not_found({:error, %Error{status: 404}}), do: {:error, :not_found}
  defp not_found(other), do: other
end
