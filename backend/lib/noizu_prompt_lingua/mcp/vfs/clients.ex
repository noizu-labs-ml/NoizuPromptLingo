defmodule NoizuPromptLingua.MCP.VFS.Clients do
  @moduledoc """
  `MCP.Clients` entity-dir (MCP-VFS-GROUP-MOUNTS.md §2.22) — the internal
  group, backed by the local app-DB mirror (`NoizuPromptLingua.Clients`).

  Owns the `/tobor/{org}/clients` subtree (Root dispatches mapped groups
  wholly):

      /tobor/{org}/clients                     readdir = Client.List
      /tobor/{org}/clients/overview.md         group overview
      /tobor/{org}/clients/{slug}              client dir (slug = stable key)
      …/{slug}/record.json                     read = Client.Get · write = Client.Update
                                               create = Client.Create

  Exposure is the narrowest in the tree: the subtree exists ONLY for
  **root-plane principals** (no custom scope — §2.22 serves this group on the
  root plane, never through scoped/custom endpoints) whose `clients` group
  gate passes AND who are org admins (local Authz rank ≤ admin). Everyone
  else — scoped keys, non-admin users, unresolvable principals — gets
  `:enoent` for the entire subtree: hidden, not read-only.

  Writes follow §3.4: `record.json` merges accepted fields (`name`, `notes`,
  `currency`, `default_hourly_rate_cents`) with last-write-wins. Status is a
  lifecycle column, not content: writing `"archived"`/`"deleted"` is refused
  `:eacces` (§3.5 — no client archive/delete is file-exposed); an unchanged
  `"active"` value round-trips (daemon echoes of a full read doc pass).

  Removal is not implemented (delete stays off the file plane, §3.5).
  """

  use Noizu.MCP.VFS

  alias Noizu.MCP.VFS
  alias NoizuPromptLingua.Clients, as: ClientsCtx
  alias NoizuPromptLingua.MCP.EffectiveToolset
  alias NoizuPromptLingua.MCP.Resolve
  alias NoizuPromptLingua.MCP.VFS.Principal
  alias NoizuPromptLingua.Organizations
  alias NoizuPromptLingua.Schema.Clients.Client

  @orgs_root "tobor"
  @group_dir "clients"
  @record "record.json"

  @write_fields ["name", "notes", "currency", "default_hourly_rate_cents"]
  @transitions ["archived", "deleted"]

  # ── stat/2 ────────────────────────────────────────────────────────────────

  @impl true
  def stat(path, ctx) do
    with {:ok, segments} <- split_segments(path) do
      case segments do
        [@orgs_root, org, @group_dir] ->
          exposed(ctx, org, fn -> {:ok, dir_node()} end)

        [@orgs_root, org, @group_dir, "overview.md"] ->
          exposed(ctx, org, fn -> {:ok, file_node(byte_size(overview_md()))} end)

        [@orgs_root, org, @group_dir, slug] ->
          exposed(ctx, org, fn ->
            with {:ok, org_id} <- resolve_org_id(org),
                 {:ok, %Client{} = client} <- fetch_client(org_id, slug) do
              {:ok, %{dir_node() | xattrs: %{"id" => client.id}}}
            end
          end)

        [@orgs_root, org, @group_dir, slug, @record] ->
          exposed(ctx, org, fn ->
            with {:ok, org_id} <- resolve_org_id(org),
                 {:ok, %Client{} = client} <- fetch_client(org_id, slug) do
              {:ok, file_node(doc_size(client))}
            end
          end)

        _ ->
          {:error, :enoent}
      end
    end
  end

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
    exposed(ctx, org, fn ->
      with {:ok, org_id} <- resolve_org_id(org) do
        slugs =
          org_id
          |> ClientsCtx.list_for_org(status: "all")
          |> Enum.map(& &1.slug)
          |> Enum.sort()
          |> Enum.uniq()

        {:ok, Enum.map(slugs, &dir_entry/1)}
      end
    end)
  end

  defp list_segments([@orgs_root, org, @group_dir, slug], ctx) do
    exposed(ctx, org, fn ->
      with {:ok, org_id} <- resolve_org_id(org),
           {:ok, %Client{}} <- fetch_client(org_id, slug) do
        {:ok, [file_entry(@record)]}
      end
    end)
  end

  defp list_segments([@orgs_root, _org, @group_dir, "overview.md"], _ctx), do: {:error, :enotdir}
  defp list_segments([@orgs_root, _org, @group_dir, _slug, @record], _ctx), do: {:error, :enotdir}

  defp list_segments(_, _), do: {:error, :enoent}

  # ── read/2 ────────────────────────────────────────────────────────────────

  @impl true
  def read(path, ctx) do
    with {:ok, segments} <- split_segments(path) do
      case segments do
        [@orgs_root, org, @group_dir, "overview.md"] ->
          exposed(ctx, org, fn -> {:ok, overview_md(), version()} end)

        [@orgs_root, org, @group_dir, slug, @record] ->
          exposed(ctx, org, fn ->
            with {:ok, org_id} <- resolve_org_id(org),
                 {:ok, %Client{} = client} <- fetch_client(org_id, slug) do
              {:ok, Jason.encode!(client_doc(client)), version()}
            end
          end)

        [@orgs_root, _org, @group_dir] ->
          {:error, :eisdir}

        _ ->
          {:error, :enoent}
      end
    end
  end

  # ── write/3 — Client.Update (canonical doc merge, §3.4) ───────────────────

  @impl true
  def write(path, content, ctx) do
    with {:ok, segments} <- split_segments(path),
         [@orgs_root, org, @group_dir, slug, @record] <- segments,
         :ok <- expose_gate(ctx, org),
         {:ok, org_id} <- resolve_org_id(org),
         {:ok, %Client{} = client} <- fetch_client(org_id, slug),
         {:ok, doc} <- decode(content),
         :ok <- refuse_transition(doc, client) do
      attrs =
        doc
        |> Map.take(@write_fields)
        |> stringify_keys()

      case ClientsCtx.update(client.id, attrs) do
        {:ok, updated} -> {:ok, file_node(doc_size(updated))}
        {:error, :not_found} -> {:error, :enoent}
        {:error, _changeset} -> {:error, :eio}
      end
    else
      {:error, _} = err -> err
      _ -> {:error, :enoent}
    end
  end

  # Status is a lifecycle column (§3.5): transitions are refused; a value
  # equal to the current status round-trips (daemon echo of a full doc).
  defp refuse_transition(%{"status" => s}, _client) when s in @transitions, do: {:error, :eacces}

  defp refuse_transition(%{"status" => s}, %Client{} = client) when is_binary(s) do
    if s == client.status, do: :ok, else: {:error, :eio}
  end

  defp refuse_transition(%{"status" => _}, _), do: {:error, :eio}
  defp refuse_transition(_, _), do: :ok

  # ── create/3 — Client.Create ──────────────────────────────────────────────

  @impl true
  def create(_path, :dir, _ctx), do: {:error, :enosys}

  def create(path, content, ctx) do
    with {:ok, segments} <- split_segments(path),
         [@orgs_root, org, @group_dir, slug, @record] <- segments,
         :ok <- expose_gate(ctx, org),
         {:ok, org_id} <- resolve_org_id(org),
         :ok <- assert_slug_free(org_id, slug),
         {:ok, doc} <- decode(content),
         {:ok, name} <- require_field(doc, "name") do
      attrs = %{
        "organization_id" => org_id,
        "slug" => slug,
        "name" => name,
        "notes" => doc["notes"],
        "currency" => doc["currency"],
        "default_hourly_rate_cents" => doc["default_hourly_rate_cents"]
      }

      case ClientsCtx.create(attrs, Resolve.current_user_id(ctx)) do
        {:ok, client} -> {:ok, file_node(doc_size(client))}
        {:error, %Ecto.Changeset{errors: errors}} -> changeset_errno(errors)
        {:error, _} -> {:error, :eio}
      end
    else
      {:error, _} = err -> err
      _ -> {:error, :enoent}
    end
  end

  # ── payload ───────────────────────────────────────────────────────────────

  defp client_doc(client) do
    %{
      "id" => client.id,
      "organization_id" => client.organization_id,
      "name" => client.name,
      "slug" => client.slug,
      "status" => client.status,
      "notes" => client.notes,
      "currency" => client.currency,
      "default_hourly_rate_cents" => client.default_hourly_rate_cents,
      "created_at" => iso(client.inserted_at),
      "updated_at" => iso(client.updated_at)
    }
  end

  defp doc_size(client), do: byte_size(Jason.encode!(client_doc(client)))

  # ── exposure gate (§2.22: root-plane × org-admin, else hidden) ────────────

  defp exposed(ctx, org, fun) do
    with :ok <- expose_gate(ctx, org), do: fun.()
  end

  # The §2.22 gate: org-visible × root-plane key × org admin. NOTE there is
  # NO group-gate check here — `clients` is deliberately absent from the
  # public customizable catalog (it is served on the root plane only), so
  # `Principal.group_gate/2` has no catalog row to consult; root-plane keys
  # carry the aggregate toolset and the admin requirement narrows writes and
  # reads alike. Any miss is indistinguishable from absence (hidden, not
  # read-only).
  defp expose_gate(ctx, org) do
    with true <- Principal.org_visible?(ctx, org),
         true <- root_plane?(ctx),
         {:ok, org_id} <- resolve_org_id(org),
         {:ok, _} <-
           NoizuPromptLingua.Authz.authorize(
             Resolve.current_user_id(ctx),
             "organization",
             org_id,
             "admin"
           ) do
      :ok
    else
      # EVERY miss — not visible, scoped key, non-admin, no user — is
      # indistinguishable from absence (§2.22: hidden, not read-only).
      _ -> {:error, :enoent}
    end
  end

  # Root-plane = the connection carries no custom scope (§2.22: this group is
  # served on the root plane only — a scoped key never sees the subtree).
  defp root_plane?(ctx), do: is_nil(EffectiveToolset.scope_from_ctx(ctx))

  # ── lookups ───────────────────────────────────────────────────────────────

  defp resolve_org_id(org) do
    case Organizations.get_id_by_slug(org) do
      nil -> {:error, :enoent}
      id -> {:ok, id}
    end
  end

  defp fetch_client(org_id, slug) do
    case ClientsCtx.resolve(org_id, slug) do
      nil -> {:error, :enoent}
      client -> {:ok, client}
    end
  end

  defp assert_slug_free(org_id, slug) do
    if ClientsCtx.resolve(org_id, slug) != nil, do: {:error, :eexist}, else: :ok
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

  defp changeset_errno(errors) do
    if Keyword.has_key?(errors, :slug), do: {:error, :eexist}, else: {:error, :eio}
  end

  defp stringify_keys(map) when is_map(map),
    do: Map.new(map, fn {k, v} -> {if(is_binary(k), do: k, else: to_string(k)), v} end)

  defp iso(nil), do: nil
  defp iso(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp iso(other), do: to_string(other)

  defp overview_md do
    """
    # Clients (clients)

    Internal client entity-dir (`MCP-VFS-GROUP-MOUNTS.md` §2.22) — org-scoped
    customers on the local app-DB mirror. Exposed only to root-plane org-admin
    principals; `record.json` is the canonical document. Lifecycle values
    (`archived`, `deleted`) are not file-writable.
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
