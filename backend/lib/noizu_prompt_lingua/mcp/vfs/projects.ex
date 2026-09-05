defmodule NoizuPromptLingua.MCP.VFS.Projects do
  @moduledoc """
  `MCP.Projects` entity-dir (MCP-VFS-GROUP-MOUNTS.md §2.6) — TRP shared-key
  backed through `NoizuPromptLingua.Projects`/`NoizuPromptLingua.TRP`.

  Owns the `/tobor/{org}/projects` subtree (Root dispatches mapped groups
  wholly — dir node, overview, and deeper):

      /tobor/{org}/projects                     readdir = Project.List
      /tobor/{org}/projects/overview.md         group overview
      /tobor/{org}/projects/{slug}              project dir (slug = stable key)
      /tobor/{org}/projects/{slug}/record.json  read = Project.Get
                                                write = Project.Update (canonical merge)
                                                create = Project.Create

  Read-write for every principal the group gate admits (§2.6 — no per-role
  narrowing on this group). Per §3.4, `record.json` is the only canonical
  write target: writes merge accepted fields (`name`, `description`,
  `status`) and ignore unknown keys; `slug` in a written doc is ignored —
  the path segment IS the slug and renames are not file-exposed.

  TRP error semantics (this backend's base): `list_organizations` /
  `list_projects` failures render an EMPTY listing (mirrors the
  `Principal` org-inventory precedent — a failed shared-key read never
  fabricates nodes), while a write whose TRP call fails is `:eio` — the
  mutation did not land, and the caller retries rather than mistaking it
  for a permission problem.
  """

  use Noizu.MCP.VFS

  alias Noizu.MCP.VFS
  alias NoizuPromptLingua.MCP.VFS.Principal
  alias NoizuPromptLingua.TRP

  @orgs_root "tobor"
  @group_id "projects"
  @group_dir "projects"
  @record "record.json"

  @write_fields ["name", "description", "status"]

  # ── stat/2 ────────────────────────────────────────────────────────────────

  @impl true
  def stat(path, ctx) do
    with {:ok, segments} <- split_segments(path) do
      stat_segments(segments, ctx)
    end
  end

  defp stat_segments([@orgs_root, org, @group_dir], ctx) do
    require_group(ctx, org, fn -> {:ok, dir_node()} |> tap_writable(ctx) end)
  end

  defp stat_segments([@orgs_root, org, @group_dir, "overview.md"], ctx) do
    require_group(ctx, org, fn ->
      {:ok, %{file_node(byte_size(overview_md())) | writable: gate_writable?(ctx)}}
    end)
  end

  defp stat_segments([@orgs_root, org, @group_dir, slug], ctx) do
    require_group(ctx, org, fn ->
      with {:ok, org_id} <- trp_org_id(org),
           {:ok, project} <- fetch_project(org_id, slug) do
        {:ok, dir_node()}
        |> tap_writable(ctx)
        |> then(&put_record_xattrs(&1, project))
      end
    end)
  end

  defp stat_segments([@orgs_root, org, @group_dir, slug, @record], ctx) do
    require_group(ctx, org, fn ->
      with {:ok, org_id} <- trp_org_id(org),
           {:ok, project} <- fetch_project(org_id, slug) do
        {:ok, file_node(doc_size(project))}
        |> tap_writable(ctx)
        |> put_record_xattrs(project)
      end
    end)
  end

  defp stat_segments(_, _), do: {:error, :enoent}

  # ── list/3 ────────────────────────────────────────────────────────────────

  @impl true
  def list(path, cursor, ctx) do
    with {:ok, segments} <- split_segments(path),
         {:ok, entries} <- list_segments(segments, ctx) do
      case cursor do
        c when c in [nil, ""] -> {:ok, entries, nil}
        _ -> {:error, Noizu.MCP.Error.invalid_params("invalid cursor")}
      end
    end
  end

  defp list_segments([@orgs_root, org, @group_dir], ctx) do
    require_group(ctx, org, fn ->
      slugs =
        with {:ok, org_id} <- trp_org_id(org),
             rows when is_list(rows) <- TRP.list_projects(org_id) do
          rows |> Enum.map(& &1.slug) |> Enum.sort() |> Enum.uniq()
        else
          _ -> []
        end

      {:ok, Enum.map(slugs, &dir_entry/1)}
    end)
  end

  defp list_segments([@orgs_root, org, @group_dir, slug], ctx) do
    require_group(ctx, org, fn ->
      with {:ok, org_id} <- trp_org_id(org),
           {:ok, _project} <- fetch_project(org_id, slug) do
        {:ok, [file_entry(@record)]}
      end
    end)
  end

  defp list_segments([@orgs_root, _org, @group_dir, _slug, @record], _ctx),
    do: {:error, :enotdir}

  defp list_segments([@orgs_root, _org, @group_dir, "overview.md"], _ctx), do: {:error, :enotdir}

  defp list_segments(_, _), do: {:error, :enoent}

  # ── read/2 ────────────────────────────────────────────────────────────────

  @impl true
  def read(path, ctx) do
    with {:ok, segments} <- split_segments(path) do
      read_segments(segments, ctx)
    end
  end

  defp read_segments([@orgs_root, org, @group_dir, "overview.md"], ctx) do
    require_group(ctx, org, fn -> {:ok, overview_md(), version()} end)
  end

  defp read_segments([@orgs_root, org, @group_dir, slug, @record], ctx) do
    require_group(ctx, org, fn ->
      with {:ok, org_id} <- trp_org_id(org),
           {:ok, project} <- fetch_project(org_id, slug) do
        {:ok, Jason.encode!(project_doc(project)), version()}
      end
    end)
  end

  defp read_segments([@orgs_root, _org, @group_dir], _ctx), do: {:error, :eisdir}
  defp read_segments(_, _), do: {:error, :enoent}

  # ── write/3 — Project.Update (canonical doc merge, §3.4) ──────────────────

  @impl true
  def write(path, content, ctx) do
    with {:ok, segments} <- split_segments(path),
         [@orgs_root, org, @group_dir, slug, @record] <- segments,
         :ok <- require_writable(ctx, org),
         {:ok, org_id} <- trp_org_id(org),
         {:ok, project} <- fetch_project(org_id, slug),
         {:ok, doc} <- decode(content) do
      # The slug path segment is the stable key; slug writes are ignored.
      attrs = Map.new(@write_fields, fn key -> {key, valid_string(doc[key])} end)
      attrs = Map.reject(attrs, fn {_k, v} -> is_nil(v) end)

      case NoizuPromptLingua.Projects.update_project(project.id, attrs) do
        {:ok, updated} -> {:ok, file_node(doc_size(updated))}
        {:error, :not_found} -> {:error, :enoent}
        {:error, _} -> {:error, :eio}
      end
    else
      {:error, _} = err -> err
      _ -> {:error, :enoent}
    end
  end

  # ── create/3 — Project.Create ─────────────────────────────────────────────

  @impl true
  def create(_path, :dir, _ctx), do: {:error, :enosys}

  def create(path, content, ctx) do
    with {:ok, segments} <- split_segments(path),
         [@orgs_root, org, @group_dir, slug, @record] <- segments,
         :ok <- require_writable(ctx, org),
         {:ok, org_id} <- trp_org_id(org),
         :ok <- assert_slug_free(org_id, slug),
         {:ok, doc} <- decode(content) do
      attrs =
        %{
          organization_id: org_id,
          slug: slug,
          name: valid_string(doc["name"]) || slug,
          description: valid_string(doc["description"])
        }

      case NoizuPromptLingua.Projects.create_with_owner(attrs, nil) do
        {:ok, project} ->
          xattrs = %{
            "id" => project.id,
            "canonical_path" => "/#{@orgs_root}/#{org}/#{@group_dir}/#{project.slug}/#{@record}"
          }

          {:ok, %VFS{file_node(doc_size(project)) | xattrs: xattrs}}

        {:error, _} ->
          {:error, :eio}
      end
    else
      {:error, _} = err -> err
      _ -> {:error, :enoent}
    end
  end

  # ── payload ───────────────────────────────────────────────────────────────

  defp project_doc(project) do
    %{
      "id" => project.id,
      "organization_id" => project.organization_id,
      "name" => project.name,
      "slug" => project.slug,
      "description" => project.description,
      "status" => project.status,
      "key_prefix" => Map.get(project, :key_prefix),
      "created_at" => iso(project.inserted_at),
      "updated_at" => iso(project.updated_at)
    }
  end

  defp doc_size(project), do: byte_size(Jason.encode!(project_doc(project)))

  # ── gates ─────────────────────────────────────────────────────────────────

  defp require_group(ctx, org, fun) do
    if Principal.org_visible?(ctx, org) and match?(:ok, Principal.group_gate(ctx, @group_id)) do
      fun.()
    else
      {:error, :enoent}
    end
  end

  defp require_writable(ctx, org) do
    cond do
      not (Principal.org_visible?(ctx, org) and match?(:ok, Principal.group_gate(ctx, @group_id))) ->
        {:error, :enoent}

      not gate_writable?(ctx) ->
        {:error, :eacces}

      true ->
        :ok
    end
  end

  defp gate_writable?(ctx) do
    case Principal.groups(ctx)[@group_id] do
      %{writable: true} -> true
      _ -> false
    end
  end

  defp tap_writable({:ok, node}, ctx), do: {:ok, %{node | writable: gate_writable?(ctx)}}

  defp put_record_xattrs({:ok, node}, project),
    do: {:ok, %{node | xattrs: Map.put(node.xattrs, "id", project.id)}}

  defp put_record_xattrs(err, _project), do: err

  # TRP org inventory is the key scope (mirrors Principal.org_slugs/0); the
  # slug→id fold goes through the shared-key list so TRP-side ids are used.
  defp trp_org_id(org) do
    case TRP.find_organization_by_slug(org) do
      %{id: id} -> {:ok, id}
      _ -> {:error, :enoent}
    end
  end

  defp fetch_project(org_id, slug) do
    case NoizuPromptLingua.Projects.get_project_by_slug(org_id, slug) do
      nil -> {:error, :enoent}
      project -> {:ok, project}
    end
  end

  defp assert_slug_free(org_id, slug) do
    if NoizuPromptLingua.Projects.get_project_by_slug(org_id, slug) != nil,
      do: {:error, :eexist},
      else: :ok
  end

  # ── shared shape helpers ──────────────────────────────────────────────────

  defp decode(content) when is_binary(content) do
    case Jason.decode(content) do
      {:ok, doc} when is_map(doc) -> {:ok, doc}
      _ -> {:error, :eio}
    end
  end

  defp decode(_), do: {:error, :eio}

  defp valid_string(v) when is_binary(v) and v != "", do: v
  defp valid_string(_), do: nil

  defp iso(nil), do: nil
  defp iso(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp iso(other), do: to_string(other)

  defp overview_md do
    """
    # Projects (projects)

    TRP-backed project entity-dir (`MCP-VFS-GROUP-MOUNTS.md` §2.6). One dir per
    project, keyed by slug; `record.json` is the canonical document — read it,
    write it, create new projects at `{slug}/record.json`.
    """
  end

  # ── node builders (Root.ex conventions) ───────────────────────────────────

  defp dir_node, do: %VFS{type: :dir, mtime: now_ms(), version: version()}
  defp file_node(size), do: %VFS{type: :file, size: size, mtime: now_ms(), version: version()}

  defp dir_entry(name),
    do: %{name: name, type: :dir, size: 0, mtime: now_ms(), version: version()}

  defp file_entry(name),
    do: %{name: name, type: :file, size: 0, mtime: now_ms(), version: version()}

  defp version, do: 1
  defp now_ms, do: System.os_time(:millisecond)

  defp split_segments(path) do
    segments =
      path
      |> String.trim_trailing("/")
      |> String.split("/", trim: true)

    if Enum.any?(segments, &(&1 in [".", ".."])),
      do: {:error, :enoent},
      else: {:ok, segments}
  end
end
