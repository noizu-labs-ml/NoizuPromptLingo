defmodule NoizuPromptLingua.MCP.VFS.Customers do
  @moduledoc """
  VFS backend for the `customers` group (MCP-VFS-GROUP-MOUNTS.md §2.14) —
  entity-dir over the `NoizuPromptLingua.Domains.Customers` context (customer
  personas + segments, the marketing audience model — not agent personas).
  Full absolute paths, self-enforced §1.3 gates (via
  `NoizuPromptLingua.MCP.VFS.Scope`), independently conformance-testable.

      /tobor/{org}/customers                             → subtree root
      /tobor/{org}/customers/overview.md                 → Overview tool render
      /tobor/{org}/customers/personas/                   → readdir (PersonaList)
      /tobor/{org}/customers/personas/{key}/             → entity dir (PersonaGet)
      /tobor/{org}/customers/personas/{key}/record.json  → projection (read) / PersonaUpdate (write)
      /tobor/{org}/customers/personas/{key}/tickets.json → linked tickets (read) / link-set sync (write)
      /tobor/{org}/customers/segments/…                  → same shape under `segments/` (Segment*)

  ## Decisions & conventions

    * **Entity keys are the org-unique `slug`** (stable keys, §1.1; the
      contexts guarantee slug uniqueness per org); `{key}` may also be the
      entity UUID — `resolve_persona/2` / `resolve_segment/2` accept either.
      Listings emit slugs.
    * **`record.json` is writable** — `PersonaUpdate` / `SegmentUpdate` map to
      a write whose body is a JSON object of attrs. Canonical identity keys
      (`id`, `organization_id`, `slug`) in the body are ignored: the path is
      the truth. Malformed or non-object JSON is `:eio`; changeset failures
      are `:eio`.
    * **Create** writes the entity dir (`create` at `…/personas/{slug}`) with
      a JSON object body; `name` defaults to the slug (the changesets require
      it). Create on `record.json` / `tickets.json` is `:eexist` when the
      entity exists (`:enoent` when it does not — the files exist by
      definition once the entity does).
    * **`tickets.json`** is always present on a persona (a `[]` when
      unlinked) and never on a segment. Read gives the link rows; write
      replaces the default-type (`relates_to`) link set with the JSON array
      of ticket UUIDs in the body — the diff fans out to
      `PersonaLinkTicket` / `PersonaUnlinkTicket`. Unknown ticket ids are
      `:enoent`; non-array (or non-string-element) bodies are `:eio`. The
      sync is best-effort sequential (the context has no transaction
      primitive); a mid-way failure surfaces `:eio`.
    * **Delete**: these domains expose no Delete tools, so `remove` is
      `:enosys` for an existing entity (`:enoent` otherwise) — tool-faithful
      (the §2.14 table lists List/Get/Create/Update only).
    * **PersonaDraft** (LLM generation) is not a file-plane op: a write at
      `…/personas/{key}/draft` is `:enosys`. Generation ops move to the §3.8
      job-dir convention when the Wave 4 Jobs runner lands.
    * **Pagination** — lib `Features.Pagination` opaque offset cursors over an
      org-bounded fetch (ceiling 500).

  Liveness: VFS mutations are live; MCP-surface edits surface within the TTL.
  """

  use Noizu.MCP.VFS

  alias Noizu.MCP.Server.Features.Pagination
  alias NoizuPromptLingua.Domains.Customers
  alias NoizuPromptLingua.Domains.Tickets
  alias NoizuPromptLingua.MCP.Resolve
  alias NoizuPromptLingua.MCP.VFS.{Overview, Scope}

  @group "customers"
  @fetch_ceiling 500
  @page_size 100

  @subtrees ["personas", "segments"]
  @entity_files ["record.json", "tickets.json"]
  @persona_files @entity_files
  @segment_files ["record.json"]

  @identity_keys [:id, :organization_id, :slug]
  @link_type "relates_to"

  # ── stat/2 ────────────────────────────────────────────────────────────────

  @impl true
  def stat(path, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, gate} <- Scope.gate(ctx, org, @group) do
      stat_rest(org, rest, gate, ctx)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  defp stat_rest(_org, [], gate, _ctx), do: {:ok, %{Scope.dir_node() | writable: gate.writable}}

  defp stat_rest(_org, ["overview.md"], _gate, _ctx),
    do: {:ok, Scope.file_node(byte_size(Overview.md(overview_tool(), @group)))}

  defp stat_rest(org, [subtree], gate, _ctx) when subtree in @subtrees do
    with {:ok, _org_id} <- org_id(org) do
      {:ok, %{Scope.dir_node() | writable: gate.writable}}
    end
  end

  defp stat_rest(org, [subtree, key], gate, _ctx) when subtree in @subtrees do
    with {:ok, _entity} <- resolve_entity(org, subtree, key) do
      {:ok, %{Scope.dir_node() | writable: gate.writable}}
    end
  end

  defp stat_rest(org, [subtree, key, filename], _gate, _ctx)
       when subtree in @subtrees and filename in @entity_files do
    with {:ok, entity} <- resolve_entity(org, subtree, key),
         {:ok, body} <- entity_file(subtree, entity, filename) do
      {:ok, Scope.file_node(byte_size(body))}
    end
  end

  defp stat_rest(_org, _rest, _gate, _ctx), do: {:error, :enoent}

  # ── list/3 ────────────────────────────────────────────────────────────────

  @impl true
  def list(path, cursor, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, _gate} <- Scope.gate(ctx, org, @group) do
      list_rest(org, rest, cursor, ctx)
    end
  end

  defp list_rest(_org, [], cursor, _ctx) do
    paginate(
      [Scope.file_entry("overview.md"), Scope.dir_entry("personas"), Scope.dir_entry("segments")],
      cursor
    )
  end

  defp list_rest(_org, ["overview.md"], _cursor, _ctx), do: {:error, :enotdir}

  defp list_rest(org, [subtree], cursor, _ctx) when subtree in @subtrees do
    with {:ok, entities} <- list_entities(org, subtree) do
      paginate(Enum.map(entities, &Scope.dir_entry(&1.slug)), cursor)
    end
  end

  defp list_rest(org, [subtree, key], cursor, _ctx) when subtree in @subtrees do
    with {:ok, _entity} <- resolve_entity(org, subtree, key) do
      files = if subtree == "personas", do: @persona_files, else: @segment_files
      paginate(Scope.file_entries(files), cursor)
    end
  end

  defp list_rest(_org, _rest, _cursor, _ctx), do: {:error, :enotdir}

  # ── read/2 ────────────────────────────────────────────────────────────────

  @impl true
  def read(path, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, _gate} <- Scope.gate(ctx, org, @group) do
      read_rest(org, rest, ctx)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  defp read_rest(_org, [], _ctx), do: {:error, :eisdir}

  defp read_rest(_org, ["overview.md"], _ctx),
    do: {:ok, Overview.md(overview_tool(), @group), Scope.version()}

  defp read_rest(org, [subtree], _ctx) when subtree in @subtrees,
    do: with({:ok, _org_id} <- org_id(org), do: {:error, :eisdir})

  defp read_rest(org, [subtree, key], _ctx) when subtree in @subtrees do
    case resolve_entity(org, subtree, key) do
      {:ok, _entity} -> {:error, :eisdir}
      error -> error
    end
  end

  defp read_rest(org, [subtree, key, filename], _ctx)
       when subtree in @subtrees and filename in @entity_files do
    with {:ok, entity} <- resolve_entity(org, subtree, key),
         {:ok, body} <- entity_file(subtree, entity, filename) do
      {:ok, body, Scope.version()}
    end
  end

  defp read_rest(_org, _rest, _ctx), do: {:error, :enoent}

  # ── create/3 ──────────────────────────────────────────────────────────────

  @impl true
  def create(path, data, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, gate} <- Scope.gate(ctx, org, @group),
         :ok <- Scope.require_writable(gate) do
      create_rest(org, rest, data)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  # PersonaCreate / SegmentCreate: slug from the path, attrs from the JSON body.
  defp create_rest(org, [subtree, key], data)
       when subtree in @subtrees and is_binary(data) do
    with {:ok, org_id} <- org_id(org),
         {:ok, body} <- decode_object(data),
         {:ok, attrs} <- atomize(body),
         :ok <- collision_ok(org, subtree, key) do
      attrs =
        attrs
        |> Map.drop(@identity_keys)
        |> Map.put_new(:name, key)
        |> Map.put(:organization_id, org_id)
        |> Map.put(:slug, key)

      insert_entity(subtree, attrs)
    end
  end

  defp create_rest(_org, [_subtree, _key], :dir), do: {:error, :enosys}

  defp create_rest(org, [subtree, key, _filename], _data) when subtree in @subtrees do
    case resolve_entity(org, subtree, key) do
      {:ok, _entity} -> {:error, :eexist}
      error -> error
    end
  end

  defp create_rest(_org, _rest, _data), do: {:error, :enosys}

  # ── write/3 ───────────────────────────────────────────────────────────────

  @impl true
  def write(path, data, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, gate} <- Scope.gate(ctx, org, @group),
         :ok <- Scope.require_writable(gate) do
      write_rest(org, rest, data)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  # PersonaUpdate / SegmentUpdate: JSON object merged onto the entity; the
  # path's identity keys win over any in the body.
  defp write_rest(org, [subtree, key, "record.json"], data)
       when subtree in @subtrees and is_binary(data) do
    with {:ok, entity} <- resolve_entity(org, subtree, key),
         {:ok, body} <- decode_object(data),
         {:ok, attrs} <- atomize(body) do
      case update_entity(subtree, entity.id, Map.drop(attrs, @identity_keys)) do
        {:ok, updated} ->
          {:ok, Scope.file_node(byte_size(entity_file!(subtree, updated, "record.json")))}

        {:error, _changeset} ->
          {:error, :eio}
      end
    end
  end

  # PersonaLinkTicket / PersonaUnlinkTicket fan-out: the body replaces the
  # default-type link set.
  defp write_rest(org, ["personas", key, "tickets.json"], data) when is_binary(data) do
    with {:ok, persona} <- resolve_entity(org, "personas", key),
         {:ok, ticket_ids} <- decode_ticket_ids(data),
         :ok <- sync_ticket_links(persona.id, ticket_ids) do
      {:ok, Scope.file_node(byte_size(ticket_links_json(persona.id)))}
    end
  end

  # PersonaDraft (LLM generation) — not a file-plane op (§3.8 job-dir, Wave 4).
  defp write_rest(org, ["personas", key, "draft"], _data) do
    case resolve_entity(org, "personas", key) do
      {:ok, _persona} -> {:error, :enosys}
      error -> error
    end
  end

  defp write_rest(org, [subtree, key, filename], _data)
       when subtree in @subtrees and filename in @entity_files do
    case resolve_entity(org, subtree, key) do
      {:ok, _entity} -> {:error, :enosys}
      error -> error
    end
  end

  defp write_rest(_org, _rest, _data), do: {:error, :enosys}

  # ── remove/2 ──────────────────────────────────────────────────────────────

  # No Delete tools in the domain — removal stays off the file plane.
  @impl true
  def remove(path, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, gate} <- Scope.gate(ctx, org, @group),
         :ok <- Scope.require_writable(gate) do
      remove_rest(org, rest)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  defp remove_rest(org, [subtree, key]) when subtree in @subtrees do
    case resolve_entity(org, subtree, key) do
      {:ok, _entity} -> {:error, :enosys}
      error -> error
    end
  end

  defp remove_rest(_org, _rest), do: {:error, :enosys}

  # ── resolution ────────────────────────────────────────────────────────────

  defp overview_tool, do: NoizuPromptLingua.Domains.Customers.Tools.Overview

  defp org_id(org) do
    case Resolve.organization_id(org) do
      nil -> {:error, :enoent}
      id -> {:ok, id}
    end
  end

  defp resolve_entity(org, subtree, key) when subtree in @subtrees do
    with {:ok, org_id} <- org_id(org) do
      entity =
        case subtree do
          "personas" -> Customers.resolve_persona(org_id, key)
          "segments" -> Customers.resolve_segment(org_id, key)
        end

      case entity do
        nil -> {:error, :enoent}
        entity -> {:ok, entity}
      end
    end
  end

  defp resolve_entity(_org, _subtree, _key), do: {:error, :enoent}

  defp list_entities(org, subtree) do
    with {:ok, org_id} <- org_id(org) do
      case subtree do
        "personas" ->
          {:ok, Customers.list_personas(organization_id: org_id, limit: @fetch_ceiling)}

        "segments" ->
          {:ok, Customers.list_segments(organization_id: org_id, limit: @fetch_ceiling)}
      end
    end
  end

  # ── entity files ──────────────────────────────────────────────────────────

  defp entity_file("personas", persona, "record.json"), do: {:ok, record_json(persona)}

  defp entity_file("personas", persona, "tickets.json"),
    do: {:ok, ticket_links_json(persona.id)}

  defp entity_file("segments", segment, "record.json"), do: {:ok, record_json(segment)}
  defp entity_file(_subtree, _entity, _filename), do: {:error, :enoent}

  defp entity_file!(subtree, entity, filename) do
    {:ok, body} = entity_file(subtree, entity, filename)
    body
  end

  defp record_json(persona_or_segment) do
    base = %{
      "id" => persona_or_segment.id,
      "slug" => persona_or_segment.slug,
      "name" => persona_or_segment.name,
      "project_id" => persona_or_segment.project_id,
      "tags" => persona_or_segment.tags,
      "status" => persona_or_segment.status,
      "organization_id" => persona_or_segment.organization_id,
      "created_at" => iso(persona_or_segment.inserted_at),
      "updated_at" => iso(persona_or_segment.updated_at)
    }

    extra =
      case persona_or_segment do
        %{demographics: _} ->
          %{
            "segment_id" => persona_or_segment.segment_id,
            "archetype" => persona_or_segment.archetype,
            "demographics" => persona_or_segment.demographics,
            "goals" => persona_or_segment.goals,
            "pains" => persona_or_segment.pains,
            "channels" => persona_or_segment.channels,
            "motivations" => persona_or_segment.motivations,
            "objections" => persona_or_segment.objections,
            "summary" => persona_or_segment.summary,
            "artifact_id" => persona_or_segment.artifact_id
          }

        _ ->
          %{
            "description" => persona_or_segment.description,
            "criteria" => persona_or_segment.criteria
          }
      end

    Jason.encode!(Map.merge(base, extra))
  end

  defp ticket_links_json(persona_id) do
    Customers.linked_tickets(persona_id)
    |> Enum.map(fn link ->
      %{
        "ticket_id" => link.ticket_id,
        "link_type" => link.link_type,
        "created_at" => iso(link.inserted_at)
      }
    end)
    |> Jason.encode!()
  end

  # ── ticket link-set sync ──────────────────────────────────────────────────

  defp decode_ticket_ids(data) do
    case Jason.decode(data) do
      {:ok, ids} when is_list(ids) ->
        if Enum.all?(ids, &is_binary/1), do: {:ok, Enum.uniq(ids)}, else: {:error, :eio}

      {:ok, _} ->
        {:error, :eio}

      {:error, _} ->
        {:error, :eio}
    end
  end

  defp sync_ticket_links(persona_id, ticket_ids) do
    current =
      persona_id
      |> Customers.linked_tickets()
      |> Enum.filter(&(&1.link_type == @link_type))
      |> Enum.map(& &1.ticket_id)

    with :ok <- validate_tickets(ticket_ids),
         :ok <- add_links(persona_id, ticket_ids -- current),
         :ok <- drop_links(persona_id, current -- ticket_ids) do
      :ok
    end
  end

  defp validate_tickets(ticket_ids) do
    if Enum.all?(ticket_ids, &(Tickets.get(&1) != nil)), do: :ok, else: {:error, :enoent}
  end

  defp add_links(_persona_id, []), do: :ok

  defp add_links(persona_id, [ticket_id | rest]) do
    case Customers.link_ticket(persona_id, ticket_id) do
      {:ok, _} -> add_links(persona_id, rest)
      {:error, _} -> {:error, :eio}
    end
  end

  defp drop_links(_persona_id, []), do: :ok

  defp drop_links(persona_id, [ticket_id | rest]) do
    case Customers.unlink_ticket(persona_id, ticket_id) do
      {:ok, _} -> drop_links(persona_id, rest)
      {:error, _} -> {:error, :eio}
    end
  end

  # ── create/update plumbing ────────────────────────────────────────────────

  defp collision_ok(org, subtree, key) do
    case resolve_entity(org, subtree, key) do
      {:ok, _} -> {:error, :eexist}
      {:error, :enoent} -> :ok
      error -> error
    end
  end

  defp insert_entity("personas", attrs) do
    case Customers.create_persona(attrs) do
      {:ok, persona} -> {:ok, %{Scope.dir_node() | writable: true, xattrs: %{"id" => persona.id}}}
      {:error, _changeset} -> {:error, :eio}
    end
  end

  defp insert_entity("segments", attrs) do
    case Customers.create_segment(attrs) do
      {:ok, segment} -> {:ok, %{Scope.dir_node() | writable: true, xattrs: %{"id" => segment.id}}}
      {:error, _changeset} -> {:error, :eio}
    end
  end

  defp insert_entity(_subtree, _attrs), do: {:error, :enosys}

  defp update_entity("personas", id, attrs), do: Customers.update_persona(id, attrs)
  defp update_entity("segments", id, attrs), do: Customers.update_segment(id, attrs)
  defp update_entity(_subtree, _id, _attrs), do: {:error, :enosys}

  # JSON object bodies only (arrays/scalars are :eio) — the attrs of the op.
  # Bodies are atomized via existing atoms (the schema field names); unknown
  # fields are rejected as :eio instead of leaking into the changeset.
  defp decode_object(data) do
    case Jason.decode(data) do
      {:ok, attrs} when is_map(attrs) -> {:ok, attrs}
      {:ok, _} -> {:error, :eio}
      {:error, _} -> {:error, :eio}
    end
  end

  defp atomize(attrs) do
    {:ok, Map.new(attrs, fn {k, v} -> {String.to_existing_atom(k), v} end)}
  rescue
    ArgumentError -> {:error, :eio}
  end

  # ── shared helpers ────────────────────────────────────────────────────────

  defp paginate(items, cursor) do
    cursor = if cursor == "", do: nil, else: cursor

    case Pagination.paginate(items, cursor, @page_size) do
      {:ok, page, next} -> {:ok, page, next}
      {:error, _} -> {:error, Noizu.MCP.Error.invalid_params("invalid cursor")}
    end
  end

  defp iso(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp iso(dt), do: to_string(dt)
end
