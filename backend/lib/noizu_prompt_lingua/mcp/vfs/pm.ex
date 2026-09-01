defmodule NoizuPromptLingua.MCP.VFS.PM do
  @moduledoc """
  Project-management VFS backend over the shared pm_core data layer
  (`Noizu.PM.*` on `Noizu.PM.Repo`), implementing `Noizu.MCP.VFS`.

  ## Layout

      /pm/                                  → organizations
      /pm/<org-slug>/                       → projects + index.yaml
      /pm/<org>/<project>/                  → fixed subdirs + rollups + index.yaml
        personas/<slug>.md                  → Noizu.PM.Schema.Personas.Persona
        tickets/<KEY>-<slug>.md             → Noizu.PM.Schema.Items.Item (real human key)
        artifacts/A-<uuid>-<slug>.md        → Noizu.PM.Schema.Artifacts.Artifact (+ revisions)
        wiki/<space-slug>/<page-slug>.md    → Noizu.PM.Schema.Wiki.Page (project-scoped spaces)
        index.yaml, personas.md, tickets.md, artifacts.md (control, read-only)

  Entity ids are the IDs pm_core actually supports: items use their immutable
  human key (`PREFIX-NNN`), personas/wiki use org-unique slugs, artifacts carry
  their UUID in the filename (cosmetic slug after it). `index.yaml` and the
  `*.md` rollups are GENERATED on read — writes to them return `:erofs`.

  Reads are unauthenticated (transport-level authz applies). Mutations require
  an authenticated caller (`ctx.assigns[:auth_claims]`) with at least `member`
  role in the organization (`Noizu.PM.Authz`); the authorize step is injectable
  via `:mcp_vfs_pm` config key `:authorize` (MFA `{mod, fun, [extra]}` called as
  `mod.fun(user_id, org_id)` or a 2-arity fun) for hosts that need another seam.

  `remove` archives by default (status flip, never a hard delete). Configure
  `:mcp_vfs_pm` → `hard_delete: true` for true deletes (artifacts delete their
  revisions). Artifact writes are append-only: each write appends a new
  `ArtifactRevision` via `Noizu.PM.Artifacts.add_revision/3`.

  Search is pragmatic ILIKE-style scanning over the markdown-rendered content
  of the subtree; DB full-text (pgvector/tsvector) is a future upgrade.
  """
  use Noizu.MCP.VFS

  alias Noizu.MCP.Error
  alias Noizu.MCP.VFS
  alias Noizu.PM.{Artifacts, Authz, Items, Organizations, Personas, Repo, Wiki}
  alias Noizu.PM.Schema.Artifacts.{Artifact, ArtifactRevision}
  alias Noizu.PM.Schema.Items.Item
  alias Noizu.PM.Schema.Projects.Project
  alias Noizu.PM.Schema.Wiki.Page
  alias NoizuPromptLingua.MCP.Resolve

  @page_size 50
  @entity_cap 500
  @type_dirs ~w(personas tickets artifacts wiki)
  @rollups ~w(personas.md tickets.md artifacts.md)

  # ══════════════════════════════════ stat ══════════════════════════════════

  @impl true
  def stat(path, _ctx) do
    case resolve(path) do
      {:ok, view} -> node_for(view)
      {:error, _} = err -> err
    end
  end

  # ══════════════════════════════════ list ══════════════════════════════════

  @impl true
  def list(path, cursor, _ctx) do
    with {:ok, offset} <- decode_cursor(cursor),
         {:ok, view} <- resolve(path),
         {:ok, entries} <- children(view) do
      page = Enum.slice(entries, offset, @page_size)
      next = if offset + @page_size < length(entries), do: encode_cursor(offset + @page_size), else: nil
      {:ok, page, next}
    else
      {:error, _} = err -> err
    end
  end

  # ══════════════════════════════════ read ══════════════════════════════════

  @impl true
  def read(path, _ctx) do
    case resolve(path) do
      {:ok, {:root}} -> {:error, :eisdir}
      {:ok, view} ->
        case content_for(view) do
          {:ok, content, version} -> {:ok, content, version}
          {:error, _} = err -> err
        end

      {:error, _} = err ->
        err
    end
  end

  # ══════════════════════════════════ write ═════════════════════════════════

  @impl true
  def write(path, data, ctx) when is_binary(data) do
    with {:ok, view} <- resolve(path),
         {:ok, kind, record, extra} <- writable_file(view),
         {:ok, user} <- require_user(ctx),
         :ok <- authorize(user, extra.org_id),
         {:ok, fm, body} <- parse_doc(data) do
      commit_write(kind, record, fm, body)
    else
      {:error, _} = err -> err
    end
  end

  defp commit_write(:persona, persona, fm, body) do
    attrs = %{
      name: fm_name(fm) || persona.name,
      role: fm["role"] || persona.role,
      bio: body || persona.bio,
      status: fm["status"] || persona.status,
      tags: fm_tags(fm) || persona.tags
    }

    with {:ok, updated} <- Personas.update(persona.id, attrs) do
      {:ok, file_node({:persona, updated})}
    end
  end

  defp commit_write(:ticket, item, fm, body) do
    attrs =
      %{
        title: fm["title"] || fm_name(fm) || item.title,
        status: fm["status"] || item.status,
        priority: fm["priority"] || item.priority,
        assignee: fm["assignee"] || item.assignee,
        description: body || item.description,
        tags: fm_tags(fm) || item.tags
      }
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Map.new()

    with {:ok, updated} <- Items.update(item.id, attrs) do
      {:ok, file_node({:ticket, updated})}
    end
  end

  # Artifacts are append-only: a write appends a revision; metadata edits are
  # ignored (the `note` frontmatter key, when present, labels the revision).
  defp commit_write(:artifact, artifact, fm, body) do
    with {:ok, _rev} <- Artifacts.add_revision(artifact.id, body, fm["note"]) do
      {artifact, _rev} = Artifacts.get(artifact.id)
      {:ok, file_node({:artifact, artifact})}
    end
  end

  defp commit_write(:wiki_page, page, fm, body) do
    attrs = %{title: fm["title"] || fm_name(fm) || page.title, content: body || page.content}

    with {:ok, updated} <- Wiki.update_page(page.id, attrs) do
      {:ok, file_node({:wiki_page, updated})}
    end
  end

  # ═════════════════════════════════ create ═════════════════════════════════

  @impl true
  def create(_path, :dir, _ctx), do: {:error, :enosys}

  def create(path, data, ctx) when is_binary(data) do
    with {:ok, segs} <- normalize(path),
         {:ok, scope} <- resolve_create_scope(segs),
         {:ok, user} <- require_user(ctx),
         :ok <- authorize(user, scope.org_id),
         :ok <- ensure_absent(path) do
      commit_create(scope, data)
    else
      {:error, _} = err -> err
    end
  end

  defp resolve_create_scope(segs) do
    case segs do
      # generated control files (index.yaml / rollups) are read-only
      [_o, "index.yaml"] ->
        {:error, :erofs}

      [_o, _p, f] when f == "index.yaml" or f in @rollups ->
        {:error, :erofs}

      [_o, _p, t, "index.yaml"] when t in @type_dirs ->
        {:error, :erofs}

      [_o, _p, "wiki", _space, "index.yaml"] ->
        {:error, :erofs}

      [o, p, t, f] when t in @type_dirs ->
        with {:ok, org} <- fetch_org(o),
             {:ok, project} <- fetch_project(org, p) do
          {:ok, %{type: dir_type(t), org: org, org_id: org.id, project: project, name: f}}
        end

      [o, p, "wiki", space, f] ->
        with {:ok, org} <- fetch_org(o),
             {:ok, project} <- fetch_project(org, p),
             {:ok, sp} <- fetch_space(org, project, space) do
          {:ok, %{type: :wiki_page, org: org, org_id: org.id, project: project, space: sp, name: f}}
        end

      _ ->
        {:error, :enoent}
    end
  end

  defp ensure_absent(path) do
    case resolve(path) do
      {:error, :enoent} -> :ok
      {:ok, _} -> {:error, :eexist}
    end
  end

  defp commit_create(%{type: :persona} = scope, data) do
    with {:ok, fm, body} <- parse_doc(data),
         {:ok, created} <-
           Personas.create(%{
             organization_id: scope.org_id,
             project_id: scope.project.id,
             slug: base_name(scope.name),
             name: fm_name(fm) || titleize(base_name(scope.name)),
             role: fm["role"],
             bio: body,
             status: fm["status"] || "active",
             tags: fm_tags(fm) || []
           }) do
      {:ok, file_node({:persona, created})}
    end
  end

  defp commit_create(%{type: :ticket} = scope, data) do
    with {:ok, fm, body} <- parse_doc(data) do
      attrs =
        %{
          organization_id: scope.org_id,
          project_id: scope.project.id,
          title: fm["title"] || fm_name(fm) || titleize(base_name(scope.name)),
          item_type: fm["item_type"] || "task",
          status: fm["status"] || "open",
          priority: fm["priority"],
          assignee: fm["assignee"],
          description: body,
          tags: fm_tags(fm) || []
        }
        |> Enum.reject(fn {_k, v} -> is_nil(v) end)
        |> Map.new()

      with {:ok, created} <- Items.create(attrs) do
        {:ok, file_node({:ticket, created})}
      end
    end
  end

  defp commit_create(%{type: :artifact} = scope, data) do
    with {:ok, fm, body} <- parse_doc(data),
         {:ok, created} <-
           Artifacts.create(%{
             organization_id: scope.org_id,
             project_id: scope.project.id,
             kind: fm["kind"] || "document",
             title: fm["title"] || fm_name(fm) || titleize(base_name(scope.name)),
             mime_type: fm["mime_type"] || "text/markdown",
             content: body || ""
           }) do
      {:ok, file_node({:artifact, created})}
    end
  end

  defp commit_create(%{type: :wiki_page} = scope, data) do
    with {:ok, fm, body} <- parse_doc(data),
         {:ok, created} <-
           Wiki.create_page(%{
             space_id: scope.space.id,
             slug: base_name(scope.name),
             title: fm["title"] || fm_name(fm) || titleize(base_name(scope.name)),
             content: body || "",
             position: fm["position"] || 0
           }) do
      {:ok, file_node({:wiki_page, created})}
    end
  end

  # ═════════════════════════════════ remove ═════════════════════════════════

  # Default is a soft remove (archive). `:mcp_vfs_pm` → `hard_delete: true`
  # opts into real deletes.
  @impl true
  def remove(path, ctx) do
    with {:ok, view} <- resolve(path),
         {:ok, kind, record, extra} <- writable_file(view),
         {:ok, user} <- require_user(ctx),
         :ok <- authorize(user, extra.org_id) do
      result =
        if hard_delete?() do
          hard_remove(kind, record)
        else
          archive(kind, record)
        end

      case result do
        :ok -> :ok
        {:ok, _} -> :ok
        {:error, _} = err -> err
      end
    else
      {:error, _} = err -> err
    end
  end

  defp archive(:persona, persona), do: Personas.archive(persona.id)
  defp archive(:ticket, item), do: Items.update(item.id, %{status: "archived"})

  defp archive(_kind, _record), do: {:error, :enosys}

  defp hard_remove(:persona, persona), do: Personas.delete(persona.id)
  defp hard_remove(:ticket, item), do: item.id |> Repo.get(Item) |> Repo.delete()

  defp hard_remove(:artifact, artifact) do
    Repo.transaction(fn ->
      Repo.delete_all(from_rev(artifact.id))
      Repo.delete(%Artifact{id: artifact.id})
    end)
  end

  defp hard_remove(:wiki_page, page), do: Wiki.delete_page(page.id)

  defp from_rev(artifact_id) do
    import Ecto.Query, only: [where: 3]
    where(ArtifactRevision, [r], r.artifact_id == ^artifact_id)
  end

  defp hard_delete?(),
    do: :noizu_prompt_lingua |> Application.get_env(:mcp_vfs_pm, []) |> Keyword.get(:hard_delete, false)

  # ═════════════════════════════════ search ═════════════════════════════════

  # Pragmatic: render every file under `root` and scan lines. DB full-text is a
  # future upgrade.
  @impl true
  def search(root, query, _ctx) when is_binary(query) do
    with {:ok, view} <- resolve(root) do
      matches =
        view
        |> collect_docs(@entity_cap)
        |> scan_docs(String.downcase(query))

      {:ok, matches, nil}
    else
      {:error, _} = err -> err
    end
  end

  defp scan_docs(docs, needle) do
    for {path, content} <- docs,
        {line, line_no} <- content |> String.split("\n") |> Enum.with_index(1),
        String.contains?(String.downcase(line), needle) do
      %{path: path, line: line_no, text: String.trim_trailing(line)}
    end
  end

  defp collect_docs(view, cap) do
    case children(view) do
      {:ok, entries} ->
        parent = view_path(view)

        entries
        |> Enum.take(cap)
        |> Enum.flat_map(fn entry ->
          child = join_path(parent, entry.name)

          cond do
            entry.type == :file -> [{child, render_path(child)}]
            entry.type == :dir -> collect_docs_by_path(child, cap - 1)
            true -> []
          end
        end)

      _ ->
        []
    end
  end

  defp collect_docs_by_path(path, cap) when cap > 0 do
    case resolve(path) do
      {:ok, view} -> collect_docs(view, cap)
      _ -> []
    end
  end

  defp collect_docs_by_path(_, _), do: []

  defp render_path(path) do
    case read(path, %Noizu.MCP.Ctx{}) do
      {:ok, content, _v} -> content
      _ -> ""
    end
  end

  # ═════════════════════════════════ xattr ══════════════════════════════════

  @impl true
  def xattr(path, _ctx) do
    case resolve(path) do
      {:ok, view} ->
        case xattrs_for(view) do
          {:ok, xattrs} -> {:ok, xattrs}
          {:error, _} = err -> err
        end

      {:error, _} = err ->
        err
    end
  end

  # ══════════════════════════════ path resolution ═══════════════════════════

  defp normalize(path) when is_binary(path) do
    case String.split(path, "/", trim: true) do
      [] -> {:ok, []}
      ["pm"] -> {:ok, []}
      ["pm" | rest] -> {:ok, rest}
      _ -> {:error, :enoent}
    end
  end

  defp resolve(path) when is_binary(path) do
    with {:ok, segs} <- normalize(path) do
      resolve_segs(segs)
    end
  end

  defp resolve_segs([]), do: {:ok, {:root}}

  defp resolve_segs([o]) do
    with {:ok, org} <- fetch_org(o), do: {:ok, {:org, org}}
  end

  defp resolve_segs([o, "index.yaml"]) do
    with {:ok, org} <- fetch_org(o), do: {:ok, {:control, {:org_index, org}}}
  end

  defp resolve_segs([o, p]) do
    with {:ok, org} <- fetch_org(o),
         {:ok, project} <- fetch_project(org, p) do
      {:ok, {:project, org, project}}
    end
  end

  defp resolve_segs([o, p, "index.yaml"]) do
    with {:ok, org} <- fetch_org(o),
         {:ok, project} <- fetch_project(org, p) do
      {:ok, {:control, {:project_index, org, project}}}
    end
  end

  defp resolve_segs([o, p, f]) when f in @rollups do
    with {:ok, org} <- fetch_org(o),
         {:ok, project} <- fetch_project(org, p) do
      {:ok, {:control, {:rollup, rollup_kind(f), org, project}}}
    end
  end

  defp resolve_segs([o, p, t]) when t in @type_dirs do
    with {:ok, org} <- fetch_org(o),
         {:ok, project} <- fetch_project(org, p) do
      {:ok, {:type_dir, dir_type(t), org, project}}
    end
  end

  defp resolve_segs([o, p, t, "index.yaml"]) when t in @type_dirs do
    with {:ok, org} <- fetch_org(o),
         {:ok, project} <- fetch_project(org, p) do
      {:ok, {:control, {:type_index, dir_type(t), org, project}}}
    end
  end

  defp resolve_segs([o, p, "wiki", space]) do
    with {:ok, org} <- fetch_org(o),
         {:ok, project} <- fetch_project(org, p),
         {:ok, sp} <- fetch_space(org, project, space) do
      {:ok, {:space_dir, org, project, sp}}
    end
  end

  defp resolve_segs([o, p, "wiki", space, "index.yaml"]) do
    with {:ok, org} <- fetch_org(o),
         {:ok, project} <- fetch_project(org, p),
         {:ok, sp} <- fetch_space(org, project, space) do
      {:ok, {:control, {:space_index, org, project, sp}}}
    end
  end

  defp resolve_segs([o, p, "wiki", space, f]) do
    with {:ok, org} <- fetch_org(o),
         {:ok, project} <- fetch_project(org, p),
         {:ok, sp} <- fetch_space(org, project, space),
         {:ok, page} <- fetch_page(sp, f) do
      {:ok, {:file, {:wiki_page, page}, %{org_id: org.id}}}
    end
  end

  defp resolve_segs([o, p, t, f])
       when t in ~w(personas tickets artifacts) and f != "index.yaml" do
    with {:ok, org} <- fetch_org(o),
         {:ok, project} <- fetch_project(org, p),
         {:ok, hit} <- fetch_entity(dir_type(t), org, project, f) do
      {:ok, {:file, hit, %{org_id: org.id}}}
    end
  end

  defp resolve_segs(_), do: {:error, :enoent}

  defp dir_type("personas"), do: :persona
  defp dir_type("tickets"), do: :ticket
  defp dir_type("artifacts"), do: :artifact
  defp dir_type("wiki"), do: :wiki_page
  defp dir_type(_), do: :unknown

  defp rollup_kind("personas.md"), do: :persona
  defp rollup_kind("tickets.md"), do: :ticket
  defp rollup_kind("artifacts.md"), do: :artifact

  defp fetch_org(ref) when is_binary(ref) do
    org =
      case Ecto.UUID.cast(ref) do
        {:ok, uuid} ->
          Organizations.get_organization(uuid)

        :error ->
          case Organizations.get_id_by_slug(ref) do
            nil -> nil
            id -> Organizations.get_organization(id)
          end
      end

    (org && {:ok, org}) || {:error, :enoent}
  end

  defp fetch_project(org, ref) do
    project =
      Repo.get_by(Project, organization_id: org.id, slug: ref) ||
        case Ecto.UUID.cast(ref) do
          {:ok, uuid} -> Repo.get_by(Project, id: uuid, organization_id: org.id)
          :error -> nil
        end

    (project && {:ok, project}) || {:error, :enoent}
  end

  defp fetch_space(org, project, slug) do
    case Wiki.get_space_by_slug(org.id, slug) do
      %{project_id: pid} = sp when pid in [nil, project.id] -> {:ok, sp}
      _ -> {:error, :enoent}
    end
  end

  defp fetch_page(space, f) do
    case Repo.get_by(Page, space_id: space.id, slug: base_name(f)) do
      nil -> {:error, :enoent}
      page -> {:ok, page}
    end
  end

  # Entity lookup by filename. Personas: `<slug>.md`. Tickets: `<KEY>-<slug>.md`
  # (KEY = the item's immutable human key). Artifacts: `A-<uuid>-<slug>.md`.
  defp fetch_entity(:persona, org, project, f) do
    slug = base_name(f)

    case Personas.resolve(org.id, slug) do
      %{project_id: pid} = persona when pid in [nil, project.id] -> {:ok, {:persona, persona}}
      _ -> {:error, :enoent}
    end
  end

  defp fetch_entity(:ticket, org, project, f) do
    case Regex.run(~r/^([A-Z0-9]+-\d+)-/, base_name(f)) do
      [_, key] ->
        case Items.get_by_key(org.id, key) do
          %{project_id: pid} = item when pid == project.id -> {:ok, {:ticket, item}}
          _ -> {:error, :enoent}
        end

      _ ->
        {:error, :enoent}
    end
  end

  defp fetch_entity(:artifact, org, project, f) do
    case Regex.run(~r/^A-([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})-/, base_name(f)) do
      [_, uuid] ->
        case Repo.get(Artifact, uuid) do
          %{organization_id: oid, project_id: pid} = artifact
          when oid == org.id and pid == project.id ->
            {:ok, {:artifact, artifact}}

          _ ->
            {:error, :enoent}
        end

      _ ->
        {:error, :enoent}
    end
  end

  defp fetch_entity(_, _, _, _), do: {:error, :enoent}

  # ═══════════════════════════════ nodes/entries ════════════════════════════

  defp node_for({:root}),
    do: {:ok, dir(0, %{"mcp.type" => "pm-root"})}

  defp node_for({:org, org}),
    do: {:ok, dir(mtime(org), %{"mcp.id" => org.id, "mcp.type" => "organization", "pm.slug" => org.slug})}

  defp node_for({:project, org, project}),
    do: {:ok, dir(mtime(project), project_xattrs(org, project))}

  defp node_for({:type_dir, kind, _org, project}) do
    {:ok, dir(mtime(project), %{"mcp.type" => Atom.to_string(kind), "pm.project" => project.slug})}
  end

  defp node_for({:space_dir, _org, _project, space}) do
    {:ok, dir(mtime(space), %{"mcp.id" => space.id, "mcp.type" => "wiki_space", "pm.slug" => space.slug})}
  end

  defp node_for({:file, hit, _extra}), do: {:ok, file_node(hit)}

  defp node_for({:control, spec}) do
    case content_for({:control, spec}) do
      {:ok, content, version} ->
        {:ok,
         %VFS{
           type: :control,
           size: byte_size(content),
           mtime: now_ms(),
           version: version,
           xattrs: %{"mcp.type" => "generated", "mcp.writable" => "false"}
         }}

      {:error, _} = err ->
        err
    end
  end

  defp project_xattrs(org, project) do
    %{
      "mcp.id" => project.id,
      "mcp.type" => "project",
      "pm.slug" => project.slug,
      "pm.status" => project.status,
      "pm.org" => org.slug
    }
  end

  defp file_node({kind, record}) do
    content = render_entity(kind, record)

    %VFS{
      type: :file,
      size: byte_size(content),
      mtime: mtime(record),
      version: max(mtime(record), 1),
      writable: true,
      xattrs: entity_xattrs(kind, record)
    }
  end

  defp entity_xattrs(:persona, p) do
    %{
      "mcp.id" => p.id,
      "mcp.type" => "persona",
      "pm.slug" => p.slug,
      "pm.status" => p.status,
      "pm.role" => p.role
    }
  end

  defp entity_xattrs(:ticket, t) do
    %{
      "mcp.id" => t.id,
      "mcp.type" => "ticket",
      "pm.key" => t.key,
      "pm.status" => t.status,
      "pm.priority" => t.priority,
      "pm.item_type" => t.item_type
    }
  end

  defp entity_xattrs(:artifact, a) do
    {_artifact, rev} = Artifacts.get(a.id)

    %{
      "mcp.id" => a.id,
      "mcp.type" => "artifact",
      "pm.kind" => a.kind,
      "pm.revision" => (rev && rev.revision_number) || 0,
      "pm.mime_type" => a.mime_type
    }
  end

  defp entity_xattrs(:wiki_page, page) do
    %{"mcp.id" => page.id, "mcp.type" => "wiki_page", "pm.slug" => page.slug}
  end

  defp xattrs_for({:file, hit, _extra}), do: {:ok, entity_xattrs(elem(hit, 0), elem(hit, 1))}

  defp xattrs_for(view) do
    case node_for(view) do
      {:ok, node} -> {:ok, node.xattrs}
      err -> err
    end
  end

  defp dir(mtime, xattrs), do: %VFS{type: :dir, mtime: mtime, version: max(mtime, 1), xattrs: xattrs}

  defp mtime(rec), do: unix_ms(Map.get(rec, :updated_at) || Map.get(rec, :inserted_at))
  defp unix_ms(%DateTime{} = dt), do: DateTime.to_unix(dt, :millisecond)
  defp unix_ms(_), do: 0
  defp now_ms, do: System.system_time(:millisecond)

  # ═══════════════════════════════ directory children ═══════════════════════

  defp children({:root}) do
    entries =
      for org <- Organizations.list_all() do
        entry(org.slug, :dir, mtime(org))
      end

    {:ok, entries}
  end

  defp children({:org, org}) do
    projects = Repo.all(from_proj(org.id))

    entries =
      Enum.map(projects, fn p ->
        entry(p.slug, :dir, mtime(p))
      end) ++ [control_entry("index.yaml")]

    {:ok, entries}
  end

  defp children({:project, _org, project}) do
    dirs =
      for t <- @type_dirs do
        entry(t, :dir, mtime(project))
      end

    controls = ["index.yaml" | @rollups] |> Enum.map(&control_entry/1)
    {:ok, dirs ++ controls}
  end

  defp children({:type_dir, :persona, org, project}) do
    personas = Personas.list(organization_id: org.id, project_id: project.id, include_org_level: true)

    entries =
      for p <- personas do
        file_entry("#{p.slug}.md", byte_size(render_entity(:persona, p)), mtime(p))
      end

    {:ok, entries ++ [control_entry("index.yaml")]}
  end

  defp children({:type_dir, :ticket, org, project}) do
    items = Items.list(organization_id: org.id, project_id: project.id, limit: @entity_cap)

    entries =
      for t <- items do
        file_entry("#{t.key}-#{slugify(t.title)}.md", byte_size(render_entity(:ticket, t)), mtime(t))
      end

    {:ok, entries ++ [control_entry("index.yaml")]}
  end

  defp children({:type_dir, :artifact, org, project}) do
    artifacts = Artifacts.list(organization_id: org.id, project_id: project.id, limit: @entity_cap)

    entries =
      for a <- artifacts do
        file_entry("A-#{a.id}-#{slugify(a.title)}.md", byte_size(render_entity(:artifact, a)), mtime(a))
      end

    {:ok, entries ++ [control_entry("index.yaml")]}
  end

  defp children({:type_dir, :wiki_page, org, project}) do
    spaces = Wiki.list_spaces(organization_id: org.id, project_id: project.id)

    entries =
      for s <- spaces do
        entry("#{s.slug}", :dir, mtime(s))
      end

    {:ok, entries ++ [control_entry("index.yaml")]}
  end

  defp children({:space_dir, _org, _project, space}) do
    pages = Wiki.list_pages(space.id)

    entries =
      for pg <- pages do
        file_entry("#{pg.slug}.md", byte_size(render_entity(:wiki_page, pg)), mtime(pg))
      end

    {:ok, entries ++ [control_entry("index.yaml")]}
  end

  defp children(_), do: {:error, :enotdir}

  defp from_proj(org_id) do
    import Ecto.Query, only: [where: 3]
    where(Project, [p], p.organization_id == ^org_id)
  end

  defp entry(name, type, mtime),
    do: %{name: name, type: type, size: 0, mtime: mtime, version: max(mtime, 1)}

  defp file_entry(name, size, mtime), do: %{entry(name, :file, mtime) | size: size}
  defp control_entry(name), do: entry(name, :control, now_ms())

  # ═══════════════════════════════ content ══════════════════════════════════

  defp content_for({:org, _org}), do: {:error, :eisdir}
  defp content_for({:project, _org, _project}), do: {:error, :eisdir}
  defp content_for({:type_dir, _kind, _org, _project}), do: {:error, :eisdir}
  defp content_for({:space_dir, _org, _project, _space}), do: {:error, :eisdir}

  defp content_for({:file, {kind, record}, _extra}),
    do: {:ok, render_entity(kind, record), max(mtime(record), 1)}

  defp content_for({:control, {:org_index, org}}), do: {:ok, org_index(org), max(mtime(org), 1)}

  defp content_for({:control, {:project_index, _org, project}}),
    do: {:ok, project_index(project), max(mtime(project), 1)}

  defp content_for({:control, {:type_index, kind, org, project}}),
    do: {:ok, type_index(kind, org, project), max(mtime(project), 1)}

  defp content_for({:control, {:space_index, _org, _project, space}}),
    do: {:ok, space_index(space), max(mtime(space), 1)}

  defp content_for({:control, {:rollup, kind, org, project}}),
    do: {:ok, rollup(kind, org, project), now_ms()}

  defp content_for(_), do: {:error, :eisdir}

  defp render_entity(:persona, p) do
    frontmatter(
      id: p.id,
      slug: p.slug,
      type: "persona",
      name: p.name,
      role: p.role,
      status: p.status,
      tags: p.tags,
      updated: iso8601(Map.get(p, :updated_at))
    ) <> (p.bio || "") <> "\n"
  end

  defp render_entity(:ticket, t) do
    frontmatter(
      id: t.id,
      key: t.key,
      type: "ticket",
      item_type: t.item_type,
      title: t.title,
      status: t.status,
      priority: t.priority,
      assignee: t.assignee,
      tags: t.tags,
      updated: iso8601(Map.get(t, :updated_at))
    ) <> (t.description || "") <> "\n"
  end

  defp render_entity(:artifact, a) do
    {_artifact, rev} = Artifacts.get(a.id)

    frontmatter(
      id: a.id,
      type: "artifact",
      kind: a.kind,
      title: a.title,
      mime_type: a.mime_type,
      revision: rev && rev.revision_number,
      updated: iso8601(Map.get(a, :updated_at))
    ) <> ((rev && rev.content) || "") <> "\n"
  end

  defp render_entity(:wiki_page, pg) do
    frontmatter(
      id: pg.id,
      slug: pg.slug,
      type: "wiki_page",
      title: pg.title,
      position: pg.position,
      updated: iso8601(Map.get(pg, :updated_at))
    ) <> (pg.content || "") <> "\n"
  end

  defp frontmatter(pairs) do
    body = Enum.map_join(pairs, "\n", fn {k, v} -> "#{k}: #{yaml_value(v)}" end)
    "---\n" <> body <> "\n---\n"
  end

  defp yaml_value(nil), do: "null"
  defp yaml_value(v) when is_integer(v), do: Integer.to_string(v)

  defp yaml_value(v) when is_list(v),
    do: "[" <> Enum.map_join(v, ", ", &yaml_value/1) <> "]"

  defp yaml_value(v) when is_binary(v) do
    if v == "" or String.contains?(v, [":", "#", "\n", "'", "\""]) do
      inspect(v)
    else
      v
    end
  end

  defp iso8601(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp iso8601(_), do: nil

  # ── generated indexes (mirror the on-disk project-management/ convention) ──

  defp org_index(org) do
    projects = Repo.all(from_proj(org.id))

    """
    organization: #{org.slug}
    projects:
    #{entries_yaml(projects, fn p -> %{"id" => p.id, "title" => p.name, "file" => p.slug <> "/", "status" => p.status} end)}
    """
  end

  defp project_index(project) do
    type_lines =
      @type_dirs
      |> Enum.map(&"- #{&1}/")
      |> Enum.join("\n")

    rollup_lines =
      @rollups
      |> Enum.map(&"- #{&1}")
      |> Enum.join("\n")

    """
    project: #{project.slug}
    id: #{project.id}
    status: #{project.status}
    directories:
    #{type_lines}
    generated:
    #{rollup_lines}
    note: index.yaml and *.md rollups are generated on read and read-only
    """
  end

  defp type_index(kind, org, project) do
    {label, rows} = index_rows(kind, org, project)

    """
    #{label}:
    #{entries_yaml(rows, fn r -> r end)}
    """
  end

  defp index_rows(:persona, org, project) do
    rows =
      for p <- Personas.list(organization_id: org.id, project_id: project.id, include_org_level: true) do
        %{"id" => p.id, "title" => p.name, "file" => "#{p.slug}.md", "status" => p.status, "role" => p.role}
      end

    {"personas", rows}
  end

  defp index_rows(:ticket, org, project) do
    rows =
      for t <- Items.list(organization_id: org.id, project_id: project.id, limit: @entity_cap) do
        %{
          "id" => t.id,
          "key" => t.key,
          "title" => t.title,
          "file" => "#{t.key}-#{slugify(t.title)}.md",
          "status" => t.status,
          "priority" => t.priority
        }
      end

    {"tickets", rows}
  end

  defp index_rows(:artifact, org, project) do
    rows =
      for a <- Artifacts.list(organization_id: org.id, project_id: project.id, limit: @entity_cap) do
        %{"id" => a.id, "title" => a.title, "file" => "A-#{a.id}-#{slugify(a.title)}.md", "kind" => a.kind}
      end

    {"artifacts", rows}
  end

  defp index_rows(:wiki_page, org, project) do
    rows =
      for s <- Wiki.list_spaces(organization_id: org.id, project_id: project.id) do
        %{"id" => s.id, "title" => s.name, "file" => "#{s.slug}/"}
      end

    {"wiki", rows}
  end

  defp space_index(space) do
    rows =
      for pg <- Wiki.list_pages(space.id) do
        %{"id" => pg.id, "title" => pg.title, "file" => "#{pg.slug}.md", "position" => pg.position}
      end

    """
    space: #{space.slug}
    pages:
    #{entries_yaml(rows, fn r -> r end)}
    """
  end

  # Rollups render a one-line-per-entity summary; control type, read-only.
  defp rollup(:persona, org, project) do
    body =
      for p <- Personas.list(organization_id: org.id, project_id: project.id, include_org_level: true) do
        "- [#{p.slug}](personas/#{p.slug}.md) — #{p.name}#{role_suffix(p.role)} [#{p.status}]"
      end
      |> Enum.join("\n")

    "# Personas\n\n#{body}\n"
  end

  defp rollup(:ticket, org, project) do
    body =
      for t <- Items.list(organization_id: org.id, project_id: project.id, limit: @entity_cap) do
        "- [#{t.key}](tickets/#{t.key}-#{slugify(t.title)}.md) — #{t.title} [#{t.status}]#{prio_suffix(t.priority)}"
      end
      |> Enum.join("\n")

    "# Tickets\n\n#{body}\n"
  end

  defp rollup(:artifact, org, project) do
    body =
      for a <- Artifacts.list(organization_id: org.id, project_id: project.id, limit: @entity_cap) do
        "- [#{a.title}](artifacts/A-#{a.id}-#{slugify(a.title)}.md) (#{a.kind})"
      end
      |> Enum.join("\n")

    "# Artifacts\n\n#{body}\n"
  end

  defp entries_yaml(rows, mapper) do
    rows
    |> Enum.map(fn row ->
      map = mapper.(row)

      "  - " <>
        Enum.map_join(map, "\n    ", fn {k, v} -> "#{k}: #{yaml_value(v)}" end)
    end)
    |> Enum.join("\n")
    |> case do
      "" -> "  []"
      yaml -> yaml
    end
  end

  defp role_suffix(nil), do: ""
  defp role_suffix(role), do: " (#{role})"
  defp prio_suffix(nil), do: ""
  defp prio_suffix(p), do: " (#{p})"

  # ═══════════════════════════════ parsing ══════════════════════════════════

  defp parse_doc(data) do
    with {:ok, fm_src, body} <- split_doc(data),
         {:ok, fm} <- YamlElixir.read_from_string(fm_src) do
      fm = if is_map(fm), do: fm, else: %{}
      body = String.trim_trailing(body, "\n")
      {:ok, fm, if(body == "", do: nil, else: body)}
    else
      _ -> {:error, Error.invalid_params("malformed document: expected YAML frontmatter + body")}
    end
  end

  defp split_doc("---\n" <> rest) do
    case :binary.split(rest, "\n---\n") do
      [fm, body] -> {:ok, fm, body}
      _ -> :error
    end
  end

  defp split_doc(_), do: :error

  defp fm_name(fm), do: fm["name"] || fm["title"]
  defp fm_tags(fm), do: (is_list(fm["tags"]) && fm["tags"]) || nil

  # ═══════════════════════════════ identity/authz ═══════════════════════════

  defp require_user(ctx) do
    case Resolve.current_user_id(ctx) do
      nil -> {:error, :eacces}
      user_id -> {:ok, user_id}
    end
  end

  defp authorize(user_id, org_id) do
    case authorize_fun().(user_id, org_id) do
      :ok -> :ok
      {:ok, _} -> :ok
      _ -> {:error, :eacces}
    end
  end

  defp authorize_fun do
    :noizu_prompt_lingua
    |> Application.get_env(:mcp_vfs_pm, [])
    |> Keyword.get(:authorize, &default_authorize/2)
  end

  defp default_authorize(user_id, org_id) do
    Authz.authorize(user_id, "organization", org_id, "member")
  end

  # ═══════════════════════════════ cursors ══════════════════════════════════

  defp encode_cursor(offset), do: Base.url_encode64(Jason.encode!(%{"o" => offset}))

  defp decode_cursor(nil), do: {:ok, 0}

  defp decode_cursor(cursor) do
    with {:ok, json} <- Base.url_decode64(cursor),
         {:ok, %{"o" => offset}} <- Jason.decode(json),
         true <- is_integer(offset) and offset >= 0 do
      {:ok, offset}
    else
      _ -> {:error, Error.invalid_params("invalid cursor")}
    end
  end

  # ═══════════════════════════════ names ════════════════════════════════════

  defp base_name(f), do: f |> String.replace_suffix(".md", "")

  defp slugify(nil), do: "untitled"

  defp slugify(title) do
    title
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
    |> case do
      "" -> "untitled"
      s -> String.slice(s, 0, 60)
    end
  end

  defp titleize(slug),
    do: slug |> String.split("-") |> Enum.map_join(" ", &String.capitalize/1)

  defp join_path(parent, name), do: Enum.join([parent, name], "/")

  defp view_path({:root}), do: "/pm"
  defp view_path({:org, org}), do: "/pm/#{org.slug}"
  defp view_path({:project, org, project}), do: "/pm/#{org.slug}/#{project.slug}"

  defp view_path({:type_dir, kind, org, project}),
    do: "/pm/#{org.slug}/#{project.slug}/#{type_dir_name(kind)}"

  defp view_path({:space_dir, org, project, space}),
    do: "/pm/#{org.slug}/#{project.slug}/wiki/#{space.slug}"

  defp type_dir_name(:persona), do: "personas"
  defp type_dir_name(:ticket), do: "tickets"
  defp type_dir_name(:artifact), do: "artifacts"
  defp type_dir_name(:wiki_page), do: "wiki"

  defp writable_file({:file, hit, extra}), do: {:ok, elem(hit, 0), elem(hit, 1), extra}
  defp writable_file(_), do: {:error, :erofs}
end
