defmodule NoizuPromptLingua.TRP.TestStub do
  @moduledoc """
  In-memory TRP shared-key API stub implementing
  `NoizuPromptLingua.TRP.Transport`. Backed by an ETS table, exercised through
  the REAL `Client` (auth header, envelope parsing, retries, cache), so unit
  tests cover the whole client+cache stack without a network.

  State helpers (`seed_org/1`, `seed_project/2`, `seed_item/2`, …) double as
  fixture factories for tests of rewired modules.

  Error-injection: `queue_response(status, body)` pops one synthetic response
  before routing (401/403/422/429/500 envelopes, transport failures).

  Enable in config/test.exs: `:trp_transport` → this module, base_url/key set.
  """

  @behaviour NoizuPromptLingua.TRP.Transport

  @table :noizu_trp_test_stub
  @key "trp_sk_test"
  @auth "Bearer " <> @key

  # ── lifecycle ─────────────────────────────────────────────────

  def reset do
    ensure_table()
    :ets.insert(@table, {{:orgs, :map}, %{}, %{}, %{}, %{}, %{}, %{}, []})
    :ok
  end

  defp ensure_table do
    if :ets.whereis(@table) == :undefined do
      :ets.new(@table, [:named_table, :public, :set])
    end

    case :ets.lookup(@table, {:orgs, :map}) do
      [] -> :ets.insert(@table, {{:orgs, :map}, %{}, %{}, %{}, %{}, %{}, %{}, []})
      _ -> :ok
    end
  end

  defp update(fun) do
    ensure_table()

    [{k, orgs, projects, items, types, fields, type_fields, queued}] =
      :ets.lookup(@table, {:orgs, :map})

    result =
      fun.(%{
        orgs: orgs,
        projects: projects,
        items: items,
        types: types,
        fields: fields,
        type_fields: type_fields,
        queued: queued
      })

    :ets.insert(@table, {k, result.orgs, result.projects, result.items, result.types, result.fields, result.type_fields, result.queued})
    result.__ret
  end

  # ── fixture helpers ───────────────────────────────────────────

  def seed_org(id \\ Ecto.UUID.generate(), slug, name \\ "Stub Org") do
    update(fn s ->
      %{s | orgs: Map.put(s.orgs, id, %{id: id, slug: slug, name: name})} |> Map.put(:__ret, id)
    end)
  end

  def seed_project(org_id, attrs) do
    id = attrs[:id] || Ecto.UUID.generate()

    project =
      %{
        id: id,
        organization_id: org_id,
        name: attrs[:name] || "Project",
        slug: attrs[:slug],
        description: attrs[:description],
        status: attrs[:status] || "active",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      }
      |> Map.merge(Map.take(attrs, [:key_prefix]))

    update(fn s -> %{s | projects: Map.put(s.projects, {org_id, id}, project)} |> Map.put(:__ret, project) end)
  end

  def seed_item(org_id, attrs) do
    id = attrs[:id] || Ecto.UUID.generate()

    item =
      %{
        id: id,
        key: attrs[:key],
        number: attrs[:number] || System.unique_integer([:positive]),
        organization_id: org_id,
        project_id: attrs[:project_id],
        title: attrs[:title] || "Item",
        description: attrs[:description],
        item_type: attrs[:item_type] || "task",
        status: attrs[:status] || "open",
        priority: attrs[:priority],
        assignee: attrs[:assignee],
        reporter: attrs[:reporter],
        queue_id: attrs[:queue_id],
        parent_id: attrs[:parent_id],
        stage_id: attrs[:stage_id],
        iteration_id: attrs[:iteration_id],
        rank: attrs[:rank],
        start_date: nil,
        due_date: nil,
        estimate: nil,
        custom_fields: attrs[:custom_fields] || %{},
        inserted_at: attrs[:inserted_at] || DateTime.utc_now(),
        updated_at: attrs[:updated_at] || DateTime.utc_now()
      }

    update(fn s -> %{s | items: Map.put(s.items, {org_id, id}, item)} |> Map.put(:__ret, item) end)
  end

  def seed_type(org_id, attrs) do
    id = attrs[:id] || Ecto.UUID.generate()

    type = %{
      id: id,
      slug: attrs[:slug],
      name: attrs[:name] || attrs[:slug],
      description: attrs[:description],
      organization_id: attrs[:organization_id] || org_id,
      project_id: attrs[:project_id],
      icon: nil,
      color: nil,
      status_workflow: attrs[:status_workflow],
      disabled: Map.get(attrs, :disabled, false),
      deleted_at: nil,
      fields: attrs[:fields] || []
    }

    update(fn s -> %{s | types: Map.put(s.types, {org_id, id}, type)} |> Map.put(:__ret, type) end)
  end

  def seed_field(org_id, attrs) do
    id = attrs[:id] || Ecto.UUID.generate()

    field = %{
      id: id,
      slug: attrs[:slug],
      label: attrs[:label] || attrs[:slug],
      field_type: attrs[:field_type] || "text",
      organization_id: attrs[:organization_id] || org_id,
      project_id: attrs[:project_id],
      options: attrs[:options] || %{},
      default_value: attrs[:default_value],
      description: attrs[:description],
      disabled: Map.get(attrs, :disabled, false),
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }

    update(fn s -> %{s | fields: Map.put(s.fields, {org_id, id}, field)} |> Map.put(:__ret, field) end)
  end

  @doc "Registered org id for a slug (fixture convenience)."
  def org_id_by_slug(slug) do
    update(fn s -> Map.put(s, :__ret, Enum.find_value(s.orgs, fn {id, o} -> o.slug == slug && id end)) end)
  end

  @doc "Queue one synthetic response (or `{:transport, reason}`) before routing."
  def queue_response(response) do
    update(fn s -> s |> Map.update!(:queued, &(&1 ++ [response])) |> Map.put(:__ret, :ok) end)
  end

  @doc "Last request's Authorization header (auth assertions)."
  def last_auth do
    update(fn s -> Map.put(s, :__ret, Process.get(:trp_stub_last_auth)) end)
  end

  # ── transport callback ────────────────────────────────────────

  @impl true
  def request(method, _base_url, path, headers, body, _opts) do
    method = method |> to_string() |> String.upcase()
    auth = List.keyfind(headers, "authorization", 0) |> elem(1)
    Process.put(:trp_stub_last_auth, auth)
    ensure_table()

    [{_, orgs, projects, items, types, fields, type_fields, queued}] =
      :ets.lookup(@table, {:orgs, :map})

    case queued do
      [next | rest] ->
        :ets.update_element(@table, {:orgs, :map}, [{8, rest}])
        respond(next)

      [] ->
        state = %{orgs: orgs, projects: projects, items: items, types: types, fields: fields, type_fields: type_fields, queued: []}

        if auth != @auth do
          respond(401, %{"error" => "unauthorized"})
        else
          route(method, path, body, state)
        end
    end
  end

  defp respond(status, body), do: {:ok, status, body}
  defp respond({:transport, reason}), do: {:error, reason}
  defp respond({status, body}) when is_integer(status), do: {:ok, status, body}

  # ── routing ───────────────────────────────────────────────────

  defp route(method, path, body, state) do
    {path, query} = split_query(path)
    segs = path |> String.split("/", trim: true)

    case {method, segs} do
      {"GET", ["api", "v1", "organizations"]} ->
        respond(200, %{organizations: Map.values(state.orgs), meta: %{limit: 500, offset: 0}})

      {"GET", ["api", "v1", "organizations", org_id]} ->
        found(state.orgs[org_id], &%{organization: &1})

      {"GET", ["api", "v1", "organizations", org_id, "projects"]} ->
        respond(200, %{projects: list_for(state.projects, org_id, query)})

      {"POST", ["api", "v1", "organizations", org_id, "projects"]} ->
        created = seed_project(org_id, unwrap(body, :project) |> atomize())
        respond(201, %{project: created})

      {"GET", ["api", "v1", "organizations", org_id, "projects", id]} ->
        found(state.projects[{org_id, id}], &%{project: &1})

      {"PATCH", ["api", "v1", "organizations", org_id, "projects", id]} ->
        mutate(state.projects[{org_id, id}], body, fn p ->
          respond(200, %{project: update_seed(:projects, {org_id, id}, p, unwrap(body, :project))})
        end)

      {"DELETE", ["api", "v1", "organizations", org_id, "projects", id]} ->
        delete_seed(:projects, {org_id, id}, &%{project: &1})

      {"GET", ["api", "v1", "organizations", org_id, "items"]} ->
        respond(200, %{items: list_items(state.items, org_id, query)})

      {"POST", ["api", "v1", "organizations", org_id, "items"]} ->
        attrs = unwrap(body, :item) |> atomize()
        attrs = Map.put(attrs, :key, attrs[:key] || "TSK-#{System.unique_integer([:positive])}")
        created = seed_item(org_id, attrs)
        respond(201, %{item: created})

      {"GET", ["api", "v1", "organizations", org_id, "items", id]} ->
        item = state.items[{org_id, id}] || find_by_key(state.items, org_id, id)
        found(item, &%{item: &1})

      {"PATCH", ["api", "v1", "organizations", org_id, "items", id]} ->
        item = state.items[{org_id, id}] || find_by_key(state.items, org_id, id)

        mutate(item, body, fn ->
          respond(200, %{item: update_seed(:items, {org_id, item.id}, item, unwrap(body, :item))})
        end)

      {"DELETE", ["api", "v1", "organizations", org_id, "items", id]} ->
        delete_seed(:items, {org_id, id}, &%{item: &1})

      {"GET", ["api", "v1", "organizations", org_id, "definitions", "types"]} ->
        rows =
          list_for(state.types, org_id, query)
          |> Enum.reject(&(!is_nil(&1.deleted_at)))
          |> Enum.map(&expand_fields(state, org_id, &1))

        respond(200, %{types: rows})

      {"POST", ["api", "v1", "organizations", org_id, "definitions", "types"]} ->
        created = seed_type(org_id, unwrap(body, :type) |> atomize())
        respond(201, %{type: created})

      {"GET", ["api", "v1", "organizations", org_id, "definitions", "types", id]} ->
        found(state.types[{org_id, id}], &%{type: expand_fields(state, org_id, &1)})

      {"PATCH", ["api", "v1", "organizations", org_id, "definitions", "types", id]} ->
        t = state.types[{org_id, id}]

        mutate(t, body, fn ->
          updated = update_seed(:types, {org_id, id}, t, unwrap(body, :type))
          respond(200, %{type: expand_fields(state, org_id, updated)})
        end)

      {"DELETE", ["api", "v1", "organizations", org_id, "definitions", "types", id]} ->
        delete_seed(:types, {org_id, id}, &%{type: &1}, soft: true)

      {"POST", ["api", "v1", "organizations", org_id, "definitions", "types", id, "fields"]} ->
        t = state.types[{org_id, id}]

        mutate(t, body, fn ->
          new_fields = body |> atomize() |> Map.get(:fields, [])
          merged = merge_fields(new_fields, t.fields)
          updated = update_seed(:types, {org_id, id}, t, %{fields: merged})
          respond(200, %{type: expand_fields(state, org_id, updated)})
        end)

      {"DELETE", ["api", "v1", "organizations", org_id, "definitions", "types", id, "fields", field_id]} ->
        t = state.types[{org_id, id}]

        mutate(t, body, fn ->
          remaining = Enum.reject(t.fields, &(&1.id == field_id))

          if length(remaining) == length(t.fields) do
            respond(404, %{"error" => "Field not found"})
          else
            updated = update_seed(:types, {org_id, id}, t, %{fields: remaining})
            respond(200, %{type: expand_fields(state, org_id, updated)})
          end
        end)

      {"GET", ["api", "v1", "organizations", org_id, "definitions", "fields"]} ->
        respond(200, %{fields: list_for(state.fields, org_id, query)})

      {"POST", ["api", "v1", "organizations", org_id, "definitions", "fields"]} ->
        created = seed_field(org_id, unwrap(body, :field) |> atomize())
        respond(201, %{field: created})

      {"GET", ["api", "v1", "organizations", org_id, "definitions", "fields", id]} ->
        found(state.fields[{org_id, id}], &%{field: &1})

      {"PATCH", ["api", "v1", "organizations", org_id, "definitions", "fields", id]} ->
        f = state.fields[{org_id, id}]

        mutate(f, body, fn ->
          respond(200, %{field: update_seed(:fields, {org_id, id}, f, unwrap(body, :field))})
        end)

      {"DELETE", ["api", "v1", "organizations", org_id, "definitions", "fields", id]} ->
        delete_seed(:fields, {org_id, id}, &%{field: &1})

      _ ->
        respond(404, %{"error" => "Not found"})
    end
  end

  defp split_query(path) do
    case String.split(path, "?", parts: 2) do
      [p] -> {p, %{}}
      [p, q] -> {p, URI.decode_query(q)}
    end
  end

  # Client wraps write bodies (%{item: ...} etc. — mirrors TRP controllers).
  defp unwrap(body, key) when is_map(body) do
    case body do
      %{^key => inner} when is_map(inner) -> inner
      _ -> body
    end
  end

  defp unwrap(body, _key), do: body

  defp atomize(body) when is_map(body) do
    Map.new(body, fn {k, v} -> {if(is_atom(k), do: k, else: String.to_atom(k)), v} end)
  end

  # Spec 4.4: a type's `fields` arrive as full field JSON + required/position.
  defp expand_fields(state, org_id, type) do
    fields =
      Enum.map(type.fields, fn f ->
        base = state.fields[{org_id, f.id}] || f

        Map.merge(base, %{
          required: Map.get(f, :required, false),
          position: Map.get(f, :position, 0)
        })
      end)

    Map.put(type, :fields, fields)
  end

  defp found(nil, _wrap), do: respond(404, %{"error" => "Resource not found"})
  defp found(value, wrap), do: respond(200, wrap.(value))

  defp mutate(nil, _body, _cont), do: respond(404, %{"error" => "Resource not found"})
  defp mutate(_value, _body, cont), do: cont.()

  defp list_for(map, org_id, query) do
    map
    |> Enum.filter(fn {{o, _}, v} -> o == org_id end)
    |> Enum.map(fn {_, v} -> v end)
    |> filter_project(query)
  end

  defp filter_project(rows, %{"project_id" => pid}) when is_binary(pid),
    do: Enum.filter(rows, &(&1.project_id == pid))

  defp filter_project(rows, _), do: rows

  defp list_items(map, org_id, query) do
    map
    |> Enum.filter(fn {{o, _}, _} -> o == org_id end)
    |> Enum.map(fn {_, v} -> v end)
    |> filter_project(query)
    |> filter_status(query)
    |> Enum.sort_by(&{&1.inserted_at, &1.id})
  end

  defp filter_status(rows, %{"status" => s}), do: Enum.filter(rows, &(&1.status == s))
  defp filter_status(rows, _), do: rows

  defp find_by_key(items, org_id, key) do
    Enum.find_value(items, fn {{o, _}, v} -> o == org_id && v.key == key && v end)
  end

  defp update_seed(kind, key, _current, changes) do
    update(fn s ->
      current = Map.get(s, kind)[key]

      updated =
        Map.merge(current, atomize(changes) |> Map.new(fn {k, v} -> {k, v} end))
        |> Map.put(:updated_at, DateTime.utc_now())

      %{s | kind => Map.put(Map.get(s, kind), key, updated)} |> Map.put(:__ret, updated)
    end)
  end

  defp delete_seed(kind, key, _wrap, opts \\ []) do
    current = update(fn s -> Map.put(s, :__ret, Map.get(s, kind)[key]) end)

    if current do
      changes = if opts[:soft], do: %{deleted_at: DateTime.utc_now()}, else: %{}

      update(fn s ->
        new =
          if opts[:soft] do
            Map.update!(s, kind, &Map.put(&1, key, Map.merge(current, atomize(changes))))
          else
            Map.update!(s, kind, &Map.delete(&1, key))
          end

        new |> Map.put(:__ret, :ok)
      end)

      respond(204, nil)
    else
      respond(404, %{"error" => "Resource not found"})
    end
  end

  defp merge_fields(new_fields, current) do
    Enum.map(new_fields, fn f -> %{id: f.id, required: Map.get(f, :required, false), position: Map.get(f, :position, 0)} end) ++
      Enum.reject(current, fn cf -> Enum.any?(new_fields, &(&1.id == cf.id)) end)
  end
end
