defmodule NoizuPromptLingua.MCP.OrganizationGetTrpShapeTest do
  @moduledoc """
  Post-TRP-cutover regression: Organization.Get against the TRP org shape
  (`Shapes.organization` — id/slug/name/role/owner, no `settings`). The tool
  must not KeyError on the missing legacy key; the response keeps `settings`
  (defaulting to %{}) so the MCP contract stays stable, and surfaces the new
  `role`/`owner` fields.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.MCP.Organizations.Tools.OrganizationGet
  alias NoizuPromptLingua.TRP.Cache
  alias NoizuPromptLingua.TRP.TestStub

  setup do
    Cache.clear()
    TestStub.reset()

    # Slug resolution caches in the Redis-backed NoizuPromptLingua.Cache (1h TTL,
    # negative results included) — TRP.Cache.clear() above does NOT touch it, so
    # the slug must be unique per run or a stale slug→UUID entry 404s the stub.
    slug = "getorg-#{System.unique_integer([:positive])}"
    org_id = TestStub.seed_org(Ecto.UUID.generate(), slug)
    {:ok, org_id: org_id, slug: slug}
  end

  test "TRP-shaped org resolves without KeyError; settings defaults to %{}", %{slug: slug} do
    assert {:ok, org} = OrganizationGet.call(%{"organization" => slug}, %{})

    assert org.slug == slug
    assert is_binary(org.id)
    assert org.settings == %{}
  end

  test "resolves by UUID too", %{org_id: org_id, slug: slug} do
    assert {:ok, org} = OrganizationGet.call(%{"organization" => org_id}, %{})

    assert org.slug == slug
    assert org.settings == %{}
  end

  test "unknown org still errors gracefully" do
    assert {:error, "Organization 'nope' not found"} =
             OrganizationGet.call(%{"organization" => "nope"}, %{})
  end
end
