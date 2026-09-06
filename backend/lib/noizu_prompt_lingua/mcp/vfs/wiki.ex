defmodule NoizuPromptLingua.MCP.VFS.Wiki do
  @moduledoc """
  Wiki group backend (Wave 1, natural-file) — MCP-VFS-GROUP-MOUNTS.md §2.1.

  Dispatched by `NoizuPromptLingua.MCP.VFS.Root` for every `/tobor/{org}/wiki/**`
  path; every op re-resolves the connection principal
  (`NoizuPromptLingua.MCP.VFS.Principal`), so an org outside the key scope or an
  excluded/hidden `wiki` group is `:enoent` for the whole subtree, and an
  included-but-disabled group serves read-only (`writable: false`, mutating ops
  `:eacces`).

  ## Path map (op ↔ file, §2.1)

      /tobor/{org}/wiki                              readdir = spaces (SpaceList)
      /tobor/{org}/wiki/overview.md                  group Overview (read-only furniture)
      /tobor/{org}/wiki/{space}                      readdir = pages + meta files (PageList)
      /tobor/{org}/wiki/{space}/_space.json          SpaceGet / SpaceUpdate
      /tobor/{org}/wiki/{space}/{page}.md            PageGet / PageCreate / PageUpdate / PageDelete
      /tobor/{org}/wiki/{space}/{page}.comments/     CommentList (readdir)
      /tobor/{org}/wiki/{space}/{page}.comments/{id}.json     CommentCreate / CommentDelete
      /tobor/{org}/wiki/{space}/{page}.assets/       AttachmentList (readdir)
      /tobor/{org}/wiki/{space}/{page}.assets/{filename}      AttachmentCreate / AttachmentDelete
      /tobor/{org}/wiki/{space}/reactions.json       ReactionList / ReactionAdd / ReactionRemove

  `list/3` is cursor-paginated (lib `Features.Pagination`), so large spaces stay
  bounded on the wire; the daemon's walk honors `nextCursor`.

  ## File formats

    * `{page}.md` — YAML front-matter (`id`, `title`, `slug`, `position`,
      `parent`, `created`, `updated`) followed by the page body (the row's
      `content`). A write WITH front-matter updates title/position/parent from
      it and the body from the remainder; the front-matter `id`/`slug` are
      IGNORED — the path is the identity. A write WITHOUT front-matter replaces
      only the body. On create the title falls back to the first `#` heading,
      then to the humanized slug. `parent` resolves by page slug, or by UUID
      when that page belongs to the same space.
    * `_space.json` — canonical space document (record.json convention, §3.4);
      writes merge the provided `name` / `description` / `project_id` fields
      (absent keys leave the row unchanged; canonical-doc writes are
      last-write-wins merges).
    * `{id}.json` comment files — server-assigned UUID ids: `create` accepts
      any filename and returns the real id in `xattrs["id"]` (the §2.8
      TicketCreate key-assignment convention). Content is the raw body text,
      or a JSON object (`body`, `author`, `parent`); author defaults to the
      principal, then `"vfs"`.
    * `assets/{filename}` — text-only until the B1 blob contract (§3.3):
      content is stored as a `data:` URI on the attachment row and `read`
      decodes it back; non-UTF-8 uploads are refused with `:enosys`. `write`
      is `:enosys` — the tool surface has AttachmentCreate/Delete only; edit =
      remove + create.
    * `reactions.json` — desired-state document for the whole space:
      `{"page": {"<page-id>": [{"emoji", "actor"}]}, "comment": {…}}`. A write
      syncs the space to the document — entries not present are added, present
      entries absent from the document are removed, and targets the document
      does not mention lose their reactions (ReactionAdd + ReactionRemove
      composed); targets outside the space are ignored, malformed docs are
      `:eio`. `read` renders the current state.

  ## Semantics

    * `write` is whole-file overwrite with no server-side CAS (lib §0.1);
      concurrent-edit races surface through the daemon's stat-then-push
      `.conflict-*` save-aside (§0.3).
    * Comment/attachment files are not writable (`write` → `:enosys`); only
      create/remove are mapped, per the §2.1 table.
    * `remove {space}` is `:enotempty` while pages exist; `remove {page}.md` is
      `:enotempty` while comments/attachments exist. Force-deletes stay on the
      MCP tool surface via `/etc/dev` control writes (§3.5).
    * `search/3` greps page bodies (case-insensitive substring per line) under
      `root` (the group root, a space, or a single page) — `mcp_fs_search` gets
      wiki for free.
    * Liveness: `live` for VFS-routed writes (generation bump + pubsub via the
      lib `Features.VFS` wrappers); `ttl` (cache TTL) for web-UI edits until
      the L1 domain publish hooks land (§6 Q5).

  All persistence goes through `NoizuPromptLingua.Domains.Wiki`; no SQL lives in
  this module.
  """

  use Noizu.MCP.VFS

  alias Noizu.MCP.Server.Features.Pagination
  alias Noizu.MCP.VFS
  alias NoizuPromptLingua.Domains.Wiki
  alias NoizuPromptLingua.MCP.Resolve
  alias NoizuPromptLingua.MCP.VFS.Principal
  alias NoizuPromptLingua.Schema.Wiki.{Attachment, Comment}

  @group "wiki"
  @space_meta "_space.json"
  @reactions_file "reactions.json"
  @page_ext ".md"
  @comments_ext ".comments"
  @assets_ext ".assets"
  @overview "overview.md"

  # Hard bound on context listings that have no native cursor; Pagination
  # slices the assembled entry list for the wire.
  @listing_limit 10_000
  @slug_format ~r/^[a-z0-9-]+$/

  # ── stat/2 ────────────────────────────────────────────────────────────────

  @impl true
  def stat(path, ctx) do
    with {:ok, scope, rest} <- parse(path, ctx) do
      stat_node(rest, scope)
    end
  end

  defp stat_node([], scope), do: {:ok, dir_node(scope.writable)}

  # Group furniture: the group's own Overview, served by the backend that owns
  # the subtree (Root hands the whole wiki prefix over, this file included).
  defp stat_node([@overview], scope) do
    md = overview_md(scope)
    {:ok, file_node(byte_size(md), scope.writable, content_version(md))}
  end

  defp stat_node([space_slug], scope) do
    with {:ok, space} <- fetch_space(scope, space_slug) do
      {:ok, dir_node(scope.writable, space_xattrs(space))}
    end
  end

  defp stat_node([space_slug, leaf], scope) do
    with {:ok, space} <- fetch_space(scope, space_slug) do
      stat_leaf(leaf_kind(leaf), space, scope)
    end
  end

  defp stat_node([space_slug, coll, item], scope) do
    with {:ok, space} <- fetch_space(scope, space_slug),
         {:ok, page, kind} <- coll_kind(coll, space) do
      stat_item(kind, page, item)
    end
  end

  defp stat_node(_, _scope), do: {:error, :enoent}

  defp stat_leaf({:ok, :space_meta, nil}, space, scope) do
    json = Jason.encode!(space_doc(space))
    {:ok, file_node(byte_size(json), scope.writable, row_version(space), space_xattrs(space))}
  end

  defp stat_leaf({:ok, :reactions, nil}, space, scope) do
    json = reactions_json(space)
    {:ok, file_node(byte_size(json), scope.writable, content_version(json))}
  end

  defp stat_leaf({:ok, :page, slug}, space, scope) do
    with {:ok, page} <- fetch_page(space, slug) do
      {:ok,
       file_node(
         byte_size(serialize_page(page)),
         scope.writable,
         row_version(page),
         page_xattrs(page)
       )}
    end
  end

  defp stat_leaf({:ok, kind, slug}, space, scope) when kind in [:comments, :assets] do
    with {:ok, _page} <- fetch_page(space, slug) do
      {:ok, dir_node(scope.writable)}
    end
  end

  defp stat_leaf(_, _space, _scope), do: {:error, :enoent}

  defp stat_item(:comments, page, item) do
    with {:ok, id} <- comment_id(item),
         %Comment{} = comment <- owned_comment(page, id) do
      json = Jason.encode!(comment_doc(comment))

      {:ok,
       file_node(byte_size(json), false, row_version(comment), %{
         "id" => comment.id,
         "author" => comment.author,
         "page_id" => page.id
       })}
    else
      _ -> {:error, :enoent}
    end
  end

  defp stat_item(:assets, page, filename) do
    case find_attachment(page, filename) do
      %Attachment{} = att ->
        content = attachment_content(att)

        {:ok,
         file_node(byte_size(content), false, row_version(att), %{
           "mime_type" => att.mime_type,
           "byte_size" => att.byte_size
         })}

      nil ->
        {:error, :enoent}
    end
  end

  # ── list/3 ────────────────────────────────────────────────────────────────

  @impl true
  def list(path, cursor, ctx) do
    with {:ok, scope, rest} <- parse(path, ctx) do
      list_node(rest, scope, cursor)
    end
  end

  defp list_node([], scope, cursor) do
    space_entries = Enum.map(list_spaces(scope), &dir_entry(&1.slug, row_version(&1)))
    md = overview_md(scope)

    paginate(space_entries ++ [file_entry(@overview, byte_size(md), content_version(md))], cursor)
  end

  defp list_node([space_slug], scope, cursor) do
    with {:ok, space} <- fetch_space(scope, space_slug) do
      pages = Wiki.list_pages(space.id, limit: @listing_limit)

      meta_entries = [
        file_entry(@space_meta, space_meta_size(space), row_version(space)),
        file_entry(@reactions_file, 0, 1)
      ]

      page_entries =
        Enum.map(
          pages,
          &file_entry(&1.slug <> @page_ext, byte_size(serialize_page(&1)), row_version(&1))
        )

      coll_entries =
        Enum.flat_map(pages, fn page ->
          comments =
            if Wiki.list_comments(page.id) == [],
              do: [],
              else: [dir_entry(page.slug <> @comments_ext, 1)]

          assets =
            if Wiki.list_attachments(page.id) == [],
              do: [],
              else: [dir_entry(page.slug <> @assets_ext, 1)]

          comments ++ assets
        end)

      paginate(meta_entries ++ page_entries ++ coll_entries, cursor)
    end
  end

  # `.comments` / `.assets` collections list their items; page files and meta
  # files are not directories (:enotdir); unknown leaves are :enoent.
  defp list_node([space_slug, leaf], scope, cursor) do
    with {:ok, space} <- fetch_space(scope, space_slug) do
      case coll_kind(leaf, space) do
        {:ok, page, :comments} ->
          entries =
            Enum.map(Wiki.list_comments(page.id), fn c ->
              file_entry(
                c.id <> ".json",
                byte_size(Jason.encode!(comment_doc(c))),
                row_version(c)
              )
            end)

          paginate(entries, cursor)

        {:ok, page, :assets} ->
          entries =
            Enum.map(Wiki.list_attachments(page.id), fn a ->
              file_entry(a.filename, byte_size(attachment_content(a)), row_version(a))
            end)

          paginate(entries, cursor)

        {:error, :enoent} ->
          case leaf_kind(leaf) do
            {:ok, :unknown, _leaf} -> {:error, :enoent}
            _ -> {:error, :enotdir}
          end
      end
    end
  end

  defp list_node(_, _scope, _cursor), do: {:error, :enoent}

  defp paginate(entries, cursor) do
    case Pagination.paginate(entries, cursor) do
      {:ok, page, next} -> {:ok, page, next}
      {:error, error} -> {:error, error}
    end
  end

  # ── read/2 ────────────────────────────────────────────────────────────────

  @impl true
  def read(path, ctx) do
    with {:ok, scope, rest} <- parse(path, ctx) do
      read_node(rest, scope)
    end
  end

  defp read_node([@overview], scope),
    do: {:ok, overview_md(scope), content_version(overview_md(scope))}

  defp read_node([space_slug, @space_meta], scope) do
    with {:ok, space} <- fetch_space(scope, space_slug) do
      {:ok, Jason.encode!(space_doc(space)), row_version(space)}
    end
  end

  defp read_node([space_slug, @reactions_file], scope) do
    with {:ok, space} <- fetch_space(scope, space_slug) do
      json = reactions_json(space)
      {:ok, json, content_version(json)}
    end
  end

  defp read_node([space_slug, leaf], scope) do
    with {:ok, space} <- fetch_space(scope, space_slug) do
      case leaf_kind(leaf) do
        {:ok, :page, slug} ->
          with {:ok, page} <- fetch_page(space, slug) do
            {:ok, serialize_page(page), row_version(page)}
          end

        {:ok, :unknown, _leaf} ->
          {:error, :enoent}

        _kind ->
          # .comments/.assets dirs are not readable as files.
          {:error, :eisdir}
      end
    end
  end

  defp read_node([space_slug, coll, item], scope) do
    with {:ok, space} <- fetch_space(scope, space_slug),
         {:ok, page, kind} <- coll_kind(coll, space) do
      read_item(kind, page, item)
    end
  end

  defp read_node([space_slug], scope) do
    # A space is a directory, not a file; an invalid slug was never a node.
    if valid_slug?(space_slug), do: {:error, :eisdir}, else: {:error, :enoent}
  end

  defp read_node(_, _scope), do: {:error, :eisdir}

  defp read_item(:comments, page, item) do
    with {:ok, id} <- comment_id(item),
         %Comment{} = comment <- owned_comment(page, id) do
      {:ok, Jason.encode!(comment_doc(comment)), row_version(comment)}
    else
      _ -> {:error, :enoent}
    end
  end

  defp read_item(:assets, page, filename) do
    case find_attachment(page, filename) do
      %Attachment{} = att -> {:ok, attachment_content(att), row_version(att)}
      nil -> {:error, :enoent}
    end
  end

  # ── create/3 ──────────────────────────────────────────────────────────────

  @impl true
  def create(path, data, ctx) do
    with {:ok, scope, rest} <- parse(path, ctx),
         :ok <- require_writable(scope) do
      create_node(rest, data, scope, principal_author(ctx))
    end
  end

  # The group root and its furniture always exist.
  defp create_node([], _data, _scope, _author), do: {:error, :eexist}
  defp create_node([@overview], _data, _scope, _author), do: {:error, :eexist}

  defp create_node([space_slug], data, scope, _author) do
    with :ok <- valid_slug(space_slug),
         :ok <- ensure_absent_space(scope, space_slug),
         {:ok, attrs} <- space_attrs(data, space_slug, scope) do
      case Wiki.create_space(attrs) do
        {:ok, space} -> {:ok, dir_node(true, space_xattrs(space))}
        {:error, _} -> {:error, :eio}
      end
    end
  end

  defp create_node([space_slug, leaf], data, scope, author) do
    with {:ok, space} <- fetch_space(scope, space_slug) do
      create_leaf(leaf_kind(leaf), space, data, author)
    end
  end

  defp create_node([space_slug, coll, item], data, scope, author) do
    with {:ok, space} <- fetch_space(scope, space_slug),
         {:ok, page, kind} <- coll_kind(coll, space) do
      create_item(kind, page, item, data, author)
    end
  end

  defp create_node(_, _data, _scope, _author), do: {:error, :enoent}

  # Meta files exist as soon as the space does.
  defp create_leaf({:ok, kind, nil}, _space, _data, _author)
       when kind in [:space_meta, :reactions],
       do: {:error, :eexist}

  defp create_leaf({:ok, :page, slug}, space, data, _author) do
    with :ok <- ensure_absent_page(space, slug),
         {:ok, fm, body} <- parse_page_file(data),
         {:ok, parent_id} <- resolve_parent(space, fm) do
      attrs =
        %{
          space_id: space.id,
          slug: slug,
          title: derive_title(fm, body, slug),
          content: body,
          parent_id: parent_id
        }
        |> put_position(fm)

      case Wiki.create_page(attrs) do
        {:ok, page} ->
          {:ok,
           file_node(byte_size(serialize_page(page)), true, row_version(page), page_xattrs(page))}

        {:error, _} ->
          {:error, :eio}
      end
    end
  end

  # Implicit collection dirs: present iff the page exists.
  defp create_leaf({:ok, kind, slug}, space, _data, _author) when kind in [:comments, :assets] do
    case Wiki.get_page_by_slug(space.id, slug) do
      nil -> {:error, :enoent}
      %{} -> {:error, :eexist}
    end
  end

  defp create_leaf(_, _space, _data, _author), do: {:error, :enoent}

  defp create_item(:comments, page, _item, data, author) do
    {body, comment_author, parent_id} = comment_attrs(data, author)

    case Wiki.create_comment(%{
           page_id: page.id,
           body: body,
           author: comment_author,
           parent_id: parent_id
         }) do
      {:ok, comment} ->
        {:ok,
         file_node(byte_size(Jason.encode!(comment_doc(comment))), false, row_version(comment), %{
           "id" => comment.id,
           "author" => comment.author,
           "page_id" => page.id
         })}

      {:error, _} ->
        {:error, :eio}
    end
  end

  defp create_item(:assets, page, filename, data, _author) do
    with :ok <- ensure_absent_attachment(page, filename),
         :ok <- text_only(data) do
      mime = attachment_mime(filename)
      url = "data:" <> mime <> ";base64," <> Base.encode64(data)

      attrs = %{
        page_id: page.id,
        filename: filename,
        url: url,
        mime_type: mime,
        byte_size: byte_size(data)
      }

      case Wiki.create_attachment(attrs) do
        {:ok, att} ->
          {:ok,
           file_node(byte_size(data), false, row_version(att), %{
             "mime_type" => att.mime_type,
             "byte_size" => att.byte_size
           })}

        {:error, _} ->
          {:error, :eio}
      end
    end
  end

  # ── write/3 (whole-file overwrite) ────────────────────────────────────────

  @impl true
  def write(path, data, ctx) do
    with {:ok, scope, rest} <- parse(path, ctx),
         :ok <- require_writable(scope) do
      write_node(rest, data, scope)
    end
  end

  defp write_node([], _data, _scope), do: {:error, :eisdir}
  defp write_node([@overview], _data, _scope), do: {:error, :enosys}

  defp write_node([space_slug], _data, _scope) do
    # A space is a directory; an invalid slug was never a node.
    if valid_slug?(space_slug), do: {:error, :eisdir}, else: {:error, :enoent}
  end

  defp write_node([space_slug, @space_meta], data, scope) do
    with {:ok, space} <- fetch_space(scope, space_slug),
         {:ok, doc} <- decode_object(data) do
      attrs =
        %{}
        |> put_attr(:name, string_field(doc["name"]))
        |> put_attr(:description, string_field(doc["description"]))
        |> put_attr(:project_id, string_field(doc["project_id"]))

      case Wiki.update_space(space.id, attrs) do
        {:ok, space} ->
          {:ok,
           file_node(
             byte_size(Jason.encode!(space_doc(space))),
             true,
             row_version(space),
             space_xattrs(space)
           )}

        {:error, _} ->
          {:error, :eio}
      end
    end
  end

  defp write_node([space_slug, @reactions_file], data, scope) do
    with {:ok, space} <- fetch_space(scope, space_slug),
         :ok <- apply_reactions_doc(space, data) do
      json = reactions_json(space)
      {:ok, file_node(byte_size(json), true, content_version(json))}
    end
  end

  defp write_node([space_slug, leaf], data, scope) do
    with {:ok, space} <- fetch_space(scope, space_slug) do
      case leaf_kind(leaf) do
        {:ok, :page, slug} ->
          with {:ok, page} <- fetch_page(space, slug),
               {:ok, fm, body} <- parse_page_file(data),
               {:ok, parent_id} <- resolve_parent(space, fm) do
            attrs =
              %{content: body}
              |> put_attr(:title, fm && string_field(fm["title"]))
              |> put_position(fm)
              |> put_parent(fm, parent_id)

            case Wiki.update_page(page.id, attrs) do
              {:ok, page} ->
                {:ok,
                 file_node(
                   byte_size(serialize_page(page)),
                   true,
                   row_version(page),
                   page_xattrs(page)
                 )}

              {:error, _} ->
                {:error, :eio}
            end
          end

        {:ok, kind, _slug} when kind in [:comments, :assets] ->
          {:error, :eisdir}

        _ ->
          {:error, :enoent}
      end
    end
  end

  # Comment/attachment files have no update surface (§2.1: create/remove only).
  defp write_node([_space_slug, _coll, _item], _data, _scope), do: {:error, :enosys}

  defp write_node(_, _data, _scope), do: {:error, :enoent}

  # ── remove/2 ──────────────────────────────────────────────────────────────

  @impl true
  def remove(path, ctx) do
    with {:ok, scope, rest} <- parse(path, ctx),
         :ok <- require_writable(scope) do
      remove_node(rest, scope)
    end
  end

  # The namespace root is not removable; furniture/meta files are not in the
  # §2.1 remove mapping (force-deletes ride /etc/dev, §3.5).
  defp remove_node([], _scope), do: {:error, :eisdir}
  defp remove_node([@overview], _scope), do: {:error, :enosys}

  defp remove_node([space_slug], scope) do
    with {:ok, space} <- fetch_space(scope, space_slug),
         [] <- Wiki.list_pages(space.id, limit: 1) do
      case Wiki.delete_space(space.id) do
        {:ok, _} -> :ok
        {:error, :not_found} -> {:error, :enoent}
        {:error, _} -> {:error, :eio}
      end
    else
      {:error, _} = error -> error
      [_ | _] -> {:error, :enotempty}
    end
  end

  defp remove_node([space_slug, leaf], scope) do
    with {:ok, space} <- fetch_space(scope, space_slug) do
      case leaf_kind(leaf) do
        {:ok, :page, slug} ->
          with {:ok, page} <- fetch_page(space, slug),
               [] <- Wiki.list_comments(page.id),
               [] <- Wiki.list_attachments(page.id) do
            case Wiki.delete_page(page.id) do
              {:ok, _} -> :ok
              {:error, :not_found} -> {:error, :enoent}
              {:error, _} -> {:error, :eio}
            end
          else
            {:error, _} = error -> error
            _ -> {:error, :enotempty}
          end

        {:ok, kind, slug} when kind in [:comments, :assets] ->
          remove_collection(kind, slug, space)

        _ ->
          # _space.json / reactions.json: not mapped for remove (§2.1).
          {:error, :enosys}
      end
    end
  end

  defp remove_node([space_slug, coll, item], scope) do
    with {:ok, space} <- fetch_space(scope, space_slug),
         {:ok, page, kind} <- coll_kind(coll, space) do
      remove_item(kind, page, item)
    end
  end

  defp remove_node(_, _scope), do: {:error, :enoent}

  # Implicit collection dirs: ENOTEMPTY while entries exist, ENOSYS when empty
  # (there is no node to remove — they exist iff the page exists).
  defp remove_collection(kind, slug, space) do
    with {:ok, page} <- fetch_page(space, slug) do
      nonempty? =
        case kind do
          :comments -> Wiki.list_comments(page.id) != []
          :assets -> Wiki.list_attachments(page.id) != []
        end

      if nonempty?, do: {:error, :enotempty}, else: {:error, :enosys}
    end
  end

  defp remove_item(:comments, page, item) do
    with {:ok, id} <- comment_id(item),
         %Comment{} = comment <- owned_comment(page, id) do
      case Wiki.delete_comment(comment.id) do
        {:ok, _} -> :ok
        {:error, :not_found} -> {:error, :enoent}
        {:error, _} -> {:error, :eio}
      end
    else
      _ -> {:error, :enoent}
    end
  end

  defp remove_item(:assets, page, filename) do
    case find_attachment(page, filename) do
      %Attachment{} = att ->
        case Wiki.delete_attachment(att.id) do
          {:ok, _} -> :ok
          {:error, :not_found} -> {:error, :enoent}
          {:error, _} -> {:error, :eio}
        end

      nil ->
        {:error, :enoent}
    end
  end

  # ── search/3 (page bodies — mcp_fs_search fans out here) ─────────────────

  @impl true
  def search(root, query, ctx) when is_binary(root) and is_binary(query) do
    with {:ok, scope, rest} <- parse(root, ctx) do
      search_node(rest, scope, String.downcase(query))
    end
  end

  defp search_node([_space, leaf], _scope, _needle) when leaf in [@space_meta, @reactions_file],
    do: {:error, :enotdir}

  defp search_node([], scope, needle) do
    matches =
      Enum.flat_map(list_spaces(scope), fn space ->
        pages = Wiki.list_pages(space.id, limit: @listing_limit)

        Enum.flat_map(pages, &page_matches(&1, page_path(scope, space.slug, &1.slug), needle))
      end)

    {:ok, matches, nil}
  end

  defp search_node([space_slug], scope, needle) do
    with {:ok, space} <- fetch_space(scope, space_slug) do
      matches =
        Wiki.list_pages(space.id, limit: @listing_limit)
        |> Enum.flat_map(&page_matches(&1, page_path(scope, space.slug, &1.slug), needle))

      {:ok, matches, nil}
    end
  end

  defp search_node([space_slug, leaf], scope, needle) do
    with {:ok, space} <- fetch_space(scope, space_slug),
         {:ok, :page, slug} <- page_leaf(leaf),
         {:ok, page} <- fetch_page(space, slug) do
      {:ok, page_matches(page, page_path(scope, space.slug, page.slug), needle), nil}
    end
  end

  defp search_node(_, _scope, _needle), do: {:error, :enoent}

  defp page_matches(page, path, needle) do
    (page.content || "")
    |> String.split("\n")
    |> Enum.with_index(1)
    |> Enum.flat_map(fn {line, n} ->
      if String.contains?(String.downcase(line), needle),
        do: [%{path: path, line: n, text: line}],
        else: []
    end)
  end

  # ── path parsing + gates ──────────────────────────────────────────────────

  defp parse(path, ctx) do
    segments = path |> String.trim_trailing("/") |> String.split("/", trim: true)

    # Stable-key segments only: reject traversal and dot segments outright.
    if Enum.any?(segments, &(&1 in [".", ".."])) do
      {:error, :enoent}
    else
      case segments do
        ["tobor", org, @group | rest] ->
          with {:ok, scope} <- resolve_scope(ctx, org) do
            {:ok, scope, rest}
          end

        _ ->
          {:error, :enoent}
      end
    end
  end

  # Org visibility (§1.3: one membership check at {org}) + the wiki group gate
  # + the slug → UUID resolution the domain queries need. All fail closed to
  # :enoent (no existence leak).
  defp resolve_scope(ctx, org) do
    with :ok <- Principal.group_gate(ctx, @group),
         true <- Principal.org_visible?(ctx, org),
         org_id when is_binary(org_id) <- Resolve.organization_id(org) do
      gate = Principal.groups(ctx)[@group]
      {:ok, %{org: org, org_id: org_id, writable: gate.writable}}
    else
      _ -> {:error, :enoent}
    end
  end

  defp require_writable(%{writable: true}), do: :ok
  defp require_writable(_), do: {:error, :eacces}

  # ── node classification ───────────────────────────────────────────────────

  defp leaf_kind(leaf) do
    cond do
      leaf == @space_meta -> {:ok, :space_meta, nil}
      leaf == @reactions_file -> {:ok, :reactions, nil}
      String.ends_with?(leaf, @page_ext) -> page_leaf(leaf)
      String.ends_with?(leaf, @comments_ext) -> coll_leaf(leaf, @comments_ext)
      String.ends_with?(leaf, @assets_ext) -> coll_leaf(leaf, @assets_ext)
      true -> {:ok, :unknown, leaf}
    end
  end

  defp page_leaf(leaf) do
    slug = String.replace_suffix(leaf, @page_ext, "")

    if valid_slug?(slug), do: {:ok, :page, slug}, else: {:ok, :unknown, leaf}
  end

  defp coll_leaf(leaf, ext) do
    slug = String.replace_suffix(leaf, ext, "")

    if valid_slug?(slug), do: {:ok, coll_kind_atom(ext), slug}, else: {:ok, :unknown, leaf}
  end

  defp coll_kind_atom(@comments_ext), do: :comments
  defp coll_kind_atom(@assets_ext), do: :assets

  # A `.comments`/`.assets` node resolves only when its page exists; the page
  # comes back so item ops don't re-fetch it. Total: non-coll leaves are
  # :enoent, never a bare non-error value.
  defp coll_kind(leaf, space) do
    case leaf_kind(leaf) do
      {:ok, kind, slug} when kind in [:comments, :assets] ->
        case fetch_page(space, slug) do
          {:ok, page} -> {:ok, page, kind}
          error -> error
        end

      _ ->
        {:error, :enoent}
    end
  end

  # ── row fetches ───────────────────────────────────────────────────────────

  defp fetch_space(scope, slug) do
    with true <- valid_slug?(slug),
         %{} = space <- Wiki.get_space_by_slug(scope.org_id, slug) do
      {:ok, space}
    else
      _ -> {:error, :enoent}
    end
  end

  defp fetch_page(space, slug) do
    case Wiki.get_page_by_slug(space.id, slug) do
      %{} = page -> {:ok, page}
      nil -> {:error, :enoent}
    end
  end

  defp ensure_absent_space(scope, slug) do
    if Wiki.get_space_by_slug(scope.org_id, slug), do: {:error, :eexist}, else: :ok
  end

  defp ensure_absent_page(space, slug) do
    if Wiki.get_page_by_slug(space.id, slug), do: {:error, :eexist}, else: :ok
  end

  defp ensure_absent_attachment(page, filename) do
    if find_attachment(page, filename), do: {:error, :eexist}, else: :ok
  end

  defp owned_comment(page, id) do
    case Wiki.get_comment(id) do
      %{page_id: page_id} = comment when page_id == page.id -> comment
      _ -> nil
    end
  end

  defp find_attachment(page, filename) do
    Wiki.list_attachments(page.id) |> Enum.find(&(&1.filename == filename))
  end

  defp comment_id(item) do
    case String.replace_suffix(item, ".json", "") do
      id when id == "" or id == item ->
        :error

      id ->
        # Comment ids are UUIDs; a non-uuid filename is simply not a node
        # (and Repo.get with a non-uuid would raise a cast error).
        if match?({:ok, _}, Ecto.UUID.cast(id)), do: {:ok, id}, else: :error
    end
  end

  # ── documents & formats ───────────────────────────────────────────────────

  defp space_meta_size(space), do: byte_size(Jason.encode!(space_doc(space)))

  defp space_doc(space) do
    %{
      "id" => space.id,
      "organization_id" => space.organization_id,
      "project_id" => space.project_id,
      "slug" => space.slug,
      "name" => space.name,
      "description" => space.description,
      "inserted_at" => iso(space.inserted_at),
      "updated_at" => iso(space.updated_at)
    }
  end

  defp comment_doc(comment) do
    %{
      "id" => comment.id,
      "page_id" => comment.page_id,
      "parent_id" => comment.parent_id,
      "author" => comment.author,
      "body" => comment.body,
      "inserted_at" => iso(comment.inserted_at),
      "updated_at" => iso(comment.updated_at)
    }
  end

  defp page_xattrs(page) do
    %{
      "id" => page.id,
      "space_id" => page.space_id,
      "parent_id" => page.parent_id,
      "title" => page.title,
      "position" => page.position
    }
  end

  defp space_xattrs(space), do: %{"id" => space.id, "name" => space.name}

  defp serialize_page(page) do
    parent_ref =
      case page.parent_id && Wiki.get_page(page.parent_id) do
        %{slug: slug} when is_binary(slug) -> slug
        _ -> nil
      end

    front_matter =
      [
        {"id", page.id},
        {"title", page.title},
        {"slug", page.slug},
        {"position", page.position},
        {"parent", parent_ref},
        {"created", iso(page.inserted_at)},
        {"updated", iso(page.updated_at)}
      ]
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Enum.map(fn {k, v} -> "#{k}: #{yaml_scalar(v)}" end)
      |> Enum.join("\n")

    "---\n" <> front_matter <> "\n---\n" <> (page.content || "")
  end

  defp parse_page_file(data) do
    {block, body} = split_front_matter(data)

    case block do
      nil ->
        {:ok, nil, body}

      yaml ->
        case YamlElixir.read_from_string(yaml) do
          {:ok, %{} = fm} -> {:ok, fm, body}
          _ -> {:error, :eio}
        end
    end
  end

  defp split_front_matter(<<"---\n", rest::binary>>) do
    case :binary.split(rest, "\n---\n") do
      [yaml, body] -> {yaml, body}
      _ -> {nil, <<"---\n", rest::binary>>}
    end
  end

  defp split_front_matter(data), do: {nil, data}

  defp derive_title(fm, body, slug) do
    from_fm = fm && string_field(fm["title"])

    cond do
      from_fm -> from_fm
      match?({:ok, _}, first_heading(body)) -> elem(first_heading(body), 1)
      true -> humanize(slug)
    end
  end

  defp first_heading(body) do
    case Regex.run(~r/^#\s+(.+?)\s*$/m, body) do
      [_, title] -> {:ok, String.trim(title)}
      _ -> :error
    end
  end

  defp humanize(slug) do
    slug |> String.split("-") |> Enum.map_join(" ", &String.capitalize/1)
  end

  defp resolve_parent(space, fm) when is_map(fm) do
    ref = fm["parent"]

    parent_id =
      cond do
        not is_binary(ref) or ref == "" ->
          nil

        true ->
          case Wiki.get_page_by_slug(space.id, ref) do
            %{id: id} ->
              id

            nil ->
              # Raw UUID reference — accepted only when the page is in this space.
              case Wiki.get_page(ref) do
                %{space_id: sid, id: id} when sid == space.id -> id
                _ -> nil
              end
          end
      end

    {:ok, parent_id}
  end

  defp resolve_parent(_space, nil), do: {:ok, nil}

  defp put_position(attrs, fm) when is_map(fm), do: put_attr(attrs, :position, position_from(fm))
  defp put_position(attrs, nil), do: attrs

  defp put_parent(attrs, fm, parent_id) when is_map(fm) do
    if Map.has_key?(fm, "parent"), do: Map.put(attrs, :parent_id, parent_id), else: attrs
  end

  defp put_parent(attrs, _fm, _parent_id), do: attrs

  defp position_from(fm) do
    case fm["position"] do
      p when is_integer(p) ->
        p

      p when is_binary(p) ->
        case Integer.parse(p) do
          {n, ""} -> n
          _ -> nil
        end

      _ ->
        nil
    end
  end

  defp string_field(v) when is_binary(v) and v != "", do: v
  defp string_field(_), do: nil

  defp yaml_scalar(v) when is_integer(v), do: Integer.to_string(v)

  defp yaml_scalar(v) when is_binary(v) do
    if String.match?(v, ~r/^[A-Za-z0-9][A-Za-z0-9 \-_.\/()&']*$/), do: v, else: inspect(v)
  end

  defp space_attrs(:dir, slug, scope),
    do: {:ok, %{organization_id: scope.org_id, slug: slug, name: slug}}

  defp space_attrs(data, slug, scope) when is_binary(data) do
    case decode_object(data) do
      {:ok, doc} ->
        {:ok,
         %{
           organization_id: scope.org_id,
           slug: slug,
           name: string_field(doc["name"]) || slug,
           description: string_field(doc["description"]),
           project_id: string_field(doc["project_id"])
         }}

      error ->
        error
    end
  end

  defp space_attrs(_data, _slug, _scope), do: {:error, :eio}

  defp comment_attrs(data, author) do
    case decode_object(data) do
      {:ok, %{"body" => body} = doc} when is_binary(body) and body != "" ->
        {body, string_field(doc["author"]) || author, string_field(doc["parent"])}

      _ ->
        {data, author, nil}
    end
  end

  defp decode_object(data) when is_binary(data) do
    case Jason.decode(data) do
      {:ok, %{} = doc} -> {:ok, doc}
      _ -> {:error, :eio}
    end
  end

  defp text_only(data), do: if(String.valid?(data), do: :ok, else: {:error, :enosys})

  defp attachment_content(att) do
    case att.url do
      "data:" <> rest ->
        case :binary.split(rest, ";base64,") do
          [_, b64] -> Base.decode64!(b64, ignore: :whitespace)
          _ -> att.url || ""
        end

      other ->
        # Externally-hosted attachment (created via Wiki.AttachmentCreate):
        # the URL is the content out-ref (§3.3 metadata-now).
        other || ""
    end
  end

  defp attachment_mime(filename) do
    filename
    |> Path.extname()
    |> String.replace_leading(".", "")
    |> MIME.type()
  end

  defp principal_author(ctx) do
    claims = Principal.view(ctx).claims

    case claims["sub"] || claims["user_id"] do
      sub when is_binary(sub) and sub != "" -> sub
      _ -> "vfs"
    end
  end

  # ── reactions (desired-state sync over ReactionAdd/ReactionRemove) ────────

  defp apply_reactions_doc(space, data) do
    case decode_object(data) do
      {:ok, doc} ->
        pages_doc = Map.get(doc, "page", %{})
        comments_doc = Map.get(doc, "comment", %{})

        if is_map(pages_doc) and is_map(comments_doc) do
          Enum.each(pages_doc, fn {pid, entries} ->
            sync_reactions("page", pid, entries, space)
          end)

          Enum.each(comments_doc, fn {cid, entries} ->
            sync_reactions("comment", cid, entries, space)
          end)

          # Whole-space desired state: a target the document does not mention
          # loses its reactions (the daemon's read→edit→write round trip always
          # re-renders every target, so nothing is lost in normal flows).
          Enum.each(space_targets(space), fn {tt, tid} ->
            mentioned =
              case tt do
                "page" -> Map.has_key?(pages_doc, tid)
                _ -> Map.has_key?(comments_doc, tid)
              end

            unless mentioned do
              Enum.each(Wiki.list_reactions(tt, tid), fn r ->
                Wiki.remove_reaction(tt, tid, r.emoji, r.actor)
              end)
            end
          end)

          :ok
        else
          {:error, :eio}
        end

      error ->
        error
    end
  end

  defp space_targets(space) do
    pages = Wiki.list_pages(space.id, limit: @listing_limit)

    page_targets = Enum.map(pages, &{"page", &1.id})

    comment_targets =
      pages |> Enum.flat_map(&Wiki.list_comments(&1.id)) |> Enum.map(&{"comment", &1.id})

    page_targets ++ comment_targets
  end

  defp sync_reactions(tt, tid, entries, space) do
    if target_in_space?(tt, tid, space) do
      desired = MapSet.new(normalize_entries(entries))
      current = MapSet.new(Wiki.list_reactions(tt, tid), &{&1.emoji, &1.actor})

      desired
      |> MapSet.difference(current)
      |> Enum.each(fn {emoji, actor} ->
        Wiki.add_reaction(%{target_type: tt, target_id: tid, emoji: emoji, actor: actor})
      end)

      current
      |> MapSet.difference(desired)
      |> Enum.each(fn {emoji, actor} -> Wiki.remove_reaction(tt, tid, emoji, actor) end)
    end
  end

  defp normalize_entries(entries) when is_list(entries) do
    Enum.flat_map(entries, fn
      %{"emoji" => e, "actor" => a} when is_binary(e) and is_binary(a) -> [{e, a}]
      _ -> []
    end)
  end

  defp normalize_entries(_), do: []

  defp target_in_space?("page", tid, space) do
    case Wiki.get_page(tid) do
      %{space_id: sid} -> sid == space.id
      _ -> false
    end
  end

  defp target_in_space?("comment", cid, space) do
    case Wiki.get_comment(cid) do
      %{page_id: pid} ->
        case Wiki.get_page(pid) do
          %{space_id: sid} -> sid == space.id
          _ -> false
        end

      _ ->
        false
    end
  end

  defp target_in_space?(_, _, _), do: false

  defp reactions_json(space) do
    pages = Wiki.list_pages(space.id, limit: @listing_limit)

    doc = %{
      "page" => Map.new(pages, fn p -> {p.id, reaction_entries("page", p.id)} end),
      "comment" =>
        pages
        |> Enum.flat_map(&Wiki.list_comments(&1.id))
        |> Map.new(fn c -> {c.id, reaction_entries("comment", c.id)} end)
    }

    Jason.encode!(doc)
  end

  defp reaction_entries(tt, tid) do
    Enum.map(Wiki.list_reactions(tt, tid), &%{"emoji" => &1.emoji, "actor" => &1.actor})
  end

  # ── overview furniture ────────────────────────────────────────────────────

  defp overview_md(scope) do
    """
    # Wiki

    The org wiki as a natural file plane (MCP-VFS-GROUP-MOUNTS.md §2.1):
    spaces are directories, pages are `{page}.md` files, and comments,
    attachments, and reactions mount alongside them.

    - spaces: #{Wiki.count_spaces(scope.org_id)}
    - pages: #{Wiki.count_pages(scope.org_id)}

    Map `/tobor/#{scope.org}/wiki` with mcp-mount and edit pages in any
    editor; VFS-routed writes are live (generation bump + pubsub), web-UI
    edits land within the cache TTL.
    """
  end

  # ── entry/node builders ───────────────────────────────────────────────────

  defp list_spaces(scope),
    do: Wiki.list_spaces(organization_id: scope.org_id, limit: @listing_limit)

  defp page_path(scope, space_slug, page_slug),
    do: "/tobor/#{scope.org}/wiki/#{space_slug}/#{page_slug}.md"

  defp dir_node(writable, xattrs \\ %{}),
    do: %VFS{type: :dir, mtime: now_ms(), version: 1, writable: writable, xattrs: xattrs}

  defp file_node(size, writable, version, xattrs \\ %{}),
    do: %VFS{
      type: :file,
      size: size,
      mtime: now_ms(),
      version: version,
      writable: writable,
      xattrs: xattrs
    }

  defp dir_entry(name, version),
    do: %{name: name, type: :dir, size: 0, mtime: now_ms(), version: version}

  defp file_entry(name, size, version),
    do: %{name: name, type: :file, size: size, mtime: now_ms(), version: version}

  # Row identity: the row's own updated_at (Features.VFS stamps the cache
  # generation on top, so VFS-routed writes still move the wire version).
  defp row_version(%{updated_at: %DateTime{} = dt}), do: DateTime.to_unix(dt, :millisecond)
  defp row_version(_), do: 1

  # Projected documents (reactions.json, overview.md) have no single row to
  # version — a content hash keeps the version stable across unchanged reads.
  defp content_version(bin), do: max(:erlang.phash2(bin), 1)

  defp valid_slug?(slug), do: is_binary(slug) and Regex.match?(@slug_format, slug)

  defp valid_slug(slug), do: if(valid_slug?(slug), do: :ok, else: {:error, :enoent})

  defp iso(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp iso(nil), do: nil

  defp now_ms, do: System.os_time(:millisecond)

  defp put_attr(map, _key, nil), do: map
  defp put_attr(map, key, value), do: Map.put(map, key, value)
end
