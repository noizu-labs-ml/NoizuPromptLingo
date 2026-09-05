defmodule NoizuPromptLingua.MCP.VFS.Organizations do
  @moduledoc """
  `MCP.Organizations` entity-dir (MCP-VFS-GROUP-MOUNTS.md §2.5).

  Owns the org record node inside the `/tobor` tree — everything else under
  `/tobor/{org}` (the dir itself, `_meta`, the group subtrees) stays with
  `NoizuPromptLingua.MCP.VFS.Root`, which dispatches these paths here:

      /tobor/{org}/org.json    read  = Organization.Get
                               write = Organization.Update (canonical doc merge)
                               create = Organization.Create (new slug)

  Gating (§2.5): read for any principal whose TRP key scope contains the org
  AND whose `organizations` group gate passes; **write is admin-gated** — the
  connection's user must hold an org role of admin or better (local Authz
  ladder, `owner` > `admin`). A principal with no resolvable user (shared-key
  service principal) is read-only here.

  Slug is the stable key: `slug` in a written doc is ignored (rename is out of
  scope, §2.5). `record.json` is the canonical target (§3.4) — `org.json` is
  this group's canonical doc: writes merge accepted fields into it with
  last-write-wins and ignore unknown keys, so a daemon echo of a full read
  document round-trips cleanly.

  Content is local-first (the app-DB `organizations` row is the org source of
  truth per B2), enriched with the TRP shared-key `role`/`owner` fields when
  the TRP plane serves them; a TRP error degrades to the local row rather than
  failing the read.
  """

  use Noizu.MCP.VFS

  alias Noizu.MCP.VFS
  alias NoizuPromptLingua.MCP.Resolve
  alias NoizuPromptLingua.MCP.VFS.Principal
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization, as: OrgSchema
  alias NoizuPromptLingua.TRP

  @orgs_root "tobor"
  @group_id "organizations"
  @record "org.json"

  # ── stat/2 ────────────────────────────────────────────────────────────────

  @impl true
  def stat(path, ctx) do
    with {:ok, segments} <- split_segments(path) do
      stat_segments(segments, ctx)
    end
  end

  defp stat_segments([@orgs_root, org, @record], ctx) do
    require_org(ctx, org, fn ->
      {:ok, file_node(doc_size(org, ctx))}
      |> tap_writable(org, ctx)
    end)
  end

  defp stat_segments(_, _), do: {:error, :enoent}

  # ── list/3 ────────────────────────────────────────────────────────────────

  # `org.json` is a file — nothing under this backend's ownership lists.
  @impl true
  def list(path, cursor, _ctx) do
    with {:ok, _segments} <- split_segments(path) do
      case cursor do
        c when c in [nil, ""] -> {:error, :enoent}
        _ -> {:error, Noizu.MCP.Error.invalid_params("invalid cursor")}
      end
    end
  end

  # ── read/2 ────────────────────────────────────────────────────────────────

  @impl true
  def read(path, ctx) do
    with {:ok, segments} <- split_segments(path) do
      read_segments(segments, ctx)
    end
  end

  defp read_segments([@orgs_root, org, @record], ctx) do
    require_org(ctx, org, fn -> {:ok, Jason.encode!(org_doc(org, ctx)), version()} end)
  end

  defp read_segments(_, _), do: {:error, :enoent}

  # ── write/3 — Organization.Update (canonical doc merge) ───────────────────

  @impl true
  def write(path, content, ctx) do
    with {:ok, segments} <- split_segments(path),
         [@orgs_root, org, @record] <- segments,
         {:ok, org_id} <- resolve_local_org(ctx, org),
         :ok <- require_admin(ctx, org_id),
         {:ok, doc} <- decode(content) do
      # Slug is the stable key (§2.5) — renames ride the console, not the file.
      name = valid_string(doc["name"])
      attrs = if name, do: %{"name" => name}, else: %{}

      case NoizuPromptLingua.Organizations.update_organization(org_id, attrs) do
        {:ok, _org} ->
          {:ok, file_node(byte_size(Jason.encode!(org_doc(org, ctx))))}

        {:error, %Ecto.Changeset{errors: errors}} ->
          # A rejected field edit is a refused write, not a missing node.
          {:error, changeset_errno(errors)}

        {:error, _} ->
          {:error, :eio}
      end
    else
      {:error, _} = err -> err
      _ -> {:error, :enoent}
    end
  end

  # ── create/3 — Organization.Create (create-dir + file, §2.5) ──────────────

  @impl true
  def create(_path, :dir, _ctx), do: {:error, :enosys}

  def create(path, content, ctx) do
    with {:ok, segments} <- split_segments(path),
         [@orgs_root, slug, @record] <- segments,
         :ok <- require_group_gate(ctx),
         {:ok, owner_id} <- current_user(ctx),
         {:ok, doc} <- decode(content),
         {:ok, name} <- require_field(doc, "name"),
         :ok <- assert_slug_free(slug) do
      case NoizuPromptLingua.Organizations.create_organization_with_owner(
             %{"slug" => slug, "name" => name},
             owner_id
           ) do
        {:ok, org} ->
          xattrs = %{"slug" => org.slug, "created_by" => owner_id}

          {:ok,
           %VFS{
             file_node(byte_size(Jason.encode!(%{"id" => org.id, "slug" => org.slug})))
             | xattrs: xattrs
           }}

        {:error, %Ecto.Changeset{errors: errors}} ->
          {:error, changeset_errno(errors)}

        {:error, _} ->
          {:error, :eio}
      end
    else
      {:error, _} = err -> err
      _ -> {:error, :enoent}
    end
  end

  # ── payload ───────────────────────────────────────────────────────────────

  # Local row is the org source of truth (B2); TRP contributes role/owner.
  defp org_doc(slug, _ctx) do
    local = local_org(slug)

    trp =
      case TRP.find_organization_by_slug(slug) do
        %{id: _} = shaped -> shaped
        _ -> nil
      end

    %{
      "id" => id(local, trp),
      "slug" => slug,
      "name" => name(local, trp),
      "settings" => settings(local),
      "role" => trp && Map.get(trp, :role),
      "owner" => trp && Map.get(trp, :owner)
    }
  end

  defp id(nil, %{id: id}), do: id
  defp id(%OrgSchema{id: id}, _), do: id
  defp id(_, _), do: nil

  defp name(%OrgSchema{name: name}, _), do: name
  defp name(_, %{name: name}), do: name
  defp name(_, _), do: nil

  defp settings(%OrgSchema{settings: s}) when is_map(s), do: s
  defp settings(_), do: %{}

  defp doc_size(slug, ctx), do: byte_size(Jason.encode!(org_doc(slug, ctx)))

  # ── gates ─────────────────────────────────────────────────────────────────

  defp require_org(ctx, org, fun) do
    if Principal.org_visible?(ctx, org) and match?(:ok, Principal.group_gate(ctx, @group_id)) do
      fun.()
    else
      {:error, :enoent}
    end
  end

  # Create addresses a NOT-YET-VISIBLE org (the new slug is by definition
  # outside the principal's scope until created), so only the group gate
  # applies here — not org visibility.
  defp require_group_gate(ctx) do
    if match?(:ok, Principal.group_gate(ctx, @group_id)), do: :ok, else: {:error, :enoent}
  end

  # The node exists for the principal; the writable FLAG narrows to org admins.
  defp tap_writable({:ok, node}, org, ctx) do
    writable =
      with {:ok, org_id} <- resolve_local_org(ctx, org), do: admin?(ctx, org_id)

    {:ok, %{node | writable: writable == true and gate_writable?(ctx)}}
  end

  defp resolve_local_org(ctx, org) do
    if Principal.org_visible?(ctx, org) do
      case NoizuPromptLingua.Organizations.get_id_by_slug(org) do
        nil -> {:error, :enoent}
        id -> {:ok, id}
      end
    else
      {:error, :enoent}
    end
  end

  defp require_admin(ctx, org_id) do
    if admin?(ctx, org_id), do: :ok, else: {:error, :eacces}
  end

  defp admin?(ctx, org_id) do
    case user(ctx) do
      nil ->
        false

      uid ->
        gate_writable?(ctx) and
          match?(
            {:ok, _},
            NoizuPromptLingua.Authz.authorize(uid, "organization", org_id, "admin")
          )
    end
  end

  defp gate_writable?(ctx) do
    case Principal.groups(ctx)[@group_id] do
      %{writable: true} -> true
      _ -> false
    end
  end

  defp user(ctx), do: Resolve.current_user_id(ctx)

  defp current_user(ctx) do
    case user(ctx) do
      nil -> {:error, :eacces}
      id -> {:ok, id}
    end
  end

  defp assert_slug_free(slug) do
    if NoizuPromptLingua.Organizations.get_id_by_slug(slug) != nil,
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

  defp require_field(doc, key) do
    case doc[key] do
      v when is_binary(v) and v != "" -> {:ok, v}
      _ -> {:error, :eio}
    end
  end

  defp valid_string(v) when is_binary(v) and v != "", do: v
  defp valid_string(_), do: nil

  defp changeset_errno(errors) do
    if Keyword.has_key?(errors, :slug), do: {:error, :eexist}, else: {:error, :eio}
  end

  defp local_org(slug), do: Repo.get_by(OrgSchema, slug: slug)

  # ── node builders (Root.ex conventions) ───────────────────────────────────

  defp file_node(size), do: %VFS{type: :file, size: size, mtime: now_ms(), version: version()}
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
