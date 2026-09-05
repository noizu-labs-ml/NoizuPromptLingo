defmodule NoizuPromptLingua.MCP.VFS.Campaigns do
  @moduledoc """
  VFS backend for the `campaigns` group (MCP-VFS-GROUP-MOUNTS.md §2.16) —
  entity-dir + jobs + natural landing content over the
  `NoizuPromptLingua.Domains.Campaigns` context (campaigns, ad groups, ad
  copy, landing pages, domain names). Full absolute paths, self-enforced §1.3
  gates (via `NoizuPromptLingua.MCP.VFS.Scope`), independently
  conformance-testable.

      /tobor/{org}/campaigns/campaigns/{key}/record.json      → Campaign* CRUD
      /tobor/{org}/campaigns/ad-groups/{id}/record.json       → AdGroup* CRUD
      /tobor/{org}/campaigns/ad-copy/{id}/record.json         → AdCopy projection (read)
      /tobor/{org}/campaigns/ad-copy/{id}/verdict             → Approve/Reject control file (writable)
      /tobor/{org}/campaigns/landing-pages/{key}/record.json  → LandingPage* CRUD
      /tobor/{org}/campaigns/landing-pages/{key}/content.html → the natural-file payoff (writable)
      /tobor/{org}/campaigns/domain-names/{key}/record.json   → DomainName* CRUD

  ## Decisions & conventions

    * **Keys**: `campaigns`, `landing-pages`, and `domain-names` are keyed by
      the org-unique `slug` (UUID accepted too — the context `resolve_*`
      helpers accept either). `ad-groups` and `ad-copy` carry no org-unique
      slug (ad-group slugs are only campaign-unique; ad-copy has none), so
      those two subtrees are **id-keyed**: the `{id}` segment must be the
      entity UUID. Listings emit the key form of each subtree.
    * **Create** writes the entity dir with a JSON object body. Defaults
      mirror the changesets: `name` (campaigns/landing pages: from slug;
      ad groups/domain names: from body slug/name), `title` defaults to slug
      for landing pages. Ad-group/ad-copy creates must carry `campaign_id` in
      the body — validated to exist **within the org** (`:enoent` otherwise).
      The path identity wins: id/slug/organization_id from the body are
      ignored.
    * **`record.json` write maps the Update tools** (`CampaignUpdate`,
      `AdGroupUpdate`, `LandingPageUpdate`, `DomainNameUpdate`) — JSON object
      merged onto the entity, identity keys ignored. Ad-copy has no update
      tool: its record.json is **read-only**.
    * **`verdict` is the AdCopyApprove / AdCopyReject control file**: absent
      until a verdict exists; content is one line — `approved` or `rejected`
      (whitespace tolerated; anything else `:eio`). Writing flips or sets the
      verdict. ToolGuard-checked: the op passes the same §1.3 group write
      gate (an included-but-disabled toolset refuses with `:eacces`), which
      is the VFS-side analog of the surface tool guard.
    * **`content.html` is the natural landing-page body**, backed by the
      page's artifact (latest revision). Present only once an artifact exists
      (`stat`/`read` are `:enoent` before that). `create` links a fresh
      artifact; `write` appends a revision (or seeds the artifact when the
      page has none) — edit locally, the daemon pushes the update.
    * **Generation ops are `:enosys`** — `AdCopyGenerate` and
      `LandingPageGenerate` have no file-plane node (there is no natural
      single-file surface for a bulk-variant or full-page generation). Both
      are LLM-backed long-running ops that do not fit a sync control write
      (§3.8); they move to the job-dir convention when the Wave 4 Jobs runner
      lands.
    * **Delete**: no Delete tools in the domain — `remove` is `:enosys` for an
      existing entity (`:enoent` otherwise), tool-faithful per the §2.16
      table.
    * **Pagination** — lib `Features.Pagination` opaque offset cursors over an
      org-bounded fetch (ceiling 500).

  Liveness: VFS mutations are live; MCP-surface edits surface within the TTL.
  """

  use Noizu.MCP.VFS

  import Ecto.Query, only: [from: 2, where: 3, select: 3]

  alias Noizu.MCP.Server.Features.Pagination
  alias NoizuPromptLingua.Domains.{Artifacts, Campaigns}
  alias NoizuPromptLingua.MCP.Resolve
  alias NoizuPromptLingua.MCP.VFS.{Overview, Scope}
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{AdCopy, AdGroup, Campaign}
  alias NoizuPromptLingua.UUID

  @group "campaigns"
  @fetch_ceiling 500
  @page_size 100

  @subtrees ["campaigns", "ad-groups", "ad-copy", "landing-pages", "domain-names"]
  @slug_keyed ["campaigns", "landing-pages", "domain-names"]
  @id_keyed ["ad-groups", "ad-copy"]

  # record.json writes never move identity (id/org/slug — the path is the
  # truth); creates only drop id/org, since slug arrives from the path
  # (slug-keyed subtrees) or the body (ad groups).
  @record_identity_keys [:id, :organization_id, :slug]
  @create_identity_keys [:id, :organization_id]

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

  defp stat_rest(_org, ["overview.md"], _gate, _ctx),
    do: {:ok, Scope.file_node(byte_size(Overview.md(overview_tool(), @group)))}

  defp stat_rest(org, [subtree], gate, _ctx) when subtree in @subtrees do
    with {:ok, _org_id} <- org_id(org) do
      {:ok, %{Scope.dir_node() | writable: gate.writable}}
    end
  end

  defp stat_rest(org, [subtree, key], gate, _ctx) when subtree in @subtrees do
    with {:ok, _entity} <- resolve_entity(org, subtree, key) do
      {:ok, %{Scope.dir_node() | writable: gate.writable}}
    end
  end

  defp stat_rest(org, [subtree, key, filename], _gate, _ctx)
       when subtree in @subtrees and is_binary(filename) do
    with {:ok, entity} <- resolve_entity(org, subtree, key),
         {:ok, body} <- entity_file(subtree, entity, filename) do
      {:ok, Scope.file_node(byte_size(body))}
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

  defp list_rest(_org, [], cursor, _ctx) do
    entries = [
      Scope.file_entry("overview.md"),
      Scope.dir_entry("campaigns"),
      Scope.dir_entry("ad-groups"),
      Scope.dir_entry("ad-copy"),
      Scope.dir_entry("landing-pages"),
      Scope.dir_entry("domain-names")
    ]

    paginate(entries, cursor)
  end

  defp list_rest(_org, ["overview.md"], _cursor, _ctx), do: {:error, :enotdir}

  defp list_rest(org, [subtree], cursor, _ctx) when subtree in @subtrees do
    with {:ok, entities} <- list_entities(org, subtree) do
      paginate(Enum.map(entities, &Scope.dir_entry(entity_key(subtree, &1))), cursor)
    end
  end

  defp list_rest(org, [subtree, key], cursor, _ctx) when subtree in @subtrees do
    with {:ok, entity} <- resolve_entity(org, subtree, key) do
      paginate(Scope.file_entries(entity_files(entity)), cursor)
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

  defp read_rest(_org, ["overview.md"], _ctx),
    do: {:ok, Overview.md(overview_tool(), @group), Scope.version()}

  defp read_rest(org, [subtree], _ctx) when subtree in @subtrees,
    do: with({:ok, _org_id} <- org_id(org), do: {:error, :eisdir})

  defp read_rest(org, [subtree, key], _ctx) when subtree in @subtrees do
    case resolve_entity(org, subtree, key) do
      {:ok, _entity} -> {:error, :eisdir}
      error -> error
    end
  end

  defp read_rest(org, [subtree, key, filename], _ctx)
       when subtree in @subtrees and is_binary(filename) do
    with {:ok, entity} <- resolve_entity(org, subtree, key),
         {:ok, body} <- entity_file(subtree, entity, filename) do
      {:ok, body, Scope.version()}
    end
  end

  defp read_rest(_org, _rest, _ctx), do: {:error, :enoent}

  # ── create/3 ──────────────────────────────────────────────────────────────

  @impl true
  def create(path, data, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, gate} <- Scope.gate(ctx, org, @group),
         :ok <- Scope.require_writable(gate) do
      create_rest(org, rest, data)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  # CampaignCreate / AdGroupCreate / AdCopyCreate / LandingPageCreate /
  # DomainNameCreate: identity from the path, attrs from the JSON body.
  defp create_rest(org, [subtree, key], data)
       when subtree in @subtrees and is_binary(data) do
    with {:ok, org_id} <- org_id(org),
         {:ok, body} <- decode_object(data),
         {:ok, attrs} <- atomize(body),
         :ok <- collision_ok(org, subtree, key),
         :ok <- campaign_refs_ok(org_id, subtree, attrs) do
      attrs =
        attrs
        |> Map.drop(@create_identity_keys)
        |> maybe_default_name(subtree, key)
        |> Map.put(:organization_id, org_id)
        |> maybe_put_slug(subtree, key)

      insert_entity(subtree, key, attrs)
    end
  end

  defp create_rest(_org, [_subtree, _key], :dir), do: {:error, :enosys}

  # Strict create on the absent-or-present files: make a verdict / seed the
  # landing content when absent (`:eexist` when present — flipping a verdict
  # or revising content is a `write`).
  defp create_rest(org, ["ad-copy", key, "verdict"], data) when is_binary(data) do
    case resolve_entity(org, "ad-copy", key) do
      {:ok, ad_copy} ->
        if node_present?(ad_copy, "verdict") do
          {:error, :eexist}
        else
          with {:ok, verdict} <- parse_verdict(data),
               {:ok, _updated} <- set_verdict(ad_copy.id, verdict) do
            {:ok, Scope.file_node(byte_size(verdict))}
          end
        end

      error ->
        error
    end
  end

  defp create_rest(org, ["landing-pages", key, "content.html"], data) when is_binary(data) do
    case resolve_entity(org, "landing-pages", key) do
      {:ok, page} ->
        if node_present?(page, "content.html"),
          do: {:error, :eexist},
          else: write_landing_content(page, data)

      error ->
        error
    end
  end

  defp create_rest(org, [subtree, key, _filename], _data) when subtree in @subtrees do
    case resolve_entity(org, subtree, key) do
      {:ok, _entity} -> {:error, :eexist}
      error -> error
    end
  end

  defp create_rest(_org, _rest, _data), do: {:error, :enosys}

  # ── write/3 ───────────────────────────────────────────────────────────────

  @impl true
  def write(path, data, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, gate} <- Scope.gate(ctx, org, @group),
         :ok <- Scope.require_writable(gate) do
      write_rest(org, rest, data)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  # CampaignUpdate / AdGroupUpdate / LandingPageUpdate / DomainNameUpdate.
  defp write_rest(org, [subtree, key, "record.json"], data)
       when subtree in ["campaigns", "ad-groups", "landing-pages", "domain-names"] and
              is_binary(data) do
    with {:ok, entity} <- resolve_entity(org, subtree, key),
         {:ok, body} <- decode_object(data),
         {:ok, attrs} <- atomize(body) do
      case update_entity(subtree, entity.id, Map.drop(attrs, @record_identity_keys)) do
        {:ok, updated} ->
          {:ok, Scope.file_node(byte_size(entity_file!(subtree, updated, "record.json")))}

        {:error, _changeset} ->
          {:error, :eio}
      end
    end
  end

  # AdCopyApprove / AdCopyReject — the one-line verdict control file.
  defp write_rest(org, ["ad-copy", id, "verdict"], data) when is_binary(data) do
    with {:ok, ad_copy} <- resolve_entity(org, "ad-copy", id),
         {:ok, verdict} <- parse_verdict(data),
         {:ok, _updated} <- set_verdict(ad_copy.id, verdict) do
      {:ok, Scope.file_node(byte_size(verdict))}
    end
  end

  # The natural landing-page body: write = append a revision (seeding the
  # artifact when the page has none).
  defp write_rest(org, ["landing-pages", key, "content.html"], data) when is_binary(data) do
    with {:ok, page} <- resolve_entity(org, "landing-pages", key) do
      write_landing_content(page, data)
    end
  end

  # AdCopy has no update tool; the record.json write is refused in place.
  defp write_rest(org, ["ad-copy", id, "record.json"], _data) do
    case resolve_entity(org, "ad-copy", id) do
      {:ok, _ad_copy} -> {:error, :enosys}
      error -> error
    end
  end

  defp write_rest(_org, _rest, _data), do: {:error, :enosys}

  # ── remove/2 ──────────────────────────────────────────────────────────────

  # No Delete tools in the domain — removal stays off the file plane.
  @impl true
  def remove(path, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, gate} <- Scope.gate(ctx, org, @group),
         :ok <- Scope.require_writable(gate) do
      remove_rest(org, rest)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  defp remove_rest(org, [subtree, key]) when subtree in @subtrees do
    case resolve_entity(org, subtree, key) do
      {:ok, _entity} -> {:error, :enosys}
      error -> error
    end
  end

  defp remove_rest(_org, _rest), do: {:error, :enosys}

  # ── resolution ────────────────────────────────────────────────────────────

  defp overview_tool, do: NoizuPromptLingua.Domains.Campaigns.Tools.Overview

  defp org_id(org) do
    case Resolve.organization_id(org) do
      nil -> {:error, :enoent}
      id -> {:ok, id}
    end
  end

  defp resolve_entity(org, subtree, key) when subtree in @slug_keyed do
    with {:ok, org_id} <- org_id(org) do
      entity =
        case subtree do
          "campaigns" -> Campaigns.resolve_campaign(org_id, key)
          "landing-pages" -> Campaigns.resolve_landing_page(org_id, key)
          "domain-names" -> Campaigns.resolve_domain_name(org_id, key)
        end

      case entity do
        nil -> {:error, :enoent}
        entity -> {:ok, entity}
      end
    end
  end

  # Ad groups / ad copy are id-keyed AND org-scoped (the context getters are
  # global by id, so the org scope is enforced here).
  defp resolve_entity(org, subtree, key)
       when subtree in @id_keyed and is_binary(key) do
    with {:ok, org_id} <- org_id(org),
         {:ok, uuid} <- uuid(key) do
      entity =
        case subtree do
          "ad-groups" -> Repo.get_by(AdGroup, id: uuid, organization_id: org_id)
          "ad-copy" -> Repo.get_by(AdCopy, id: uuid, organization_id: org_id)
        end

      case entity do
        nil -> {:error, :enoent}
        entity -> {:ok, entity}
      end
    end
  end

  defp resolve_entity(_org, _subtree, _key), do: {:error, :enoent}

  defp uuid(key) do
    case UUID.cast(key) do
      {:ok, uuid} -> {:ok, uuid}
      :error -> {:error, :enoent}
    end
  end

  defp entity_key(subtree, entity) when subtree in @id_keyed, do: entity.id
  defp entity_key(_subtree, entity), do: entity.slug

  defp list_entities(org, "ad-groups") do
    with {:ok, org_id} <- org_id(org) do
      {:ok,
       Repo.all(
         from g in AdGroup,
           where: g.organization_id == ^org_id,
           order_by: [asc: g.inserted_at],
           limit: @fetch_ceiling
       )}
    end
  end

  defp list_entities(org, "ad-copy") do
    with {:ok, org_id} <- org_id(org) do
      {:ok,
       Repo.all(
         from c in AdCopy,
           where: c.organization_id == ^org_id,
           order_by: [asc: c.inserted_at],
           limit: @fetch_ceiling
       )}
    end
  end

  defp list_entities(org, subtree) do
    with {:ok, org_id} <- org_id(org) do
      case subtree do
        "campaigns" ->
          {:ok, Campaigns.list_campaigns(organization_id: org_id, limit: @fetch_ceiling)}

        "landing-pages" ->
          {:ok, Campaigns.list_landing_pages(organization_id: org_id, limit: @fetch_ceiling)}

        "domain-names" ->
          {:ok, Campaigns.list_domain_names(organization_id: org_id, limit: @fetch_ceiling)}
      end
    end
  end

  # ── entity files ──────────────────────────────────────────────────────────

  # record.json always; verdict/content.html only once they exist.
  defp entity_files(entity) do
    ["record.json"] ++ Enum.filter(["verdict", "content.html"], &node_present?(entity, &1))
  end

  defp node_present?(entity, "verdict"), do: entity.status in ["approved", "rejected"]
  defp node_present?(entity, "content.html"), do: artifact_content(entity) != nil
  defp node_present?(_entity, _filename), do: false

  defp entity_file(_subtree, entity, "record.json"), do: {:ok, record_json(entity)}

  defp entity_file("ad-copy", ad_copy, "verdict") do
    if node_present?(ad_copy, "verdict"), do: {:ok, ad_copy.status}, else: {:error, :enoent}
  end

  defp entity_file("landing-pages", page, "content.html") do
    case artifact_content(page) do
      nil -> {:error, :enoent}
      content -> {:ok, content}
    end
  end

  defp entity_file(_subtree, _entity, _filename), do: {:error, :enoent}

  defp entity_file!(subtree, entity, filename) do
    {:ok, body} = entity_file(subtree, entity, filename)
    body
  end

  defp record_json(entity) do
    entity
    |> Map.from_struct()
    |> Map.drop([:__meta__, :inserted_at, :updated_at])
    |> Map.new(fn {k, v} -> {Atom.to_string(k), jsonable(v)} end)
    |> Map.put("created_at", iso(entity.inserted_at))
    |> Map.put("updated_at", iso(entity.updated_at))
    |> Jason.encode!()
  end

  # Decimal metrics serialize as JSON numbers; everything else passes through.
  defp jsonable(%Decimal{} = d), do: Decimal.to_float(d)
  defp jsonable(v), do: v

  defp artifact_content(entity) do
    case entity.artifact_id && Artifacts.get(entity.artifact_id) do
      {_artifact, %{content: content}} when is_binary(content) -> content
      _ -> nil
    end
  end

  # ── landing-page content (natural file) ───────────────────────────────────

  defp write_landing_content(page, data) do
    if page.artifact_id do
      case Artifacts.add_revision(page.artifact_id, data, "content.html edit") do
        {:ok, _revision} -> {:ok, Scope.file_node(byte_size(data))}
        {:error, _} -> {:error, :eio}
      end
    else
      case seed_artifact(page, data) do
        {:ok, _artifact} -> {:ok, Scope.file_node(byte_size(data))}
        {:error, _} -> {:error, :eio}
      end
    end
  end

  # Mirrors LandingPageGenerate's artifact shape (kind "code", text/html).
  defp seed_artifact(page, content) do
    with {:ok, artifact} <-
           Artifacts.create(%{
             organization_id: page.organization_id,
             project_id: page.project_id,
             kind: "code",
             title: page.title,
             mime_type: "text/html",
             content: content
           }),
         {:ok, _page} <- Campaigns.update_landing_page(page.id, %{artifact_id: artifact.id}) do
      {:ok, artifact}
    end
  end

  # ── verdict (AdCopyApprove/AdCopyReject) ──────────────────────────────────

  defp parse_verdict(data) do
    case String.trim(data) do
      verdict when verdict in ["approved", "rejected"] -> {:ok, verdict}
      _ -> {:error, :eio}
    end
  end

  defp set_verdict(id, "approved"), do: Campaigns.approve_ad_copy(id)
  defp set_verdict(id, "rejected"), do: Campaigns.reject_ad_copy(id)

  # ── create/update plumbing ────────────────────────────────────────────────

  # Ad-group and ad-copy creates must reference a campaign in this org
  # (get_campaign/1 is global by id, so the org scope is enforced here).
  defp campaign_refs_ok(org_id, subtree, attrs) when subtree in @id_keyed do
    campaign_id = attrs[:campaign_id]

    with {:ok, uuid} <- uuid(campaign_id),
         %Campaign{} = campaign <- Campaigns.get_campaign(uuid),
         true <- campaign.organization_id == org_id do
      :ok
    else
      _ -> {:error, :enoent}
    end
  end

  defp campaign_refs_ok(_org_id, _subtree, _attrs), do: :ok

  defp maybe_default_name(attrs, subtree, key)
       when subtree in ["campaigns", "landing-pages", "domain-names"] do
    Map.put_new(attrs, :name, key) |> maybe_title(subtree, key)
  end

  defp maybe_default_name(attrs, "ad-groups", _key), do: Map.put_new(attrs, :name, attrs[:slug])
  defp maybe_default_name(attrs, _subtree, _key), do: attrs

  defp maybe_title(attrs, "landing-pages", key), do: Map.put_new(attrs, :title, key)
  defp maybe_title(attrs, _subtree, _key), do: attrs

  # Slug-keyed subtrees take the slug from the path; id-keyed subtrees keep
  # whatever the body carries (changeset validates).
  defp maybe_put_slug(attrs, subtree, key) when subtree in @slug_keyed,
    do: Map.put(attrs, :slug, key)

  defp maybe_put_slug(attrs, _subtree, _key), do: attrs

  defp collision_ok(org, subtree, key) do
    case resolve_entity(org, subtree, key) do
      {:ok, _} -> {:error, :eexist}
      {:error, :enoent} -> :ok
      error -> error
    end
  end

  defp insert_entity(subtree, key, attrs) when subtree in @id_keyed do
    with {:ok, uuid} <- uuid(key) do
      # The path IS the primary key; the schemas don't cast :id, so it is
      # pre-set on the struct (Repo.insert keeps a non-nil binary_id).
      schema = if(subtree == "ad-groups", do: AdGroup, else: AdCopy)
      attrs = maybe_next_variant(subtree, attrs)

      case schema |> struct(id: uuid) |> schema.changeset(attrs) |> Repo.insert() do
        {:ok, entity} -> {:ok, %{Scope.dir_node() | writable: true, xattrs: %{"id" => entity.id}}}
        {:error, _changeset} -> {:error, :eio}
      end
    else
      # Non-UUID key on an id-keyed subtree: not a valid entity address.
      {:error, _} -> {:error, :eio}
    end
  end

  defp insert_entity(subtree, _key, attrs) do
    case create_fun(subtree).(attrs) do
      {:ok, entity} -> {:ok, %{Scope.dir_node() | writable: true, xattrs: %{"id" => entity.id}}}
      {:error, _changeset} -> {:error, :eio}
    end
  end

  # Mirrors AdCopyCreate's variant auto-numbering (the changeset path here
  # cannot reach the context's private next_variant/2).
  defp maybe_next_variant("ad-copy", attrs) do
    Map.put_new_lazy(attrs, :variant_number, fn ->
      query =
        AdCopy
        |> where([a], a.campaign_id == ^attrs[:campaign_id])

      query =
        if attrs[:ad_group_id] do
          where(query, [a], a.ad_group_id == ^attrs[:ad_group_id])
        else
          where(query, [a], is_nil(a.ad_group_id))
        end

      (query |> select([a], max(a.variant_number)) |> Repo.one() || 0) + 1
    end)
  end

  defp maybe_next_variant(_subtree, attrs), do: attrs

  defp create_fun("campaigns"), do: &Campaigns.create_campaign/1
  defp create_fun("landing-pages"), do: &Campaigns.create_landing_page/1
  defp create_fun("domain-names"), do: &Campaigns.create_domain_name/1

  defp update_entity("campaigns", id, attrs), do: Campaigns.update_campaign(id, attrs)
  defp update_entity("ad-groups", id, attrs), do: Campaigns.update_ad_group(id, attrs)
  defp update_entity("landing-pages", id, attrs), do: Campaigns.update_landing_page(id, attrs)
  defp update_entity("domain-names", id, attrs), do: Campaigns.update_domain_name(id, attrs)
  defp update_entity(_subtree, _id, _attrs), do: {:error, :enosys}

  # JSON object bodies only (arrays/scalars are :eio) — the attrs of the op.
  # Bodies are atomized via existing atoms (the schema field names — the
  # domain's create_ad_copy reads campaign_id via atom access); unknown
  # fields are rejected as :eio instead of leaking into the changeset.
  defp decode_object(data) do
    case Jason.decode(data) do
      {:ok, attrs} when is_map(attrs) -> {:ok, attrs}
      {:ok, _} -> {:error, :eio}
      {:error, _} -> {:error, :eio}
    end
  end

  defp atomize(attrs) do
    {:ok, Map.new(attrs, fn {k, v} -> {String.to_existing_atom(k), v} end)}
  rescue
    ArgumentError -> {:error, :eio}
  end

  # ── shared helpers ────────────────────────────────────────────────────────

  defp paginate(items, cursor) do
    cursor = if cursor == "", do: nil, else: cursor

    case Pagination.paginate(items, cursor, @page_size) do
      {:ok, page, next} -> {:ok, page, next}
      {:error, _} -> {:error, Noizu.MCP.Error.invalid_params("invalid cursor")}
    end
  end

  defp iso(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp iso(dt), do: to_string(dt)
end
