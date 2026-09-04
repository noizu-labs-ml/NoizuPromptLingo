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

  ## Read-only

  Only `stat/2`, `list/3`, and `read/2` are implemented; `write/3`,
  `create/3`, and `remove/2` fall through to the behaviour's `:enosys`
  defaults. (The composed Router still advertises `vfs_write` on the wire —
  the lib derives capability flags from the composed module, which implements
  the full callback set for the `/etc/dev` control plane, and that plane is
  genuinely writable unless the server opts into `vfs_readonly`.) Group
  backends attach their own mutators in later waves behind the Router's
  prefix dispatch.
  """

  use Noizu.MCP.VFS

  alias Noizu.MCP.VFS
  alias NoizuPromptLingua.MCP.EffectiveToolset
  alias NoizuPromptLingua.MCP.VFS.Principal
  alias NoizuPromptLingua.MCPServers

  @orgs_root "tobor"
  @meta "_meta"
  @groups_dir "groups"

  @meta_files ["whoami.json", "toolsets.json"]

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

  # Per-group subtree: Wave 0 serves only the Overview placeholder; everything
  # deeper is the documented insertion point for the group's backend.
  defp stat_segments([@orgs_root, org, group], ctx) do
    require_org_and_group(ctx, org, group, fn gate ->
      {:ok, dir_node()}
      |> tap_writable(gate)
    end)
  end

  defp stat_segments([@orgs_root, org, group, "overview.md"], ctx) do
    require_org_and_group(ctx, org, group, fn gate ->
      {:ok, %{file_node(byte_size(overview_md(group))) | writable: gate.writable}}
    end)
  end

  defp stat_segments([@orgs_root, _org, _group, _deeper | _], _ctx), do: {:error, :enoent}
  defp stat_segments(_, _ctx), do: {:error, :enoent}

  # ── list/3 ────────────────────────────────────────────────────────────────

  @impl true
  def list(path, cursor, ctx) do
    with {:ok, segments} <- split_segments(path),
         {:ok, entries} <- list_segments(segments, ctx) do
      case cursor do
        nil -> {:ok, entries, nil}
        # Wave 0 listings are bounded by the catalog/org count; a cursor can
        # only be a stale or foreign continuation — reject it rather than
        # mis-paginate. (Group backends adopt the lib Pagination helper in
        # later waves when listings grow.)
        "" -> {:ok, entries, nil}
        _ -> {:error, Noizu.MCP.Error.invalid_params("invalid cursor")}
      end
    end
  end

  defp list_segments([], _ctx), do: {:ok, [dir_entry(@orgs_root)]}

  defp list_segments([@orgs_root], ctx) do
    {:ok, Enum.map(Principal.view(ctx).orgs, &dir_entry/1)}
  end

  defp list_segments([@orgs_root, org], ctx) do
    require_org(ctx, org, fn ->
      gates = Principal.groups(ctx)

      meta = dir_entry(@meta)

      group_dirs =
        gates
        |> Enum.filter(fn {_gid, gate} -> gate.visible end)
        |> Enum.map(fn {gid, _} -> dir_entry(gid) end)
        |> Enum.sort_by(& &1.name)

      {:ok, [meta | group_dirs]}
    end)
  end

  defp list_segments([@orgs_root, org, @meta], ctx) do
    require_org(ctx, org, fn ->
      {:ok, file_entries(@meta_files) ++ [dir_entry(@groups_dir)]}
    end)
  end

  defp list_segments([@orgs_root, org, @meta, @groups_dir], ctx) do
    require_org(ctx, org, fn ->
      gates = Principal.groups(ctx)

      entries =
        gates
        |> Enum.filter(fn {_gid, gate} -> gate.included end)
        |> Enum.map(fn {gid, _} -> file_entry(gid <> ".json") end)
        |> Enum.sort_by(& &1.name)

      {:ok, entries}
    end)
  end

  defp list_segments([@orgs_root, org, group], ctx) do
    require_org_and_group(ctx, org, group, fn _gate -> {:ok, [file_entry("overview.md")]} end)
  end

  defp list_segments([@orgs_root, _org, @meta, file], _ctx) when file in @meta_files,
    do: {:error, :enotdir}

  defp list_segments([@orgs_root, _org, @meta, @groups_dir, _descriptor], _ctx),
    do: {:error, :enotdir}

  defp list_segments([@orgs_root, _org, _group, "overview.md"], _ctx), do: {:error, :enotdir}

  defp list_segments(_, _ctx), do: {:error, :enoent}

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

  defp read_segments([@orgs_root, org, group, "overview.md"], ctx) do
    require_org_and_group(ctx, org, group, fn _gate -> {:ok, overview_md(group), version()} end)
  end

  defp read_segments([@orgs_root, _org, @meta], _ctx), do: {:error, :eisdir}
  defp read_segments(_, _ctx), do: {:error, :enoent}

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
