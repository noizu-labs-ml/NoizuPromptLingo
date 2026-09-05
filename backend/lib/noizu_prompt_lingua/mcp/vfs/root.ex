defmodule NoizuPromptLingua.MCP.VFS.Root do
  @moduledoc """
  The real VFS backend behind NPL's composed Router (Wave 0 substrate).

  Namespace (MCP-VFS-GROUP-MOUNTS.md §1.1/§3.6) — read-only over the meta
  plane; per-group subtrees are documented insertion points that raise
  `:enoent` until their Wave 1+ backends land:

      /                       → "etc" (lib control tree) + "tobor"
      /tobor                  → one dir per org visible to the principal
      /tobor/{org}/_meta      → whoami.json · toolsets.json · groups/
      /tobor/{org}/_meta/groups/{group}.json   ← catalog descriptor + gate state
      /tobor/{org}/{group}/overview.md         ← per-group Overview placeholder

  ## Gating (§1.3)

  Every op resolves the connection principal via
  `NoizuPromptLingua.MCP.VFS.Principal`:

    * `/tobor` readdir = orgs visible to the principal (TRP key scope);
    * a non-visible org's entire subtree is `:enoent` (no existence leak);
    * an excluded-or-hidden group's subtree is `:enoent`; an included but
      disabled group still lists `overview.md`, rendered `writable: false`;
    * `_meta` is always served to an org-visible principal — it IS the
      per-principal discovery plane (`whoami`, effective toolset, gates).

  ## Read-only meta plane, Wave 1 group dispatch

  The meta plane itself stays read-only (`_meta` writes are `:enosys`). Group
  subtrees whose backend has landed (`@group_backends`) delegate every op —
  including their mutators — to that backend (design §1.2 prefix dispatch);
  unregistered groups keep the Wave 0 placeholder surface and `:enosys`
  mutations. (The composed Router advertises `vfs_write` on the wire either
  way — the lib derives capability flags from the composed `Control` module,
  whose `/etc/dev` plane is genuinely writable unless the server opts into
  `vfs_readonly`.)
  """

  use Noizu.MCP.VFS

  alias Noizu.MCP.VFS
  alias NoizuPromptLingua.MCP.EffectiveToolset
  alias NoizuPromptLingua.MCP.VFS.Principal
  alias NoizuPromptLingua.MCPServers

  @orgs_root "tobor"
  @meta "_meta"
  @groups_dir "groups"
  @npl_plane "_npl"

  @meta_files ["whoami.json", "toolsets.json"]

  # Wave 1 prefix dispatch (design §1.2): per-group subtrees whose backend has
  # landed delegate verbatim to that backend (full absolute paths; the backend
  # enforces its own §1.3 gates). Unregistered groups keep the Wave 0
  # placeholder surface. Group backends register here — one map entry each,
  # the documented insertion point.
  @group_backends %{
    "wiki" => NoizuPromptLingua.MCP.VFS.Wiki
    "artifacts" => NoizuPromptLingua.MCP.VFS.Artifacts,
    "campaigns" => NoizuPromptLingua.MCP.VFS.Campaigns,
    "chat" => NoizuPromptLingua.MCP.VFS.Chat,
    "customers" => NoizuPromptLingua.MCP.VFS.Customers,
    "instructions" => NoizuPromptLingua.MCP.VFS.Instructions,
    "market" => NoizuPromptLingua.MCP.VFS.Market,
    "memory" => NoizuPromptLingua.MCP.VFS.Memory,
    "notifications" => NoizuPromptLingua.MCP.VFS.Notifications,
    "pubsub" => NoizuPromptLingua.MCP.VFS.PubSub,
    "review" => NoizuPromptLingua.MCP.VFS.Review,
    "sessions" => NoizuPromptLingua.MCP.VFS.Sessions,
    "tickets" => NoizuPromptLingua.MCP.VFS.Tickets,
    "unicode" => NoizuPromptLingua.MCP.VFS.Unicode
  }

  defp group_backend(group), do: Map.get(@group_backends, group)
  defp dispatch(backend, op, args), do: apply(backend, op, args)
  defp vpath(segments), do: "/" <> Enum.join(segments, "/")

  # ── path model ────────────────────────────────────────────────────────────

  defp normalize("/" <> rest), do: String.trim_trailing(rest, "/")
  defp normalize(path) when is_binary(path), do: String.trim_trailing(path, "/")

  # Stable-key segments only: reject traversal and dot segments outright.
  defp split_segments(path) do
    segments = String.split(normalize(path), "/", trim: true)

    if Enum.any?(segments, &(&1 in [".", ".."])),
      do: {:error, :enoent},
      else: {:ok, segments}
  end

  # ── stat/2 ────────────────────────────────────────────────────────────────

  @impl true
  def stat(path, ctx) do
    with {:ok, segments} <- split_segments(path) do
      stat_segments(segments, ctx)
    end
  end

  defp stat_segments([], _ctx), do: {:ok, dir_node()}

  defp stat_segments([@orgs_root], _ctx), do: {:ok, dir_node()}

  # `_npl` root plane (§2.23): global reference, outside every org. Must sit
  # above the `{org}` clause — `_npl` is not an org slug.
  defp stat_segments([@orgs_root, @npl_plane | rest], ctx) do
    dispatch(NoizuPromptLingua.MCP.VFS.NPL, :stat, [vpath([@orgs_root, @npl_plane | rest]), ctx])
  end

  defp stat_segments([@orgs_root, org], ctx),
    do: if(Principal.org_visible?(ctx, org), do: {:ok, dir_node()}, else: {:error, :enoent})

  defp stat_segments([@orgs_root, org, @meta], ctx),
    do: require_org(ctx, org, fn -> {:ok, dir_node()} end)

  defp stat_segments([@orgs_root, org, @meta, file], ctx) when file in @meta_files,
    do: require_org(ctx, org, fn -> {:ok, file_node(whoami_size(file, ctx))} end)

  defp stat_segments([@orgs_root, org, @meta, @groups_dir], ctx),
    do: require_org(ctx, org, fn -> {:ok, dir_node()} end)

  defp stat_segments([@orgs_root, org, @meta, @groups_dir, descriptor], ctx) do
    require_org(ctx, org, fn ->
      with {:ok, group_id} <- normalize_descriptor(descriptor),
           :ok <- Principal.group_gate(ctx, group_id) do
        {:ok, file_node(byte_size(Jason.encode!(group_descriptor(ctx, group_id))))}
      end
    end)
  end

  # Per-group subtree: registered backends take the whole prefix; everything
  # else keeps the Wave 0 Overview placeholder.
  defp stat_segments([@orgs_root, org, group | rest], ctx) when group != @meta do
    case group_backend(group) do
      nil ->
        placeholder_stat(org, group, rest, ctx)

      backend ->
        dispatch(backend, :stat, [vpath([@orgs_root, org, group | rest]), ctx])
    end
  end

  defp stat_segments([@orgs_root, _org, _group, _deeper | _], _ctx), do: {:error, :enoent}
  defp stat_segments(_, _ctx), do: {:error, :enoent}

  # Wave 0 placeholder surface for groups whose backend has not landed.
  defp placeholder_stat(org, group, [], ctx) do
    require_org_and_group(ctx, org, group, fn gate ->
      {:ok, dir_node()}
      |> tap_writable(gate)
    end)
  end

  defp placeholder_stat(org, group, ["overview.md"], ctx) do
    require_org_and_group(ctx, org, group, fn gate ->
      {:ok, %{file_node(byte_size(overview_md(group))) | writable: gate.writable}}
    end)
  end

  defp placeholder_stat(_org, _group, _rest, _ctx), do: {:error, :enoent}

  # ── list/3 ────────────────────────────────────────────────────────────────

  @impl true
  def list(path, cursor, ctx) do
    with {:ok, segments} <- split_segments(path) do
      list_segments(segments, cursor, ctx)
    end
  end

  # Bounded (meta/org) listings: a cursor can only be a stale or foreign
  # continuation — reject it rather than mis-paginate. Registered group
  # backends and `_npl` manage their own cursor policy.

  defp list_segments([], cursor, _ctx), do: bounded({:ok, [dir_entry(@orgs_root)]}, cursor)

  defp list_segments([@orgs_root], cursor, ctx) do
    bounded(
      {:ok, [dir_entry(@npl_plane) | Enum.map(Principal.view(ctx).orgs, &dir_entry/1)]},
      cursor
    )
  end

  # `_npl` root plane (§2.23) — above the `{org}` clause (`_npl` is not an org).
  defp list_segments([@orgs_root, @npl_plane | rest], cursor, ctx) do
    dispatch(NoizuPromptLingua.MCP.VFS.NPL, :list, [
      vpath([@orgs_root, @npl_plane | rest]),
      cursor,
      ctx
    ])
  end

  defp list_segments([@orgs_root, org], cursor, ctx) do
    require_org(ctx, org, fn ->
      gates = Principal.groups(ctx)

      meta = dir_entry(@meta)

      group_dirs =
        gates
        |> Enum.filter(fn {_gid, gate} -> gate.visible end)
        |> Enum.map(fn {gid, _} -> dir_entry(gid) end)
        |> Enum.sort_by(& &1.name)

      bounded({:ok, [meta | group_dirs]}, cursor)
    end)
  end

  defp list_segments([@orgs_root, org, @meta], cursor, ctx) do
    require_org(ctx, org, fn ->
      bounded({:ok, file_entries(@meta_files) ++ [dir_entry(@groups_dir)]}, cursor)
    end)
  end

  defp list_segments([@orgs_root, org, @meta, @groups_dir], cursor, ctx) do
    require_org(ctx, org, fn ->
      gates = Principal.groups(ctx)

      entries =
        gates
        |> Enum.filter(fn {_gid, gate} -> gate.included end)
        |> Enum.map(fn {gid, _} -> file_entry(gid <> ".json") end)
        |> Enum.sort_by(& &1.name)

      bounded({:ok, entries}, cursor)
    end)
  end

  defp list_segments([@orgs_root, org, group | rest], cursor, ctx) when group != @meta do
    case group_backend(group) do
      nil ->
        placeholder_list(org, group, rest, cursor, ctx)

      backend ->
        dispatch(backend, :list, [vpath([@orgs_root, org, group | rest]), cursor, ctx])
    end
  end

  defp list_segments([@orgs_root, _org, @meta, file], _cursor, _ctx) when file in @meta_files,
    do: {:error, :enotdir}

  defp list_segments([@orgs_root, _org, @meta, @groups_dir, _descriptor], _cursor, _ctx),
    do: {:error, :enotdir}

  defp list_segments(_, _cursor, _ctx), do: {:error, :enoent}

  defp placeholder_list(org, group, [], _cursor, ctx) do
    require_org_and_group(ctx, org, group, fn _gate ->
      bounded({:ok, [file_entry("overview.md")]}, nil)
    end)
  end

  defp placeholder_list(_org, _group, ["overview.md"], _cursor, _ctx), do: {:error, :enotdir}
  defp placeholder_list(_org, _group, _rest, _cursor, _ctx), do: {:error, :enoent}

  defp bounded(result, cursor)
  defp bounded({:ok, entries}, nil), do: {:ok, entries, nil}
  defp bounded({:ok, entries}, ""), do: {:ok, entries, nil}

  defp bounded({:ok, _entries}, _cursor),
    do: {:error, Noizu.MCP.Error.invalid_params("invalid cursor")}

  # ── read/2 ────────────────────────────────────────────────────────────────

  @impl true
  def read(path, ctx) do
    with {:ok, segments} <- split_segments(path) do
      read_segments(segments, ctx)
    end
  end

  defp read_segments([@orgs_root, org, @meta, "whoami.json"], ctx) do
    require_org(ctx, org, fn -> {:ok, Jason.encode!(whoami(ctx)), version()} end)
  end

  defp read_segments([@orgs_root, org, @meta, "toolsets.json"], ctx) do
    require_org(ctx, org, fn -> {:ok, Jason.encode!(toolsets(ctx)), version()} end)
  end

  defp read_segments([@orgs_root, org, @meta, @groups_dir, descriptor], ctx) do
    require_org(ctx, org, fn ->
      with {:ok, group_id} <- normalize_descriptor(descriptor),
           :ok <- Principal.group_gate(ctx, group_id) do
        {:ok, Jason.encode!(group_descriptor(ctx, group_id)), version()}
      end
    end)
  end

  defp read_segments([@orgs_root, @npl_plane | rest], ctx) do
    dispatch(NoizuPromptLingua.MCP.VFS.NPL, :read, [vpath([@orgs_root, @npl_plane | rest]), ctx])
  end

  defp read_segments([@orgs_root, org, group | rest], ctx) when group != @meta do
    case group_backend(group) do
      nil ->
        placeholder_read(org, group, rest, ctx)

      backend ->
        dispatch(backend, :read, [vpath([@orgs_root, org, group | rest]), ctx])
    end
  end

  defp read_segments([@orgs_root, _org, @meta], _ctx), do: {:error, :eisdir}
  defp read_segments(_, _ctx), do: {:error, :enoent}

  defp placeholder_read(org, group, ["overview.md"], ctx) do
    require_org_and_group(ctx, org, group, fn _gate -> {:ok, overview_md(group), version()} end)
  end

  defp placeholder_read(_org, _group, _rest, _ctx), do: {:error, :enoent}

  # ── write / create / remove / search (Wave 1 dispatch) ────────────────────
  #
  # The meta plane stays read-only; `_npl` and unregistered groups delegate to
  # their backend's behaviour defaults / return :enosys directly.

  @impl true
  def write(path, data, ctx) do
    with {:ok, segments} <- split_segments(path) do
      write_segments(segments, data, ctx)
    end
  end

  defp write_segments([@orgs_root, @npl_plane | _rest] = segments, data, ctx) do
    dispatch(NoizuPromptLingua.MCP.VFS.NPL, :write, [vpath(segments), data, ctx])
  end

  defp write_segments([@orgs_root, _org, group | _rest] = segments, data, ctx)
       when group != @meta do
    case group_backend(group) do
      nil -> {:error, :enosys}
      backend -> dispatch(backend, :write, [vpath(segments), data, ctx])
    end
  end

  defp write_segments(_segments, _data, _ctx), do: {:error, :enosys}

  @impl true
  def create(path, data, ctx) do
    with {:ok, segments} <- split_segments(path) do
      create_segments(segments, data, ctx)
    end
  end

  defp create_segments([@orgs_root, @npl_plane | _rest] = segments, data, ctx) do
    dispatch(NoizuPromptLingua.MCP.VFS.NPL, :create, [vpath(segments), data, ctx])
  end

  defp create_segments([@orgs_root, _org, group | _rest] = segments, data, ctx)
       when group != @meta do
    case group_backend(group) do
      nil -> {:error, :enosys}
      backend -> dispatch(backend, :create, [vpath(segments), data, ctx])
    end
  end

  defp create_segments(_segments, _data, _ctx), do: {:error, :enosys}

  @impl true
  def remove(path, ctx) do
    with {:ok, segments} <- split_segments(path) do
      remove_segments(segments, ctx)
    end
  end

  defp remove_segments([@orgs_root, @npl_plane | _rest] = segments, ctx) do
    dispatch(NoizuPromptLingua.MCP.VFS.NPL, :remove, [vpath(segments), ctx])
  end

  defp remove_segments([@orgs_root, _org, group | _rest] = segments, ctx)
       when group != @meta do
    case group_backend(group) do
      nil -> {:error, :enosys}
      backend -> dispatch(backend, :remove, [vpath(segments), ctx])
    end
  end

  defp remove_segments(_segments, _ctx), do: {:error, :enosys}

  @impl true
  def search(root, query, ctx) do
    with {:ok, segments} <- split_segments(root) do
      search_segments(segments, query, ctx)
    end
  end

  defp search_segments([@orgs_root, @npl_plane | _rest] = segments, query, ctx) do
    dispatch(NoizuPromptLingua.MCP.VFS.NPL, :search, [vpath(segments), query, ctx])
  end

  defp search_segments([@orgs_root, _org, group | _rest] = segments, query, ctx)
       when group != @meta do
    case group_backend(group) do
      nil -> {:error, :enosys}
      backend -> dispatch(backend, :search, [vpath(segments), query, ctx])
    end
  end

  defp search_segments(_segments, _query, _ctx), do: {:error, :enosys}

  # ── payloads ──────────────────────────────────────────────────────────────

  defp whoami(ctx) do
    view = Principal.view(ctx)

    %{
      "principal" => view.claims,
      "orgs" => view.orgs,
      "groups" => view.groups,
      "server" => %{
        "name" => NoizuPromptLingua.MCP.VFSServer.server_info().name,
        "version" => NoizuPromptLingua.MCP.VFSServer.server_info().version
      }
    }
  end

  defp toolsets(ctx) do
    gates = Principal.groups(ctx)

    %{
      "groups" => gates,
      # The narrowed plane made visible: this principal's effective tool states
      # (EffectiveToolset cascade output), keyed canonical.
      "tools" => effective_tools(ctx),
      "generated_at" => DateTime.utc_now() |> DateTime.to_iso8601()
    }
  end

  defp effective_tools(ctx) do
    client = EffectiveToolset.client_for_ctx(ctx)
    scope = EffectiveToolset.scope_from_ctx(ctx)
    user = EffectiveToolset.user_for_ctx(ctx)

    EffectiveToolset.resolve(scope, client, user)
    |> Map.new(fn {name, st} ->
      {name,
       %{
         "enabled" => st.enabled,
         "visible" => st.visible,
         "name_override" => st.name_override,
         "description_override" => st.description_override,
         "expires_at" => st.expires_at && DateTime.to_iso8601(st.expires_at)
       }}
    end)
  end

  defp group_descriptor(ctx, group_id) do
    case Enum.find(MCPServers.all(), &(&1.id == group_id)) do
      nil ->
        %{"id" => group_id}

      entry ->
        gate = Principal.groups(ctx)[group_id]

        %{
          "id" => entry.id,
          "label" => entry.label,
          "description" => entry.desc,
          "required" => entry.required,
          "gate" => %{
            "included" => gate.included,
            "visible" => gate.visible,
            "writable" => gate.writable
          },
          "status" =>
            cond do
              not gate.visible -> "excluded"
              gate.writable -> "read_write"
              true -> "read_only"
            end
        }
    end
  end

  defp overview_md(group_id) do
    label =
      case Enum.find(MCPServers.all(), &(&1.id == group_id)) do
        %{label: label} -> label
        _ -> group_id
      end

    """
    # #{label} (#{group_id})

    Wave 0 placeholder — the `#{group_id}` group's Overview surface. Its file
    plane (record.json projections, natural files, logs) mounts in a later
    wave; until then this is the only node under `/tobor/{org}/#{group_id}`.

    See `docs/` and MCP-VFS-GROUP-MOUNTS.md for the per-group mapping.
    """
  end

  # ── gates + builders ──────────────────────────────────────────────────────

  defp require_org(ctx, org, fun) do
    if Principal.org_visible?(ctx, org), do: fun.(), else: {:error, :enoent}
  end

  defp require_org_and_group(ctx, org, group, fun) do
    require_org(ctx, org, fn ->
      with :ok <- Principal.group_gate(ctx, group) do
        fun.(Principal.groups(ctx)[group])
      end
    end)
  end

  # `_meta/groups/{group}.json` — strip the extension, then gate on the group.
  defp normalize_descriptor(descriptor) do
    case String.split(descriptor, ".json") do
      [group_id, ""] when byte_size(group_id) > 0 -> {:ok, group_id}
      _ -> {:error, :enoent}
    end
  end

  defp tap_writable(result, gate) when is_tuple(result) do
    {:ok, node} = result
    {:ok, %{node | writable: gate.writable}}
  end

  defp dir_node, do: %VFS{type: :dir, mtime: now_ms(), version: version()}
  defp file_node(size), do: %VFS{type: :file, size: size, mtime: now_ms(), version: version()}

  defp dir_entry(name),
    do: %{name: name, type: :dir, size: 0, mtime: now_ms(), version: version()}

  defp file_entry(name),
    do: %{name: name, type: :file, size: 0, mtime: now_ms(), version: version()}

  defp file_entries(names), do: Enum.map(names, &file_entry/1)

  # Meta content varies by principal, not by mutation — a flat version keeps
  # the wire contract satisfied; the dispatcher stamps its generation on top.
  defp version, do: 1
  defp now_ms, do: System.os_time(:millisecond)

  defp whoami_size("whoami.json", ctx), do: byte_size(Jason.encode!(whoami(ctx)))
  defp whoami_size("toolsets.json", ctx), do: byte_size(Jason.encode!(toolsets(ctx)))
end
