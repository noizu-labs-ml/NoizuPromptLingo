defmodule NoizuPromptLinguaWeb.CustomMCPGatewaySlugUrlsTest do
  @moduledoc """
  Slug-URL work (feat/slug-urls): the canonical org-addressed custom-MCP URL
  (`/org/:org_slug/custom/:slug/mcp`) plus the legacy alias contract —
  `/custom/:slug/mcp` never breaks: browser GETs of org-bound scopes 301 to the
  canonical form, everything else (MCP clients POST JSON-RPC) is served in
  place exactly as before.

  Unauthenticated requests that reach the MCP plug deterministically get its
  401 challenge, which is used here as the "served in place" marker — the
  gateway resolved the scope and handed off, versus 404 (not found / wrong org)
  and 301 (redirected).
  """
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLinguaWeb.Router

  setup do
    # Slug uniqueness must hold across runs: the org slug -> UUID map is
    # cached in Redis and the sandbox does not roll Redis back (same hazard as
    # org_slug_length_test). unique_integer is not ExUnit-seed derived.
    uniq = System.unique_integer([:positive])

    # Post-TRP-cutover the gateway resolves org slugs through the TRP shared-key
    # plane — point the client at the TestStub so created orgs resolve.
    prev_cfg = Application.get_env(:noizu_prompt_lingua, :trp)
    prev_transport = Application.get_env(:noizu_prompt_lingua, :trp_transport)

    Application.put_env(:noizu_prompt_lingua, :trp,
      base_url: "http://trp.test",
      shared_key: "trp_sk_test"
    )

    Application.put_env(:noizu_prompt_lingua, :trp_transport, NoizuPromptLingua.TRP.TestStub)
    NoizuPromptLingua.TRP.Cache.clear()
    NoizuPromptLingua.TRP.TestStub.reset()

    on_exit(fn ->
      if prev_cfg, do: Application.put_env(:noizu_prompt_lingua, :trp, prev_cfg)
      if prev_transport, do: Application.put_env(:noizu_prompt_lingua, :trp_transport, prev_transport)
    end)

    %{uniq: uniq, org_a: nil, org_b: nil}
  end

  # ---------------------------------------------------------------------------
  # Router shape
  # ---------------------------------------------------------------------------

  test "router exposes the canonical org-addressed path and the legacy alias" do
    paths = MapSet.new(Router.__routes__(), & &1.path)

    assert MapSet.member?(paths, "/org/:org_slug/custom/:slug/mcp")
    assert MapSet.member?(paths, "/custom/:slug/mcp")
  end

  # ---------------------------------------------------------------------------
  # Legacy alias: /custom/:slug/mcp
  # ---------------------------------------------------------------------------

  test "GET of a legacy org-bound scope 301s to the canonical org URL, query preserved", %{
    conn: conn,
    uniq: uniq
  } do
    {org, scope} = org_with_scope("w1a", uniq)

    conn = get(conn, "/custom/#{scope.slug}/mcp?x=1")

    assert conn.status == 301

    assert Plug.Conn.get_resp_header(conn, "location") == [
             "/org/#{org.slug}/custom/#{scope.slug}/mcp?x=1"
           ]
  end

  test "POST of a legacy org-bound scope is served in place, never redirected", %{
    conn: conn,
    uniq: uniq
  } do
    {_org, scope} = org_with_scope("w1b", uniq)

    conn = post(conn, "/custom/#{scope.slug}/mcp")

    # MCP clients cannot be relied on to re-issue a redirect — the alias must
    # keep serving. 401 = gateway resolved the scope and handed to the plug.
    assert conn.status == 401
    assert Plug.Conn.get_resp_header(conn, "location") == []
  end

  test "GET of a legacy org-less (global) scope is served in place, not redirected", %{
    conn: conn,
    uniq: uniq
  } do
    _scope = create_scope("w1g-#{uniq}", nil)

    conn = get(conn, "/custom/w1g-#{uniq}/mcp")

    assert conn.status == 401
    assert Plug.Conn.get_resp_header(conn, "location") == []
  end

  test "unknown legacy slug is a 404", %{conn: conn} do
    conn = get(conn, "/custom/w1-never-created/mcp")
    assert conn.status == 404
  end

  # ---------------------------------------------------------------------------
  # Canonical: /org/:org_slug/custom/:slug/mcp
  # ---------------------------------------------------------------------------

  test "org-addressed URL resolves by (org slug, slug)", %{conn: conn, uniq: uniq} do
    {_org, scope} = org_with_scope("w1c", uniq)

    conn = post(conn, "/org/#{org_slug("w1c", uniq)}/custom/#{scope.slug}/mcp")

    assert conn.status == 401
  end

  test "a scope is never served under a different org's URL", %{conn: conn, uniq: uniq} do
    {org_a, scope} = org_with_scope("w1d", uniq)
    _org_b = create_org(org_b_slug(uniq))

    conn = post(conn, "/org/#{org_b_slug(uniq)}/custom/#{scope.slug}/mcp")

    assert conn.status == 404
    # And the owner's org still resolves — the 404 is scoping, not absence.
    assert MCPCustomScopes.get_by_org_and_slug(org_a.id, scope.slug) != nil
  end

  test "unknown org slug is a 404", %{conn: conn, uniq: uniq} do
    scope = create_scope("w1e-#{uniq}", nil)

    conn = post(conn, "/org/w1-no-such-org-#{uniq}/custom/#{scope.slug}/mcp")
    assert conn.status == 404
  end

  test "known org but wrong slug is a 404", %{conn: conn, uniq: uniq} do
    {_org, _scope} = org_with_scope("w1f", uniq)

    conn = post(conn, "/org/#{org_slug("w1f", uniq)}/custom/w1-wrong-slug/mcp")
    assert conn.status == 404
  end

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  defp org_slug(prefix, uniq), do: "#{prefix}-org-#{uniq}"

  # Post-TRP-cutover (W4/W8) NPL keeps org rows in its own app DB — the
  # gateway's org-slug resolution reads them there; no pm_core repo involved.
  defp pm_repo_live? do
    is_pid(Process.whereis(NoizuPromptLingua.Repo))
  end

  defp create_org(slug) do
    %NoizuPromptLingua.Schema.Organizations.Organization{}
    |> Ecto.Changeset.change(%{slug: slug, name: "W1 Org #{slug}"})
    |> NoizuPromptLingua.Repo.insert()
    |> then(fn
      {:ok, org} -> org
      # Unique-violation on a re-run — the existing row is equally valid.
      {:error, _} -> NoizuPromptLingua.Repo.get_by!(NoizuPromptLingua.Schema.Organizations.Organization, slug: slug)
    end)
    |> tap(&NoizuPromptLingua.TRP.TestStub.seed_org(&1.id, slug))
  end

  defp create_scope(slug, org_id) do
    attrs =
      %{"slug" => slug, "name" => "W1 Scope #{slug}", "config" => %{"groups" => %{}}}
      |> then(fn a -> if org_id, do: Map.put(a, "organization_id", org_id), else: a end)

    {:ok, scope} = MCPCustomScopes.create(attrs)
    scope
  end

  defp org_with_scope(prefix, uniq) do
    unless pm_repo_live?() do
      raise "pm repo not live — run @tag :pm_live tests only when Noizu.PM.Repo is started"
    end

    org = create_org(org_slug(prefix, uniq))
    scope = create_scope("#{prefix}-scope-#{uniq}", org.id)
    {org, scope}
  end

  defp org_b_slug(uniq), do: "w1d-b-org-#{uniq}"
end
