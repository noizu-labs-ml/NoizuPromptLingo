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

  test "unconfigured TRP renders the graceful error family (no crash)" do
    # Live regression (stage, 2026-09-04): with TRP un-activated the client
    # returns `{:error, :trp_not_configured}` where the handler expected a
    # shaped org map — BadMapError → opaque "Tool execution failed". The
    # handler must render the error family instead.
    prev_trp = Application.get_env(:noizu_prompt_lingua, :trp)
    # Empty strings defeat Config.configured? even if the host exports
    # TRP_API_BASE_URL (the app-env value wins over the System fallback).
    Application.put_env(:noizu_prompt_lingua, :trp, base_url: "", shared_key: "")
    Cache.clear()

    # Local row so ref resolution reaches the TRP leg instead of nil-ing out.
    org_uuid = Ecto.UUID.generate()

    %NoizuPromptLingua.Schema.Organizations.Organization{id: org_uuid, name: "trp-off", slug: "trp-off-#{System.unique_integer([:positive])}"}
    |> NoizuPromptLingua.Repo.insert!()

    try do
      assert {:error, "PM backend not configured"} =
               OrganizationGet.call(%{"organization" => org_uuid}, %{})
    after
      if prev_trp, do: Application.put_env(:noizu_prompt_lingua, :trp, prev_trp)
      Cache.clear()
    end
  end
end
