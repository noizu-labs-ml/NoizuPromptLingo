defmodule NoizuPromptLingua.MCP.VFS.Instructions do
  @moduledoc """
  VFS backend for the `instructions` group (MCP-VFS-GROUP-MOUNTS.md §2.3) —
  natural-file + version pointer, wired to the `NoizuPromptLingua.Domains.Instructions`
  context. Full absolute paths, self-enforced §1.3 gates (via
  `NoizuPromptLingua.MCP.VFS.Scope`), independently conformance-testable.

      /tobor/{org}/instructions                        → InstructionList (readdir)
      /tobor/{org}/instructions/overview.md            → Overview tool render
      /tobor/{org}/instructions/{slug}/record.json     → canonical doc (metadata)
      /tobor/{org}/instructions/{slug}/active          → pointer file: "v{n}"
      /tobor/{org}/instructions/{slug}/versions/v{n}.md → version bodies (immutable)

  ## Decisions & conventions

    * **Path segments are the org-scoped `slug`** — stable keys only (§1.1);
      display titles live in `record.json`.
    * **Version bodies are immutable** (§2.3): `create` on
      `versions/v{n}.md` maps `InstructionUpdate` — only `n == active + 1` is
      accepted (and it becomes active), existing numbers collide with
      `:eexist`, anything beyond next is `:enoent`. `write` on an existing
      version is `:eexist` (overwrite ⇒ collision, no CAS primitive).
    * **`active` is the writable pointer file**: one line `v{n}` (the
      `InstructionSetActiveVersion` mapping — §6 R1 pointer convention, the
      artifacts `current.txt` mirror). Writing a pointer to a version that
      does not exist is `:enoent`; malformed pointer content is `:eio`.
    * **`record.json` is read-only** — `InstructionUpdate` only carries a body
      through the file plane; metadata edits stay on the MCP surface.
    * **Delete**: `remove` of the instruction dir maps the existing
      `InstructionDelete` tool (which cascades its versions by design). The
      design table's `ENOTEMPTY` guard is unreachable here because version
      files are immutable/not removable — noted as a deliberate deviation
      toward tool-faithful semantics; `rm -r` on a mount deletes the
      instruction, exactly like the tool does.
    * **InstructionRender** stays a control/query action (design §2.3): it is
      invoked through the MCP surface / `/etc/dev` control writes, not the
      file plane — documented here, not implemented in this wave.
    * **Pagination** — lib `Features.Pagination` opaque offset cursors over an
      org-bounded fetch (ceiling 500).

  Liveness: VFS mutations are live; MCP-surface edits surface within the TTL.
  """

  use Noizu.MCP.VFS

  alias Noizu.MCP.Server.Features.Pagination
  alias NoizuPromptLingua.Domains.Instructions
  alias NoizuPromptLingua.MCP.Resolve
  alias NoizuPromptLingua.MCP.VFS.{Overview, Scope}

  @group "instructions"
  @fetch_ceiling 500
  @page_size 100

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
    {:ok, Scope.file_node(byte_size(Overview.md(overview_tool(), @group)))}
  end

  defp stat_rest(org, [slug], gate, ctx) do
    with {:ok, _instruction} <- resolve(org, slug, ctx) do
      {:ok, %{Scope.dir_node() | writable: gate.writable}}
    end
  end

  defp stat_rest(org, [slug, "record.json"], _gate, ctx) do
    with {:ok, instruction} <- resolve(org, slug, ctx) do
      {:ok, Scope.file_node(byte_size(record_json(instruction)))}
    end
  end

  defp stat_rest(org, [slug, "active"], gate, ctx) do
    with {:ok, instruction} <- resolve(org, slug, ctx) do
      {:ok, %{Scope.file_node(pointer_size(instruction)) | writable: gate.writable}}
    end
  end

  defp stat_rest(org, [slug, "versions"], gate, ctx) do
    with {:ok, _instruction} <- resolve(org, slug, ctx) do
      {:ok, %{Scope.dir_node() | writable: gate.writable}}
    end
  end

  defp stat_rest(org, [slug, "versions", filename], _gate, ctx) do
    with {:ok, instruction} <- resolve(org, slug, ctx),
         {:ok, n} <- parse_version_name(filename),
         {:ok, version} <- fetch_version(instruction, n) do
      {:ok, %{Scope.file_node(byte_size(version.body || "")) | mtime: ms(version.updated_at)}}
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

  defp list_rest(org, [], cursor, ctx) do
    with {:ok, page, next} <- paginate(fetch_all(org, ctx), cursor) do
      entries = [Scope.file_entry("overview.md") | Enum.map(page, &Scope.dir_entry(&1.slug))]
      {:ok, entries, next}
    end
  end

  defp list_rest(_org, ["overview.md"], _cursor, _ctx), do: {:error, :enotdir}

  defp list_rest(org, [slug], cursor, ctx) do
    with {:ok, _instruction} <- resolve(org, slug, ctx) do
      paginate(
        [
          Scope.file_entry("record.json"),
          Scope.file_entry("active"),
          Scope.dir_entry("versions")
        ],
        cursor
      )
    end
  end

  defp list_rest(org, [slug, "versions"], cursor, ctx) do
    with {:ok, instruction} <- resolve(org, slug, ctx) do
      versions =
        instruction.id
        |> Instructions.list_versions()
        |> Enum.sort_by(& &1.version)

      entries = Enum.map(versions, &Scope.file_entry("v#{&1.version}.md"))
      paginate(entries, cursor)
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

  defp read_rest(_org, ["overview.md"], _ctx) do
    {:ok, Overview.md(overview_tool(), @group), Scope.version()}
  end

  defp read_rest(_org, [_slug], _ctx), do: {:error, :eisdir}

  defp read_rest(org, [slug, "record.json"], ctx) do
    with {:ok, instruction} <- resolve(org, slug, ctx) do
      {:ok, record_json(instruction), Scope.version()}
    end
  end

  # InstructionGet: the active version's body is ALSO the instruction's read —
  # through the pointer, as the design's natural-file semantics suggest.
  defp read_rest(org, [slug, "active"], ctx) do
    with {:ok, instruction} <- resolve(org, slug, ctx) do
      {:ok, pointer(instruction.active_version), Scope.version()}
    end
  end

  defp read_rest(_org, [_slug, "versions"], _ctx), do: {:error, :eisdir}

  defp read_rest(org, [slug, "versions", filename], ctx) do
    with {:ok, instruction} <- resolve(org, slug, ctx),
         {:ok, n} <- parse_version_name(filename),
         {:ok, version} <- fetch_version(instruction, n) do
      {:ok, version.body || "", Scope.version()}
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

  # InstructionCreate: slug from the path, body from the content, active = v1.
  defp create_rest(org, [slug], data, ctx) when is_binary(data) do
    cond do
      slug == "overview.md" ->
        {:error, :eexist}

      resolve!(org, slug, ctx) != nil ->
        {:error, :eexist}

      true ->
        create_instruction(org, slug, data)
    end
  end

  defp create_rest(_org, [_slug], :dir, _ctx), do: {:error, :enosys}

  # InstructionUpdate: only the next version (active + 1); it becomes active.
  defp create_rest(org, [slug, "versions", filename], data, ctx) when is_binary(data) do
    with {:ok, instruction} <- resolve(org, slug, ctx),
         {:ok, n} <- parse_version_name(filename),
         :ok <- version_slot_ok(n, instruction) do
      case Instructions.update(instruction.id, %{}, body: data) do
        {:ok, _updated} ->
          {:ok, %{Scope.file_node(byte_size(data)) | xattrs: %{"version" => n, "active" => true}}}

        {:error, _changeset} ->
          {:error, :eio}
      end
    end
  end

  defp create_rest(_org, [_slug, "versions", _filename], :dir, _ctx), do: {:error, :enosys}
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

  # InstructionSetActiveVersion: write the `active` pointer ("v2", optional
  # surrounding whitespace/newline) at an existing version.
  defp write_rest(org, [slug, "active"], data, ctx) when is_binary(data) do
    with {:ok, instruction} <- resolve(org, slug, ctx),
         {:ok, n} <- parse_pointer(data),
         {:ok, _version} <- fetch_version(instruction, n) do
      case Instructions.set_active_version(instruction.id, n) do
        {:ok, _updated} -> {:ok, Scope.file_node(byte_size(pointer(n)))}
        {:error, _} -> {:error, :eio}
      end
    end
  end

  defp write_rest(org, [slug, "versions", filename], _data, ctx) do
    with {:ok, instruction} <- resolve(org, slug, ctx),
         {:ok, n} <- parse_version_name(filename) do
      if version_exists?(instruction.id, n), do: {:error, :eexist}, else: {:error, :enoent}
    end
  end

  defp write_rest(_org, _rest, _data, _ctx), do: {:error, :enosys}

  # ── remove/2 ──────────────────────────────────────────────────────────────

  # InstructionDelete (cascades versions — tool-faithful; see moduledoc).
  # Deeper removals (version files, record.json, active) are unmapped.
  @impl true
  def remove(path, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, gate} <- Scope.gate(ctx, org, @group),
         :ok <- Scope.require_writable(gate) do
      remove_rest(org, rest, ctx)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  defp remove_rest(org, [slug], ctx) do
    with {:ok, instruction} <- resolve(org, slug, ctx) do
      case Instructions.delete(instruction.id) do
        {:ok, _} -> :ok
        {:error, _} -> {:error, :eio}
      end
    end
  end

  defp remove_rest(org, [slug, "versions", "v" <> _], ctx) do
    case resolve(org, slug, ctx) do
      {:ok, _} -> {:error, :enosys}
      error -> error
    end
  end

  defp remove_rest(_org, _rest, _ctx), do: {:error, :enosys}

  # ── resolution ────────────────────────────────────────────────────────────

  defp overview_tool, do: NoizuPromptLingua.Domains.Instructions.Tools.Overview

  defp org_id(org) do
    case Resolve.organization_id(org) do
      nil -> {:error, :enoent}
      id -> {:ok, id}
    end
  end

  defp resolve(org, slug, _ctx) do
    with {:ok, org_id} <- org_id(org) do
      case Instructions.resolve(org_id, slug) do
        nil -> {:error, :enoent}
        instruction -> {:ok, instruction}
      end
    end
  end

  # Gate-free existence probe used by create's collision check.
  defp resolve!(org, slug, ctx) do
    case resolve(org, slug, ctx) do
      {:ok, instruction} -> instruction
      _ -> nil
    end
  end

  # ── versions ──────────────────────────────────────────────────────────────

  defp fetch_version(instruction, n) do
    case Instructions.get_version(instruction.id, n) do
      nil -> {:error, :enoent}
      version -> {:ok, version}
    end
  end

  defp version_exists?(instruction_id, n), do: Instructions.get_version(instruction_id, n) != nil

  # Mirrors InstructionUpdate: the new version is active_version + 1; existing
  # version numbers are immutable (:eexist) even when the pointer sits lower.
  defp version_slot_ok(n, instruction) do
    cond do
      version_exists?(instruction.id, n) -> {:error, :eexist}
      n == instruction.active_version + 1 -> :ok
      true -> {:error, :enoent}
    end
  end

  # "v2.md" → {:ok, 2}; bodies are always markdown-named per §2.3.
  defp parse_version_name(filename) do
    with [_, n] <- Regex.run(~r/^v(\d+)\.md$/, filename),
         {n, ""} <- Integer.parse(n),
         true <- n >= 1 do
      {:ok, n}
    else
      _ -> {:error, :enoent}
    end
  end

  # Pointer content: "v2" (the `versions/` readdir names minus .md).
  defp parse_pointer(data) do
    case String.trim(data) do
      "v" <> n ->
        with {n, ""} <- Integer.parse(n),
             true <- n >= 1 do
          {:ok, n}
        else
          _ -> {:error, :eio}
        end

      _ ->
        {:error, :eio}
    end
  end

  defp pointer(n), do: "v#{n}"

  defp pointer_size(instruction), do: byte_size(pointer(instruction.active_version))

  # ── payload helpers ───────────────────────────────────────────────────────

  defp create_instruction(org, slug, data) do
    with {:ok, org_id} <- org_id(org) do
      case Instructions.create(%{organization_id: org_id, slug: slug, title: slug}, body: data) do
        {:ok, instruction} ->
          {:ok, %{Scope.dir_node() | writable: true, xattrs: %{"id" => instruction.id}}}

        {:error, _changeset} ->
          {:error, :eio}
      end
    end
  end

  defp record_json(instruction) do
    %{
      "id" => instruction.id,
      "slug" => instruction.slug,
      "title" => instruction.title,
      "description" => instruction.description,
      "tags" => instruction.tags,
      "parameters" => instruction.parameters,
      "status" => instruction.status,
      "organization_id" => instruction.organization_id,
      "project_id" => instruction.project_id,
      "active_version" => instruction.active_version,
      "version_count" => length(Instructions.list_versions(instruction.id)),
      "created_at" => iso(instruction.inserted_at),
      "updated_at" => iso(instruction.updated_at)
    }
    |> Jason.encode!()
  end

  defp fetch_all(org, _ctx) do
    with {:ok, org_id} <- org_id(org) do
      Instructions.list(organization_id: org_id, limit: @fetch_ceiling)
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
