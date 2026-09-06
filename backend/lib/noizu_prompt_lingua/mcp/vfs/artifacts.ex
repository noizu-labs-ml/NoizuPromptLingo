defmodule NoizuPromptLingua.MCP.VFS.Artifacts do
  @moduledoc """
  VFS backend for the `artifacts` group (MCP-VFS-GROUP-MOUNTS.md §2.2) —
  natural-file + immutable revisions, wired to the `NoizuPromptLingua.Domains.Artifacts`
  context. Paths are FULL absolute paths; the backend enforces its own §1.3
  gates (via `NoizuPromptLingua.MCP.VFS.Scope`) so it is independently
  conformance-testable under the Router's prefix dispatch.

      /tobor/{org}/artifacts                         → ArtifactList (readdir)
      /tobor/{org}/artifacts/overview.md             → Overview tool render
      /tobor/{org}/artifacts/{artifact}/record.json  → ArtifactGet (canonical doc)
      /tobor/{org}/artifacts/{artifact}/revs/v{n}.{ext}  → revision content
      /tobor/{org}/artifacts/{artifact}/current.txt  → pointer naming the active revision

  ## Decisions & conventions

    * **Artifact path segments** — artifacts have no slug; per §1.1 UUIDs render
      as `{type}-{short8}` (`artifact-a1b2c3d4`, first 8 hex of the UUID).
      Resolution accepts the full UUID, the short8 form, or an exact title
      match within the org (first by id on the astronomically unlikely short8
      collision). `ArtifactCreate`'s create-path name becomes the artifact
      TITLE; its canonical dir name derives from the generated UUID (read it
      back from `record.json`/readdir).
    * **Revisions are immutable** (§2.2): `create` on `revs/v{n}.{ext}` is
      create-only — an existing revision collides with `:eexist`, only the
      NEXT revision (`max + 1`) can be created (anything further is `:enoent`),
      and `write` on an existing revision is `:eexist`. This is the file-plane
      mapping of `Artifact.AddRevision` with no new VFS primitives.
    * **`current.txt` is a pointer file** (§6 R1 pointer convention, matching
      the instructions `active` file): one line `v{n}.{ext}` naming the active
      (highest-numbered) revision. It is read-only — no set-active tool exists.
    * **`{ext}`** derives from the artifact's `mime_type` (text/markdown →
      `md`, application/json → `json`, …; unknown/nil → `txt`) at read time;
      only the derived extension is accepted on revision creates, so readdir
      names and create names always agree. If the mime changes, all revision
      file names shift label together (content is untouched).
    * **No delete surface**: artifact/revision removal is absent from the tool
      catalog — `remove/2` is `:enosys` everywhere (§3.5). There is also no
      update tool, so `record.json`/`current.txt` writes are `:enosys`.
    * **ArtifactGetBinary → [B1]**: the wire is UTF-8 JSON text, so binary
      retrieval stays blocked (§3.3); `artifact_revisions.content` is
      text-only today.
    * **Pagination** — lib `Features.Pagination` opaque offset cursors over an
      org-bounded fetch (ceiling 500); artifacts are not a monster class.

  Liveness: VFS mutations bump the generation (live); out-of-band domain
  writes surface within the cache TTL (§2 liveness classes).
  """

  use Noizu.MCP.VFS

  alias Noizu.MCP.Server.Features.Pagination
  alias NoizuPromptLingua.Domains.Artifacts
  alias NoizuPromptLingua.MCP.Resolve
  alias NoizuPromptLingua.MCP.VFS.{Overview, Scope}
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{Artifact, ArtifactRevision}

  import Ecto.Query, only: [where: 3]

  @group "artifacts"
  @kind_default "document"
  @mime_default "text/plain"
  @fetch_ceiling 500
  @page_size 100

  @exts %{
    "text/markdown" => "md",
    "text/html" => "html",
    "text/plain" => "txt",
    "application/json" => "json",
    "application/yaml" => "yaml",
    "text/yaml" => "yaml",
    "text/css" => "css",
    "application/javascript" => "js",
    "text/javascript" => "js",
    "application/xml" => "xml",
    "text/xml" => "xml"
  }

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

  defp stat_rest(_org, ["overview.md"], _gate, _ctx) do
    {:ok, Scope.file_node(overview_size())}
  end

  defp stat_rest(org, [segment], _gate, ctx) do
    with {:ok, _artifact} <- resolve(org, segment, ctx) do
      {:ok, Scope.dir_node()}
    end
  end

  defp stat_rest(org, [segment, "record.json"], _gate, ctx) do
    with {:ok, artifact} <- resolve(org, segment, ctx) do
      {:ok, Scope.file_node(byte_size(record_json(artifact)))}
    end
  end

  defp stat_rest(org, [segment, "current.txt"], _gate, ctx) do
    with {:ok, artifact} <- resolve(org, segment, ctx),
         {:ok, revision} <- current_revision(artifact) do
      {:ok, Scope.file_node(byte_size(pointer(revision, artifact)))}
    end
  end

  defp stat_rest(org, [segment, "revs"], gate, ctx) do
    with {:ok, _artifact} <- resolve(org, segment, ctx) do
      {:ok, %{Scope.dir_node() | writable: gate.writable}}
    end
  end

  defp stat_rest(org, [segment, "revs", filename], _gate, ctx) do
    with {:ok, artifact} <- resolve(org, segment, ctx),
         {:ok, n} <- parse_rev_name(filename, artifact),
         {:ok, revision} <- fetch_revision(artifact, n) do
      {:ok,
       %{Scope.file_node(byte_size(revision.content || "")) | mtime: ms(revision.inserted_at)}}
    end
  end

  defp stat_rest(_org, _rest, _gate, _ctx), do: {:error, :enoent}

  # ── list/3 ────────────────────────────────────────────────────────────────

  @impl true
  def list(path, cursor, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, gate} <- Scope.gate(ctx, org, @group) do
      list_rest(org, rest, cursor, gate, ctx)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  defp list_rest(org, [], cursor, _gate, ctx) do
    with {:ok, page, next} <- paginate(fetch_all(org, ctx), cursor) do
      entries = [Scope.file_entry("overview.md") | Enum.map(page, &Scope.dir_entry(segment(&1)))]
      {:ok, entries, next}
    end
  end

  defp list_rest(_org, ["overview.md"], _cursor, _gate, _ctx), do: {:error, :enotdir}

  defp list_rest(org, [segment], cursor, _gate, ctx) do
    with {:ok, _artifact} <- resolve(org, segment, ctx) do
      entries = [
        Scope.file_entry("record.json"),
        Scope.file_entry("current.txt"),
        Scope.dir_entry("revs")
      ]

      paginate(entries, cursor)
    end
  end

  defp list_rest(org, [segment, "revs"], cursor, _gate, ctx) do
    with {:ok, artifact} <- resolve(org, segment, ctx) do
      revisions =
        artifact.id
        |> Artifacts.list_revisions(limit: @fetch_ceiling)
        |> Enum.sort_by(& &1.revision_number)

      with {:ok, page, next} <- paginate(revisions, cursor) do
        {:ok, Enum.map(page, &Scope.file_entry(rev_name(&1.revision_number, artifact))), next}
      end
    end
  end

  defp list_rest(_org, _rest, _cursor, _gate, _ctx), do: {:error, :enotdir}

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

  defp read_rest(_org, ["overview.md"], _ctx) do
    {:ok, Overview.md(overview_tool(), @group), Scope.version()}
  end

  defp read_rest(_org, [_segment], _ctx), do: {:error, :eisdir}

  defp read_rest(org, [segment, "record.json"], ctx) do
    with {:ok, artifact} <- resolve(org, segment, ctx) do
      {:ok, record_json(artifact), Scope.version()}
    end
  end

  defp read_rest(org, [segment, "current.txt"], ctx) do
    with {:ok, artifact} <- resolve(org, segment, ctx),
         {:ok, revision} <- current_revision(artifact) do
      {:ok, pointer(revision, artifact), Scope.version()}
    end
  end

  defp read_rest(_org, [_segment, "revs"], _ctx), do: {:error, :eisdir}

  defp read_rest(org, [segment, "revs", filename], ctx) do
    with {:ok, artifact} <- resolve(org, segment, ctx),
         {:ok, n} <- parse_rev_name(filename, artifact),
         {:ok, revision} <- fetch_revision(artifact, n) do
      {:ok, revision.content || "", Scope.version()}
    end
  end

  defp read_rest(_org, _rest, _ctx), do: {:error, :enoent}

  # ── create/3 ──────────────────────────────────────────────────────────────

  @impl true
  def create(path, data, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, gate} <- Scope.gate(ctx, org, @group),
         :ok <- Scope.require_writable(gate) do
      create_rest(org, rest, data, ctx)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  # ArtifactCreate: the path name becomes the title; content seeds revision v1.
  defp create_rest(org, [name], data, ctx) when is_binary(data) do
    cond do
      name == "overview.md" ->
        {:error, :eexist}

      artifact_by_title(org, name, ctx) != nil ->
        {:error, :eexist}

      true ->
        with {:ok, org_id} <- org_id(org) do
          case Artifacts.create(%{
                 organization_id: org_id,
                 kind: @kind_default,
                 title: name,
                 mime_type: @mime_default,
                 content: data
               }) do
            {:ok, artifact} ->
              {:ok, %{Scope.dir_node() | writable: true, xattrs: %{"id" => artifact.id}}}

            {:error, _changeset} ->
              {:error, :eio}
          end
        end
    end
  end

  defp create_rest(_org, [_name], :dir, _ctx), do: {:error, :enosys}

  # AddRevision: create-only, next-number, derived-extension filename.
  defp create_rest(org, [segment, "revs", filename], data, ctx) when is_binary(data) do
    with {:ok, artifact} <- resolve(org, segment, ctx),
         {:ok, n} <- parse_rev_name(filename, artifact),
         :ok <- rev_slot_ok(n, max_revision(artifact.id)) do
      case Artifacts.add_revision(artifact.id, data) do
        {:ok, revision} ->
          {:ok,
           %{
             Scope.file_node(byte_size(data))
             | mtime: ms(revision.inserted_at),
               xattrs: %{"revision_id" => revision.id, "revision_number" => n}
           }}

        {:error, _changeset} ->
          {:error, :eio}
      end
    end
  end

  defp create_rest(_org, [_segment, "revs", _filename], :dir, _ctx), do: {:error, :enosys}
  defp create_rest(_org, _rest, _data, _ctx), do: {:error, :enosys}

  # ── write/3 ───────────────────────────────────────────────────────────────

  @impl true
  def write(path, data, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, gate} <- Scope.gate(ctx, org, @group),
         :ok <- Scope.require_writable(gate) do
      write_rest(org, rest, data, ctx)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  # Immutability: overwriting an existing revision is :eexist (§2.2); missing
  # revision files are create-only territory → :enoent.
  defp write_rest(org, [segment, "revs", filename], _data, ctx) do
    with {:ok, artifact} <- resolve(org, segment, ctx),
         {:ok, n} <- parse_rev_name(filename, artifact) do
      if Artifacts.get_revision(artifact.id, n), do: {:error, :eexist}, else: {:error, :enoent}
    end
  end

  defp write_rest(_org, _rest, _data, _ctx), do: {:error, :enosys}

  # ── remove/2 ──────────────────────────────────────────────────────────────

  # No delete surface exists in the artifact tool catalog — removal is never
  # file-exposed (§3.5).
  @impl true
  def remove(_path, _ctx), do: {:error, :enosys}

  # ── resolution ────────────────────────────────────────────────────────────

  defp overview_tool, do: NoizuPromptLingua.Domains.Artifacts.Tools.Overview
  defp overview_size, do: byte_size(Overview.md(overview_tool(), @group))

  # Org slug (TRP-visible) → organizations-table UUID. Unresolvable ⇒ :enoent
  # (the subtree exists only as far as its data does).
  defp org_id(org) do
    case Resolve.organization_id(org) do
      nil -> {:error, :enoent}
      id -> {:ok, id}
    end
  end

  # Full UUID > {type}-{short8} (§1.1) > exact title match (create-path name).
  defp resolve(org, segment, ctx) do
    with {:ok, org_id} <- org_id(org) do
      artifact =
        cond do
          uuid?(segment) -> artifact_by_uuid(org_id, segment)
          true -> artifact_by_short8(org_id, segment) || artifact_by_title(org, segment, ctx)
        end

      case artifact do
        nil -> {:error, :enoent}
        artifact -> {:ok, artifact}
      end
    end
  end

  defp artifact_by_uuid(org_id, uuid) do
    case Repo.get(Artifact, uuid) do
      %Artifact{} = artifact ->
        if artifact.organization_id == org_id, do: artifact, else: nil

      nil ->
        nil
    end
  end

  defp artifact_by_short8(org_id, segment) do
    with "artifact-" <> short8 <- segment,
         true <- short8 =~ ~r/^[0-9a-f]{8}$/ do
      Artifact
      |> where([a], a.organization_id == ^org_id)
      |> where([a], like(fragment("?::text", a.id), ^"#{short8}%"))
      |> Repo.all()
      |> List.first()
    else
      _ -> nil
    end
  end

  defp artifact_by_title(org, title, ctx) do
    case Enum.find(fetch_all(org, ctx), &(&1.title == title)) do
      nil -> nil
      artifact -> artifact_by_uuid(artifact.organization_id, artifact.id)
    end
  end

  defp uuid?(s), do: s =~ ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

  # ── revisions ─────────────────────────────────────────────────────────────

  defp current_revision(artifact) do
    case Artifacts.get(artifact.id) do
      {_artifact, %ArtifactRevision{} = revision} -> {:ok, revision}
      _ -> {:error, :enoent}
    end
  end

  defp max_revision(artifact_id) do
    case Artifacts.list_revisions(artifact_id, limit: 1) do
      [%{revision_number: n} | _] -> n
      [] -> 0
    end
  end

  defp fetch_revision(artifact, n) do
    case Artifacts.get_revision(artifact.id, n) do
      nil -> {:error, :enoent}
      revision -> {:ok, revision}
    end
  end

  # Only the NEXT revision can be created; existing numbers are immutable.
  defp rev_slot_ok(n, max) when n == max + 1, do: :ok
  defp rev_slot_ok(n, max) when n <= max, do: {:error, :eexist}
  defp rev_slot_ok(_n, _max), do: {:error, :enoent}

  # ── naming & payload helpers ──────────────────────────────────────────────

  defp ext(artifact), do: Map.get(@exts, artifact.mime_type, "txt")

  defp rev_name(n, artifact), do: "v#{n}.#{ext(artifact)}"

  # "v3.md" → {:ok, 3}; ext must match the artifact's derived extension and
  # the number must be a positive integer.
  defp parse_rev_name(filename, artifact) do
    with [_, n, e] <- Regex.run(~r/^v(\d+)\.([a-z0-9]+)$/, filename),
         ^e <- ext(artifact),
         {n, ""} <- Integer.parse(n),
         true <- n >= 1 do
      {:ok, n}
    else
      _ -> {:error, :enoent}
    end
  end

  defp segment(artifact), do: "artifact-" <> String.slice(artifact.id, 0, 8)

  defp pointer(revision, artifact), do: rev_name(revision.revision_number, artifact)

  defp record_json(artifact) do
    revisions = Artifacts.list_revisions(artifact.id, limit: @fetch_ceiling)

    current =
      case current_revision(artifact) do
        {:ok, revision} -> revision
        _ -> nil
      end

    %{
      "id" => artifact.id,
      "kind" => artifact.kind,
      "title" => artifact.title,
      "mime_type" => artifact.mime_type,
      "organization_id" => artifact.organization_id,
      "project_id" => artifact.project_id,
      "path_segment" => segment(artifact),
      "created_at" => iso(artifact.inserted_at),
      "updated_at" => iso(artifact.updated_at),
      "revision_count" => length(revisions),
      "current_revision" =>
        current &&
          %{
            "number" => current.revision_number,
            "note" => current.note,
            "created_at" => iso(current.inserted_at),
            "size" => byte_size(current.content || "")
          }
    }
    |> Jason.encode!()
  end

  defp fetch_all(org, _ctx) do
    with {:ok, org_id} <- org_id(org) do
      Artifacts.list(organization_id: org_id, limit: @fetch_ceiling)
    else
      _ -> []
    end
  end

  defp paginate(items, cursor) do
    cursor = if cursor == "", do: nil, else: cursor

    case Pagination.paginate(items, cursor, @page_size) do
      {:ok, page, next} -> {:ok, page, next}
      {:error, _} -> {:error, Noizu.MCP.Error.invalid_params("invalid cursor")}
    end
  end

  defp iso(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp iso(dt), do: to_string(dt)

  defp ms(%DateTime{} = dt), do: DateTime.to_unix(dt, :millisecond)
  defp ms(_), do: Scope.now_ms()
end
