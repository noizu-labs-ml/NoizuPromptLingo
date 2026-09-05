defmodule NoizuPromptLingua.Organizations.SlugResolutionTest do
  use NoizuPromptLingua.DataCase, async: false

  @moduledoc """
  B2 regression — org slug resolution must be LOCAL-first with the TRP
  shared-key plane as fallback. Pre-fix, `get_id_by_slug/1` consulted TRP
  only, so every org created locally (TRP provisioning failed, or TRP not
  configured — `create_organization_with_owner/2` keeps the local row)
  404'd on all /org/<slug>/… gateways while its UUID path worked.

  async: false — the TRP stub + its ETS list cache are VM-global.
  """

  alias NoizuPromptLingua.Organizations
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.TRP.TestStub

  setup do
    TestStub.reset()
    NoizuPromptLingua.TRP.Cache.bust_prefix([:orgs, :list])
    NoizuPromptLingua.TRP.Cache.clear()
    :ok
  end

  # Run-unique slug suffix: localhost Redis outlives the test VM, and a
  # repeated slug would hit the previous run's positive cache entry (TTL 1h)
  # pointing at a rolled-back sandbox org.
  defp run_slug(prefix), do: "#{prefix}-#{Ecto.UUID.generate()}"

  test "org exists LOCALLY but not in the TRP inventory ⇒ slug resolves (B2)" do
    slug = run_slug("local-only")
    org = Repo.insert!(%Organization{name: "Local Only", slug: slug})

    assert Organizations.get_id_by_slug(slug) == org.id
    assert {:ok, id} = Organizations.resolve_org_id(slug)
    assert id == org.id
  end

  test "unknown slug ⇒ not found (no oracle change)" do
    assert Organizations.get_id_by_slug(run_slug("no-such-org")) == nil

    assert {:error, :not_found} = Organizations.resolve_org_id(run_slug("no-such-org"))
  end

  test "TRP-knows-but-local-missing org ⇒ still resolves via the TRP fallback" do
    trp_id = Ecto.UUID.generate()
    slug = run_slug("trp-only")

    TestStub.seed_org(trp_id, slug)
    NoizuPromptLingua.TRP.Cache.bust_prefix([:orgs, :list])

    # No app-DB row for this org — the fallback carries it.
    assert Organizations.get_id_by_slug(slug) == trp_id
    assert {:ok, trp_id} = Organizations.resolve_org_id(slug)
  end

  test "resolution is case-insensitive on the LOCAL branch (citext)" do
    slug = run_slug("Mixed-Case")
    org = Repo.insert!(%Organization{name: "Mixed", slug: slug})
    lower = String.downcase(slug)

    assert Organizations.get_id_by_slug(lower) == org.id
  end

  test "TRP fallback still serves exact-slug orgs" do
    trp_id = Ecto.UUID.generate()
    trp_slug = run_slug("trp-exact")
    TestStub.seed_org(trp_id, trp_slug)
    NoizuPromptLingua.TRP.Cache.bust_prefix([:orgs, :list])

    assert Organizations.get_id_by_slug(trp_slug) == trp_id
  end

  test "a local row created after a TRP miss resolves immediately (no negative cache)" do
    slug = run_slug("late-local")

    # Miss BEFORE the row exists (TRP stub knows nothing).
    assert {:error, :not_found} = Organizations.resolve_org_id(slug)

    # The row lands; the same slug must resolve (Cache.fetch never stores
    # misses, so nothing shadows the local resolve).
    org = Repo.insert!(%Organization{name: "Late Local", slug: slug})

    assert {:ok, id} = Organizations.resolve_org_id(slug)
    assert id == org.id
  end
end
