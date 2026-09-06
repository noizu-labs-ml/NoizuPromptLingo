defmodule NoizuPromptLingua.MCP.VFS.Github do
  @moduledoc """
  VFS backend for the `github` group (MCP-VFS-GROUP-MOUNTS.md §2.19) — a
  read-mostly mirror over `NoizuPromptLingua.Github.Client` (upstream is
  GitHub; the local tree is a projected cache, liveness ttl-only). Full
  absolute paths, self-enforced §1.3 gates (via `NoizuPromptLingua.MCP.VFS.Scope`).

      /tobor/{org}/github                              → RepoList (readdir, ACL-filtered)
      /tobor/{org}/github/overview.md                  → Overview tool render
      /tobor/{org}/github/{owner}                      → owner grouping dir
      /tobor/{org}/github/{owner}/{repo}               → repo dir
      /tobor/{org}/github/{owner}/{repo}/branches/     → BranchList ({name}.json)
      /tobor/{org}/github/{owner}/{repo}/branches/{name}.json  → BranchGet / BranchCreate
      /tobor/{org}/github/{owner}/{repo}/pulls/        → PullList ({n}.json + {n}.merge)
      /tobor/{org}/github/{owner}/{repo}/pulls/{n}.json        → PullGet / PullCreate
      /tobor/{org}/github/{owner}/{repo}/pulls/{n}.merge       → PullMerge control note
      /tobor/{org}/github/{owner}/{repo}/pulls/{n}.comments/   → list / PullComment
      /tobor/{org}/github/{owner}/{repo}/issues/       → IssueList ({n}.json)
      /tobor/{org}/github/{owner}/{repo}/issues/{n}.json       → IssueGet / IssueCreate
      /tobor/{org}/github/{owner}/{repo}/issues/{n}.comments/  → list / IssueComment

  ## Decisions & conventions

    * **Read-mostly** (§3.1): `stat/list/read` mirror the API; `create/3`
      maps BranchCreate / PullCreate / PullComment / IssueCreate / IssueComment
      (the client may pick any filename — GitHub assigns the real number/id
      and the result is re-readable at its canonical node). `write/3`,
      `remove/2`, and `search/3` fall through to the behaviour's `:enosys`
      defaults — mirror content is never edited in place.
    * **`PullMerge` is never a file write** (§3.5): `pulls/{n}.merge` is a
      `:control` NOTE node whose read documents the only route — the
      confirm-gated `/etc/dev/tools/Github.PullMerge` control write (gated by
      the principal's effective toolset through `Principal.tool_gate/3`).
      Writing the note (or any merge-flavored file op) is `:enosys`.
    * **No existence leak on the repo ladder** (§1.3 posture): an
      unresolvable repo AND a repo the principal cannot read both render as
      `:enoent` (matching the web index's ACL filtering); create-ops on a
      repo the principal can read but not write surface the client's
      `:forbidden` as `:eacces`.
    * **`stat` is syntactic, reads are authoritative**: a well-formed node
      name stats as its node type without an API round-trip (the mirror is a
      projected cache; readdir only lists real rows); the actual fetch — and
      any `:enoent` — happens on read. `create` on `pulls/{n}.json` /
      `issues/{n}.json` for an EXISTING number collides with `:eexist`.
    * **Branch names carry `/`**: a branch like `feat/x` mounts as
      `feat%2Fx.json` (URI-component encoding, `%` → `%25`); resolution
      decodes it back.
    * **Bounded listings** (§3.2): readdir windows are the first upstream
      page (100 entries); deeper history stays on the API surface.
    * **Client error mapping**: `:repo_not_found` / GitHub 404 → `:enoent`;
      `:forbidden` / `:token_not_mapped` / 403 → `:eacces`; 422 → `:eexist`;
      other GitHub statuses and transport failures → `:eio`.
    * **Liveness is ttl-only** (§2.19): no webhook→publish bridge; the lib
      cache's TTL is the coherence bound. The identity-blind `Features.VFS`
      cache caveat (design §0.2/P1) applies to per-repo ACL differences —
      flagged upstream with the `__mcp_vfs__(:cacheable)` ask.
  """

  use Noizu.MCP.VFS

  alias Noizu.MCP.Server.Features.Pagination
  alias Noizu.MCP.VFS
  alias NoizuPromptLingua.Github.Client
  alias NoizuPromptLingua.MCP.Resolve
  alias NoizuPromptLingua.MCP.VFS.{Overview, Scope}

  @group "github"
  @window 100

  @collection_dirs ["branches", "pulls", "issues"]

  # ── stat/2 ────────────────────────────────────────────────────────────────

  @impl true
  def stat(path, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, gate} <- Scope.gate(ctx, org, @group) do
      stat_rest(org, rest, gate, ctx)
    else
      {:error, _} = error -> error
    end
  end

  defp stat_rest(_org, [], _gate, _ctx), do: {:ok, Scope.dir_node()}
  defp stat_rest(_org, ["overview.md"], _gate, _ctx), do: {:ok, Scope.file_node(overview_size())}

  defp stat_rest(org, [owner], gate, ctx) do
    if owner in owner_names!(ctx, org), do: {:ok, gated_dir(gate)}, else: {:error, :enoent}
  end

  defp stat_rest(org, [owner, repo], gate, ctx) do
    if repo_visible?(ctx, org, owner <> "/" <> repo),
      do: {:ok, gated_dir(gate)},
      else: {:error, :enoent}
  end

  defp stat_rest(org, [owner, repo, kind], _gate, ctx) when kind in @collection_dirs do
    if repo_visible?(ctx, org, owner <> "/" <> repo),
      do: {:ok, Scope.dir_node()},
      else: {:error, :enoent}
  end

  # Syntactic stat: a well-formed mirror node name stats without an API call
  # (reads are the authoritative fetch).
  defp stat_rest(org, [owner, repo, kind, filename], _gate, ctx)
       when kind in @collection_dirs do
    if repo_visible?(ctx, org, owner <> "/" <> repo) do
      case node_shape(kind, filename) do
        :control -> {:ok, merge_node()}
        :comments_dir -> {:ok, Scope.dir_node()}
        :file -> {:ok, Scope.file_node(0)}
        _ -> {:error, :enoent}
      end
    else
      {:error, :enoent}
    end
  end

  defp stat_rest(_org, _rest, _gate, _ctx), do: {:error, :enoent}

  # ── list/3 ────────────────────────────────────────────────────────────────

  @impl true
  def list(path, cursor, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, _gate} <- Scope.gate(ctx, org, @group) do
      list_rest(org, rest, cursor, ctx)
    else
      {:error, _} = error -> error
    end
  end

  # RepoList (§2.19) — org-linked repos, ACL-filtered, grouped by owner.
  defp list_rest(org, [], cursor, ctx) do
    with {:ok, names} <- owner_names(ctx, org) do
      paginate([Scope.file_entry("overview.md") | Enum.map(names, &Scope.dir_entry/1)], cursor)
    else
      {:error, _} = error -> error
    end
  end

  defp list_rest(org, [owner], cursor, ctx) do
    with {:ok, user_id, org_id} <- principal_and_org(ctx, org),
         {:ok, %{repos: repos}} <- Client.list_repos(user_id, org_id) do
      names =
        repos
        |> Enum.map(&field(&1, "repo_full_name"))
        |> Enum.filter(&is_binary/1)
        |> Enum.filter(&(repo_owner(&1) == owner))
        |> Enum.map(&repo_name/1)
        |> Enum.sort()

      paginate(Enum.map(names, &Scope.dir_entry/1), cursor)
    else
      {:error, _} = error -> error
    end
  end

  defp list_rest(org, [owner, repo], cursor, ctx) do
    if repo_visible?(ctx, org, owner <> "/" <> repo) do
      paginate(Enum.map(@collection_dirs, &Scope.dir_entry/1), cursor)
    else
      {:error, :enoent}
    end
  end

  # BranchList / PullList / IssueList — bounded first-page windows; pulls
  # also list their `{n}.merge` control notes (§3.5).
  defp list_rest(org, [owner, repo, kind], cursor, ctx) when kind in @collection_dirs do
    with {:ok, user_id, org_id, ref} <- resolve_repo(ctx, org, owner, repo),
         {:ok, items} <- list_kind(user_id, org_id, ref, kind) do
      entries =
        case kind do
          "branches" ->
            items
            |> Enum.map(&field(&1, "name"))
            |> Enum.filter(&is_binary/1)
            |> Enum.sort()
            |> Enum.map(&Scope.file_entry(node_name(&1) <> ".json"))

          "pulls" ->
            items
            |> Enum.sort_by(&number_of/1)
            |> Enum.flat_map(fn p ->
              n = to_string(field(p, "number"))
              [Scope.file_entry(n <> ".json"), control_entry(n <> ".merge")]
            end)

          "issues" ->
            items
            |> Enum.sort_by(&number_of/1)
            |> Enum.map(&Scope.file_entry(to_string(field(&1, "number")) <> ".json"))
        end

      paginate(entries, cursor)
    else
      {:error, _} = error -> error
    end
  end

  # PullComment / IssueComment listings — `{id}.json` entries.
  defp list_rest(org, [owner, repo, kind, name], cursor, ctx) do
    case node_shape(kind, name) do
      shape when shape in [:file, :control] ->
        {:error, :enotdir}

      _ ->
        with {:ok, n} <- comments_dir(name),
             {:ok, user_id, org_id, ref} <- resolve_repo(ctx, org, owner, repo),
             {:ok, items} <- list_comments(user_id, org_id, ref, kind, n) do
          entries =
            items
            |> Enum.sort_by(&((&1 && field(&1, "id")) || 0))
            |> Enum.map(&Scope.file_entry(to_string(field(&1, "id")) <> ".json"))

          paginate(entries, cursor)
        else
          {:error, _} = error -> error
        end
    end
  end

  defp list_rest(_org, ["overview.md"], _cursor, _ctx), do: {:error, :enotdir}
  defp list_rest(_org, _rest, _cursor, _ctx), do: {:error, :enotdir}

  # ── read/2 ────────────────────────────────────────────────────────────────

  @impl true
  def read(path, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, _gate} <- Scope.gate(ctx, org, @group) do
      read_rest(org, rest, ctx)
    else
      {:error, _} = error -> error
    end
  end

  defp read_rest(_org, [], _ctx), do: {:error, :eisdir}

  defp read_rest(_org, ["overview.md"], _ctx) do
    {:ok, Overview.md(overview_tool(), @group), Scope.version()}
  end

  defp read_rest(_org, [_owner], _ctx), do: {:error, :eisdir}
  defp read_rest(_org, [_owner, _repo], _ctx), do: {:error, :eisdir}

  defp read_rest(org, [owner, repo, kind], ctx) when kind in @collection_dirs do
    if repo_visible?(ctx, org, owner <> "/" <> repo),
      do: {:error, :eisdir},
      else: {:error, :enoent}
  end

  defp read_rest(org, [owner, repo, "branches", filename], ctx) do
    with {:ok, name} <- parse_name(filename),
         {:ok, user_id, org_id, ref} <- resolve_repo(ctx, org, owner, repo),
         {:ok, branch} <- errno(Client.get_branch(user_id, org_id, ref, name)) do
      {:ok, Jason.encode!(branch), Scope.version()}
    else
      {:error, _} = error -> error
    end
  end

  defp read_rest(org, [owner, repo, "pulls", filename], ctx) do
    if match?({:ok, _}, parse_number(filename, ".merge")) do
      read_merge_note(ctx, org, owner, repo, filename)
    else
      with {:ok, n} <- parse_number(filename, ".json"),
           {:ok, user_id, org_id, ref} <- resolve_repo(ctx, org, owner, repo),
           {:ok, pull} <- errno(Client.get_pull(user_id, org_id, ref, n)) do
        {:ok, Jason.encode!(pull), Scope.version()}
      else
        {:error, _} = error -> error
      end
    end
  end

  defp read_rest(org, [owner, repo, "issues", filename], ctx) do
    with {:ok, n} <- parse_number(filename, ".json"),
         {:ok, user_id, org_id, ref} <- resolve_repo(ctx, org, owner, repo),
         {:ok, issue} <- errno(Client.get_issue(user_id, org_id, ref, n)) do
      {:ok, Jason.encode!(issue), Scope.version()}
    else
      {:error, _} = error -> error
    end
  end

  # Comments read back out of their listing (no single-comment GET in the
  # client surface; ids are stable upstream).
  defp read_rest(org, [owner, repo, kind, name, filename], ctx) do
    with {:ok, n} <- comments_dir(name),
         {:ok, id} <- parse_number(filename, ".json"),
         {:ok, user_id, org_id, ref} <- resolve_repo(ctx, org, owner, repo),
         {:ok, items} <- list_comments(user_id, org_id, ref, kind, n),
         {:ok, comment} <- fetch_comment(items, id) do
      {:ok, Jason.encode!(comment), Scope.version()}
    else
      {:error, _} = error -> error
    end
  end

  defp read_rest(_org, _rest, _ctx), do: {:error, :enoent}

  # The PullMerge control note (§3.5) — documents the confirm-gated /etc/dev
  # route; there is no file-write path to a merge.
  defp read_merge_note(ctx, org, owner, repo, filename) do
    with {:ok, n} <- parse_number(filename, ".merge"),
         true <- repo_visible?(ctx, org, owner <> "/" <> repo) do
      {:ok, merge_note(n), Scope.version()}
    else
      {:error, _} = error -> error
    end
  end

  # ── create/3 — BranchCreate / PullCreate / IssueCreate / comments ─────────

  @impl true
  def create(path, data, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, gate} <- Scope.gate(ctx, org, @group),
         :ok <- Scope.require_writable(gate),
         true <- is_binary(data),
         {:ok, body} <- decode_body(data) do
      create_rest(org, rest, body, ctx)
    else
      {:error, _} = error -> error
      # Non-binary data (:dir or garbage) — nothing upstream is creatable.
      _ -> {:error, :enosys}
    end
  end

  # BranchCreate — `{"sha": ...}` (or `from_sha`) names an existing commit.
  defp create_rest(org, [owner, repo, "branches", filename], body, ctx) do
    with {:ok, name} <- parse_name(filename),
         {:ok, sha} <- body_sha(body),
         {:ok, user_id, org_id, ref} <- resolve_repo(ctx, org, owner, repo, :write) do
      case errno(Client.create_branch(user_id, org_id, ref, name, sha)) do
        {:ok, result} -> {:ok, created_file(Jason.encode!(result))}
        {:error, _} = error -> error
      end
    else
      {:error, _} = error -> error
    end
  end

  # PullCreate — any filename under `pulls/`; GitHub assigns the number. An
  # EXISTING `pulls/{n}.json` collides instead of shadowing the mirror.
  defp create_rest(org, [owner, repo, "pulls", filename], body, ctx) do
    with {:ok, _} <- body_fields(body, ["title", "head", "base"]),
         {:ok, user_id, org_id, ref} <- resolve_repo(ctx, org, owner, repo, :write),
         :ok <- slot_free(:pull, user_id, org_id, ref, filename) do
      case errno(Client.create_pull(user_id, org_id, ref, body)) do
        {:ok, result} -> {:ok, created_file(Jason.encode!(result))}
        {:error, _} = error -> error
      end
    else
      {:error, _} = error -> error
    end
  end

  # IssueCreate — mirror pattern as pulls (`{"title": ...}` required).
  defp create_rest(org, [owner, repo, "issues", filename], body, ctx) do
    with {:ok, _} <- body_fields(body, ["title"]),
         {:ok, user_id, org_id, ref} <- resolve_repo(ctx, org, owner, repo, :write),
         :ok <- slot_free(:issue, user_id, org_id, ref, filename) do
      case errno(Client.create_issue(user_id, org_id, ref, body)) do
        {:ok, result} -> {:ok, created_file(Jason.encode!(result))}
        {:error, _} = error -> error
      end
    else
      {:error, _} = error -> error
    end
  end

  # PullComment / IssueComment — `{"body": ...}` at any `{ts}.json` under the
  # comment dir; the created comment reads back at `{id}.json`.
  defp create_rest(org, [owner, repo, kind, name, _filename], body, ctx)
       when kind in @collection_dirs do
    with {:ok, n} <- comments_dir(name),
         {:ok, text} <- comment_text(body),
         {:ok, user_id, org_id, ref} <- resolve_repo(ctx, org, owner, repo, :write) do
      case errno(comment(user_id, org_id, ref, kind, n, text)) do
        {:ok, result} -> {:ok, created_file(Jason.encode!(result))}
        {:error, _} = error -> error
      end
    else
      {:error, _} = error -> error
    end
  end

  defp create_rest(_org, _rest, _body, _ctx), do: {:error, :enosys}

  # ── shared resolution helpers ─────────────────────────────────────────────

  defp principal_and_org(ctx, org) do
    with {:ok, user_id} <- principal(ctx),
         {:ok, org_id} <- org_id(org) do
      {:ok, user_id, org_id}
    end
  end

  defp principal(ctx) do
    case Resolve.current_user_id(ctx) do
      nil -> {:error, :eacces}
      user_id -> {:ok, user_id}
    end
  end

  defp org_id(org) do
    case Resolve.organization_id(org) do
      nil -> {:error, :enoent}
      org_id -> {:ok, org_id}
    end
  end

  defp owner_names(ctx, org) do
    with {:ok, user_id, org_id} <- principal_and_org(ctx, org),
         {:ok, %{repos: repos}} <- Client.list_repos(user_id, org_id) do
      {:ok,
       repos
       |> Enum.map(&field(&1, "repo_full_name"))
       |> Enum.filter(&is_binary/1)
       |> Enum.map(&repo_owner/1)
       |> Enum.uniq()
       |> Enum.sort()}
    end
  end

  defp owner_names!(ctx, org) do
    case owner_names(ctx, org) do
      {:ok, names} -> names
      _ -> []
    end
  end

  defp repo_visible?(ctx, org, full_name) do
    case resolve_repo(ctx, org, owner_part(full_name), name_part(full_name)) do
      {:ok, _, _, _} -> true
      _ -> false
    end
  end

  defp resolve_repo(ctx, org, owner, repo, acl \\ :read) do
    full_name = owner <> "/" <> repo

    with {:ok, user_id} <- principal(ctx),
         {:ok, org_id} <- org_id(org),
         repo_row when not is_nil(repo_row) <-
           NoizuPromptLingua.Github.get_repo(org_id, full_name),
         :ok <- repo_acl(user_id, repo_row, acl) do
      {:ok, user_id, org_id, full_name}
    else
      {:error, _} = error -> error
      _ -> {:error, :enoent}
    end
  end

  # Reads hide unreadable repos (`:enoent` — the web index filters them the
  # same way); create-ops distinguish read-but-not-write as `:eacces`.
  defp repo_acl(user_id, repo_row, :read) do
    if NoizuPromptLingua.Github.can_access?(user_id, repo_row, :read),
      do: :ok,
      else: {:error, :enoent}
  end

  defp repo_acl(user_id, repo_row, :write) do
    if NoizuPromptLingua.Github.can_access?(user_id, repo_row, :write),
      do: :ok,
      else: {:error, :eacces}
  end

  # ── listing + comment fetch ───────────────────────────────────────────────

  # Client error → errno mapping (see moduledoc). Known VFS errnos pass
  # through untouched.
  defp errno({:error, reason} = error) when reason in [:enoent, :eacces, :eexist, :eio],
    do: error

  defp errno({:error, :repo_not_found}), do: {:error, :enoent}

  defp errno({:error, reason}) when reason in [:forbidden, :token_not_mapped],
    do: {:error, :eacces}

  defp errno({:error, {:github, 404, _}}), do: {:error, :enoent}
  defp errno({:error, {:github, 403, _}}), do: {:error, :eacces}
  defp errno({:error, {:github, 422, _}}), do: {:error, :eexist}
  defp errno({:error, {:github, _, _}}), do: {:error, :eio}
  defp errno({:error, _}), do: {:error, :eio}
  defp errno({:ok, _} = ok), do: ok

  defp list_kind(user_id, org_id, ref, "branches") do
    Client.list_branches(user_id, org_id, ref, per_page: @window) |> items()
  end

  defp list_kind(user_id, org_id, ref, "pulls") do
    Client.list_pulls(user_id, org_id, ref, per_page: @window) |> items()
  end

  defp list_kind(user_id, org_id, ref, "issues") do
    Client.list_issues(user_id, org_id, ref, per_page: @window) |> items()
  end

  # PR conversation comments and issue comments share the issues-comments API.
  defp list_comments(user_id, org_id, ref, _kind, n) do
    Client.list_pull_comments(user_id, org_id, ref, n, per_page: @window) |> items()
  end

  defp items({:ok, %{items: items}}) when is_list(items), do: {:ok, items}
  defp items({:ok, items}) when is_list(items), do: {:ok, items}
  defp items({:error, _} = error), do: errno(error)
  defp items(_), do: {:error, :eio}

  defp fetch_comment(items, id) do
    case Enum.find(items, &(field(&1, "id") == id)) do
      nil -> {:error, :enoent}
      comment -> {:ok, comment}
    end
  end

  # The dep decodes upstream JSON with `keys: :atoms` and the client flattens
  # structs preserving key type — mirror rows may carry string OR atom keys.
  defp field(item, key) when is_map(item) do
    case Map.get(item, key) do
      nil -> Map.get(item, String.to_existing_atom(key))
      value -> value
    end
  end

  defp field(_item, _key), do: nil

  defp number_of(item), do: field(item, "number") || 0

  defp comment(user_id, org_id, ref, "pulls", n, text) do
    Client.comment_pull(user_id, org_id, ref, n, text)
  end

  defp comment(user_id, org_id, ref, "issues", n, text) do
    Client.comment_issue(user_id, org_id, ref, n, text)
  end

  defp comment(_user_id, _org_id, _ref, _kind, _n, _text), do: {:error, :enosys}

  # ── node-name shapes ──────────────────────────────────────────────────────

  defp node_shape(kind, filename) do
    cond do
      kind == "pulls" and match?({:ok, _}, parse_number(filename, ".merge")) -> :control
      match?({:ok, _}, comments_dir(filename)) -> :comments_dir
      parseable_node?(kind, filename) -> :file
      true -> :none
    end
  end

  defp parseable_node?("branches", filename), do: match?({:ok, _}, parse_name(filename))
  defp parseable_node?(_kind, filename), do: match?({:ok, _}, parse_number(filename, ".json"))

  # `pulls/{n}.comments/` is the comment dir under both pulls and issues.
  defp comments_dir(filename), do: parse_number(filename, ".comments")

  # `feat/x` → `feat%2Fx` (`%` → `%25`): flat node names for slashy branches.
  defp node_name(raw), do: URI.encode(raw, &(&1 not in [?/, ?%]))

  defp parse_name(filename) do
    case split_suffix(filename, ".json") do
      {:ok, prefix} when prefix != "" -> {:ok, URI.decode(prefix)}
      _ -> {:error, :enoent}
    end
  end

  defp parse_number(filename, suffix) do
    with {:ok, prefix} <- split_suffix(filename, suffix),
         {n, ""} <- Integer.parse(prefix) do
      {:ok, n}
    else
      _ -> {:error, :enoent}
    end
  end

  defp split_suffix(filename, suffix) do
    if String.ends_with?(filename, suffix) and filename != suffix do
      {:ok, String.slice(filename, 0, byte_size(filename) - byte_size(suffix))}
    else
      {:error, :enoent}
    end
  end

  # ── create guards + builders ──────────────────────────────────────────────

  defp decode_body(data) do
    case Jason.decode(data) do
      {:ok, %{} = body} -> {:ok, body}
      _ -> {:error, :eio}
    end
  end

  defp body_sha(%{"sha" => sha}) when is_binary(sha), do: {:ok, sha}
  defp body_sha(%{"from_sha" => sha}) when is_binary(sha), do: {:ok, sha}
  defp body_sha(_), do: {:error, :eio}

  defp comment_text(%{"body" => text}) when is_binary(text) and text != "", do: {:ok, text}
  defp comment_text(_), do: {:error, :eio}

  defp body_fields(body, required) do
    if Enum.all?(required, &(is_binary(body[&1]) and body[&1] != "")),
      do: {:ok, Map.take(body, required)},
      else: {:error, :eio}
  end

  defp slot_free(kind, user_id, org_id, ref, filename) do
    with {:ok, n} <- parse_number(filename, ".json") do
      exists? =
        case kind do
          :pull -> match?({:ok, _}, Client.get_pull(user_id, org_id, ref, n))
          :issue -> match?({:ok, _}, Client.get_issue(user_id, org_id, ref, n))
        end

      if exists?, do: {:error, :eexist}, else: :ok
    else
      _ -> :ok
    end
  end

  defp created_file(json) do
    %{
      Scope.file_node(byte_size(json))
      | writable: true,
        xattrs: %{
          "mirror" => "created",
          "note" => "re-read the canonical node for the assigned number/id"
        }
    }
  end

  # ── the PullMerge control note (§3.5) ─────────────────────────────────────

  defp merge_node do
    %VFS{
      type: :control,
      size: byte_size(merge_note(0)),
      mtime: Scope.now_ms(),
      version: Scope.version(),
      writable: false,
      xattrs: %{"control" => "pull-merge", "gate" => "tool_gate", "file_write" => "never"}
    }
  end

  defp merge_note(n) do
    Jason.encode!(%{
      "op" => "Github.PullMerge",
      "pull" => n,
      "file_write" =>
        "never — state transitions ride control writes, never content edits " <>
          "(MCP-VFS-GROUP-MOUNTS.md §3.5)",
      "route" => "/etc/dev/tools/Github.PullMerge",
      "gate" =>
        "confirm-gated: the /etc/dev control write passes Principal.tool_gate/3 — the " <>
          "principal's effective toolset must include Github.PullMerge",
      "usage" =>
        "write {\"args\": {\"caller_user_id\": ..., \"organization\": ..., \"repo\": ..., " <>
          "\"pull_number\": ..., \"merge_method\": \"merge|squash|rebase\"}} to the /etc/dev " <>
          "node, or invoke the tool on the MCP surface"
    })
  end

  # ── misc ──────────────────────────────────────────────────────────────────

  defp overview_tool, do: NoizuPromptLingua.Domains.Github.Tools.Overview

  defp overview_size, do: byte_size(Overview.md(overview_tool(), @group))

  defp repo_owner(full_name) do
    case String.split(full_name, "/", parts: 2) do
      [owner, _] -> owner
      _ -> full_name
    end
  end

  defp repo_name(full_name) do
    case String.split(full_name, "/", parts: 2) do
      [_, name] -> name
      _ -> full_name
    end
  end

  defp owner_part(full_name), do: repo_owner(full_name)
  defp name_part(full_name), do: repo_name(full_name)

  defp gated_dir(gate), do: %{Scope.dir_node() | writable: gate.writable}

  defp control_entry(name),
    do: %{name: name, type: :control, size: 0, mtime: Scope.now_ms(), version: Scope.version()}

  # Lib `Features.Pagination` opaque offset cursors (the Wave 1 convention).
  defp paginate(items, cursor) do
    cursor = if cursor == "", do: nil, else: cursor

    case Pagination.paginate(items, cursor) do
      {:ok, page, next} -> {:ok, page, next}
      {:error, _} -> {:error, Noizu.MCP.Error.invalid_params("invalid cursor")}
    end
  end
end
