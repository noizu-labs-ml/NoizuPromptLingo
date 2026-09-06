defmodule NoizuPromptLingua.MCP.VFS.Market do
  @moduledoc """
  VFS backend for the `market` group (MCP-VFS-GROUP-MOUNTS.md §2.15) —
  entity-dir + job-backed generation over the `NoizuPromptLingua.Domains.Market`
  context (competitors, keywords, market reports). Full absolute paths,
  self-enforced §1.3 gates (via `NoizuPromptLingua.MCP.VFS.Scope`),
  independently conformance-testable.

      /tobor/{org}/market                              → subtree root
      /tobor/{org}/market/overview.md                  → Overview tool render
      /tobor/{org}/market/competitors/{key}/record.json → Competitor* (read/write)
      /tobor/{org}/market/keywords/{key}/record.json    → Keyword* (read/write)
      /tobor/{org}/market/reports/{key}/record.json     → Report projection (read-only)
      /tobor/{org}/market/reports/{key}/report.md       → artifact body (natural file, read)

  ## Decisions & conventions

    * **Entity keys are the org-unique `slug`** (stable keys, §1.1); `{key}`
      may also be the entity UUID — the context `resolve_*` helpers accept
      either. Listings emit slugs.
    * **Create** writes the entity dir with a JSON object body; `name`
      (competitors) / `term` (keywords) / `title` (reports) default to the
      slug where the changeset requires them. Create on the record files is
      `:eexist` when the entity exists.
    * **`record.json` write maps the Update tools** (`CompetitorUpdate`,
      `KeywordUpdate`) — JSON object merged onto the entity; identity keys
      (`id`, `organization_id`, `slug`) in the body are ignored. `reports/`
      record.json is **read-only**: the tool surface has no `ReportUpdate`.
    * **`report.md` is the report's natural file**: present only once the
      report has an artifact (`stat`/`read` are `:enoent` before that),
      content = the artifact's latest revision.
    * **Generation ops are `:enosys`** — writing `report.md` (the natural
      ReportGenerate surface) refuses, and `KeywordResearch` has no file
      plane node at all. Both are LLM-backed long-running ops that do not fit
      a sync control write (§3.8); they move to the job-dir convention when
      the Wave 4 Jobs runner lands.
    * **Delete**: no Delete tools in the domain — `remove` is `:enosys` for an
      existing entity (`:enoent` otherwise), tool-faithful per the §2.15
      table.
    * **Pagination** — lib `Features.Pagination` opaque offset cursors over an
      org-bounded fetch (ceiling 500). Keyword metrics `cpc`/`competition`
      are `Decimal`s and serialize as JSON numbers.

  Liveness: VFS mutations are live; MCP-surface edits surface within the TTL.
  """

  use Noizu.MCP.VFS

  alias Noizu.MCP.Server.Features.Pagination
  alias NoizuPromptLingua.Domains.{Artifacts, Market}
  alias NoizuPromptLingua.MCP.Resolve
  alias NoizuPromptLingua.MCP.VFS.{Overview, Scope}

  @group "market"
  @fetch_ceiling 500
  @page_size 100

  @subtrees ["competitors", "keywords", "reports"]

  @identity_keys [:id, :organization_id, :slug]

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
       when subtree in @subtrees and filename in ["record.json", "report.md"] do
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
    entries = [
      Scope.file_entry("overview.md"),
      Scope.dir_entry("competitors"),
      Scope.dir_entry("keywords"),
      Scope.dir_entry("reports")
    ]

    paginate(entries, cursor)
  end

  defp list_rest(_org, ["overview.md"], _cursor, _ctx), do: {:error, :enotdir}

  defp list_rest(org, [subtree], cursor, _ctx) when subtree in @subtrees do
    with {:ok, entities} <- list_entities(org, subtree) do
      paginate(Enum.map(entities, &Scope.dir_entry(&1.slug)), cursor)
    end
  end

  defp list_rest(org, [subtree, key], cursor, _ctx) when subtree in @subtrees do
    with {:ok, entity} <- resolve_entity(org, subtree, key) do
      files = entity_files(entity)
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
       when subtree in @subtrees and filename in ["record.json", "report.md"] do
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

  # CompetitorCreate / KeywordCreate / ReportCreate: slug from the path, attrs
  # from the JSON body.
  defp create_rest(org, [subtree, key], data)
       when subtree in @subtrees and is_binary(data) do
    with {:ok, org_id} <- org_id(org),
         {:ok, body} <- decode_object(data),
         {:ok, attrs} <- atomize(body),
         :ok <- collision_ok(org, subtree, key) do
      attrs =
        attrs
        |> Map.drop(@identity_keys)
        |> Map.put_new(default_name_key(subtree), key)
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

  # CompetitorUpdate / KeywordUpdate.
  defp write_rest(org, [subtree, key, "record.json"], data)
       when subtree in ["competitors", "keywords"] and is_binary(data) do
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

  # ReportGenerate — the natural surface of the report body write, refused
  # until the §3.8 job-dir convention lands (Wave 4 Jobs runner).
  defp write_rest(org, ["reports", key, "report.md"], _data) do
    case resolve_entity(org, "reports", key) do
      {:ok, _report} -> {:error, :enosys}
      error -> error
    end
  end

  # Reports have no Update tool; the record.json write is refused in place.
  defp write_rest(org, ["reports", key, "record.json"], _data) do
    case resolve_entity(org, "reports", key) do
      {:ok, _report} -> {:error, :enosys}
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

  defp overview_tool, do: NoizuPromptLingua.Domains.Market.Tools.Overview

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
          "competitors" -> Market.resolve_competitor(org_id, key)
          "keywords" -> Market.resolve_keyword(org_id, key)
          "reports" -> Market.resolve_report(org_id, key)
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
        "competitors" ->
          {:ok, Market.list_competitors(organization_id: org_id, limit: @fetch_ceiling)}

        "keywords" ->
          {:ok, Market.list_keywords(organization_id: org_id, limit: @fetch_ceiling)}

        "reports" ->
          {:ok, Market.list_reports(organization_id: org_id, limit: @fetch_ceiling)}
      end
    end
  end

  # ── entity files ──────────────────────────────────────────────────────────

  defp entity_files(%{artifact_id: _} = report) do
    # A report carries report.md only once a body artifact exists.
    if report_artifact_content(report) == nil,
      do: ["record.json"],
      else: ["record.json", "report.md"]
  end

  defp entity_files(_entity), do: ["record.json"]

  defp entity_file(_subtree, entity, "record.json"), do: {:ok, record_json(entity)}

  defp entity_file("reports", report, "report.md") do
    case report_artifact_content(report) do
      nil -> {:error, :enoent}
      content -> {:ok, content}
    end
  end

  defp entity_file(_subtree, _entity, _filename), do: {:error, :enoent}

  defp entity_file!(subtree, entity, filename) do
    {:ok, body} = entity_file(subtree, entity, filename)
    body
  end

  defp report_artifact_content(report) do
    case report.artifact_id && Artifacts.get(report.artifact_id) do
      {_artifact, %{content: content}} when is_binary(content) -> content
      _ -> nil
    end
  end

  defp record_json(entity) do
    entity
    |> Map.from_struct()
    |> Map.drop([:__meta__, :inserted_at, :updated_at])
    |> Map.new(fn {k, v} -> {Atom.to_string(k), jsonable(v)} end)
    |> Map.put("created_at", iso(entity.inserted_at))
    |> Map.put("updated_at", iso(entity.updated_at))
    |> Jason.encode!()
  end

  # Decimal metrics serialize as JSON numbers; everything else passes through.
  defp jsonable(%Decimal{} = d), do: Decimal.to_float(d)
  defp jsonable(v), do: v

  # ── create/update plumbing ────────────────────────────────────────────────

  defp default_name_key("competitors"), do: :name
  defp default_name_key("keywords"), do: :term
  defp default_name_key("reports"), do: :title

  defp collision_ok(org, subtree, key) do
    case resolve_entity(org, subtree, key) do
      {:ok, _} -> {:error, :eexist}
      {:error, :enoent} -> :ok
      error -> error
    end
  end

  defp insert_entity("competitors", attrs) do
    case Market.create_competitor(attrs) do
      {:ok, entity} -> {:ok, %{Scope.dir_node() | writable: true, xattrs: %{"id" => entity.id}}}
      {:error, _changeset} -> {:error, :eio}
    end
  end

  defp insert_entity("keywords", attrs) do
    case Market.create_keyword(attrs) do
      {:ok, entity} -> {:ok, %{Scope.dir_node() | writable: true, xattrs: %{"id" => entity.id}}}
      {:error, _changeset} -> {:error, :eio}
    end
  end

  defp insert_entity("reports", attrs) do
    case Market.create_report(attrs) do
      {:ok, entity} -> {:ok, %{Scope.dir_node() | writable: true, xattrs: %{"id" => entity.id}}}
      {:error, _changeset} -> {:error, :eio}
    end
  end

  defp insert_entity(_subtree, _attrs), do: {:error, :enosys}

  defp update_entity("competitors", id, attrs), do: Market.update_competitor(id, attrs)
  defp update_entity("keywords", id, attrs), do: Market.update_keyword(id, attrs)
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
