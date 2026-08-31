defmodule NoizuPromptLinguaWeb.OrgSlugLengthTest do
  @moduledoc """
  End-to-end proof that an organization whose slug is exactly sixteen
  characters is reachable through the org-scoped API.

  The org slug is the primary URL segment for the whole multi-tenant API, and
  every org-scoped request funnels through
  `NoizuPromptLingua.Organizations.resolve_org_id/1`. That resolver used
  `Ecto.UUID.cast/1` as its id-or-slug discriminator, which also accepts a raw
  16-byte binary — so a 16-character slug was classified as a UUID and
  **passed straight through as the organization id**. Every downstream query
  then filtered `organization_id == "acme-corporation"` and matched nothing:
  the org existed, and its owner was locked out of all of it.

  Fifteen and seventeen characters were always fine. Those are here as the
  controls — without them a single failing case reads as an unrelated defect
  rather than as the length boundary it is.

  Written in its own file rather than by editing an existing controller test,
  so the length boundary is the subject rather than incidental to one.

  Projects are the probe because they are the plainest org-scoped resource:
  `ProjectController.index/2` does `resolve_org_id` then `authorize` then a
  list scoped to the resolved id, which is exactly the path that broke.
  """
  use NoizuPromptLinguaWeb.ConnCase

  # Slugs must be unique *across runs*, not just within one: the org slug ->
  # UUID map is cached in Redis with an hour TTL, and the Ecto sandbox does not
  # roll Redis back. A slug reused by a later run resolves, from cache, to the
  # org id of the earlier run — which the rollback already destroyed — and the
  # request 403s on a membership check against a row that no longer exists.
  #
  # This must NOT come from `:rand` (Enum.random, :rand.uniform). ExUnit seeds
  # `:rand` per test, so under a fixed `--seed` two runs generate the *same*
  # slugs and the second run reads the first run's stale cache entries. That is
  # not hypothetical: it is what an earlier version of this file did, and it
  # made the 15- and 17-character controls fail while the 16-character case
  # passed — the exact inverse of the bug under test, which is a very
  # convincing way to be wrong. `:crypto.strong_rand_bytes/1` ignores the
  # ExUnit seed, so slugs are unique per run by construction.
  defp slug_of_length(n) do
    prefix = "o#{n}-"
    want = n - byte_size(prefix)

    random =
      :crypto.strong_rand_bytes(want)
      |> Base.encode32(case: :lower, padding: false)
      |> binary_part(0, want)

    slug = prefix <> random
    # The point of the whole file. If this ever drifts the test is meaningless.
    ^n = byte_size(slug)
    slug
  end

  setup %{conn: conn} do
    # W4 cutover: slug resolution reads the TRP org inventory (stub-backed).
    NoizuPromptLingua.TRP.Cache.clear()
    NoizuPromptLingua.TRP.TestStub.reset()
    %{access_token: token} = setup_user_and_token()
    {:ok, conn: authenticated_conn(conn, token)}
  end

  # Creates an org with a slug of exactly `length` bytes plus one project, and
  # returns {slug, org_uuid, project_name}. The project is created by *UUID* so
  # that only the read path under test depends on slug resolution.
  defp org_with_project(conn, length) do
    slug = slug_of_length(length)

    created =
      post(conn, "/api/v1/organizations", %{
        organization: %{slug: slug, name: "Len #{length} Org"}
      })

    org_id = json_response(created, 201)["organization"]["id"]
    NoizuPromptLingua.TRP.TestStub.seed_org(org_id, slug)

    project_name = "project-for-#{slug}"

    json_response(
      post(conn, "/api/v1/organizations/#{org_id}/projects", %{
        project: %{name: project_name, slug: "p-#{slug}"}
      }),
      201
    )

    {slug, org_id, project_name}
  end

  describe "org-scoped API addressed by slug" do
    for length <- [15, 16, 17] do
      @length length

      test "a #{length}-character org slug resolves to its own org", %{conn: conn} do
        {slug, org_id, project_name} = org_with_project(conn, @length)

        body = json_response(get(conn, "/api/v1/organizations/#{slug}/projects"), 200)

        # The org resolved to *itself*, and we can see its project. Pre-fix, a
        # 16-character slug was passed through as the org id verbatim, so
        # authorization was checked against a non-existent org and this
        # request never reached 200.
        assert [project] = body["projects"]
        assert project["name"] == project_name
        assert project["organization_id"] == org_id
      end
    end

    test "the canonical UUID form still works, unchanged", %{conn: conn} do
      # The fix is purely additive: a real 36-character UUID must behave
      # exactly as before.
      {_slug, org_id, project_name} = org_with_project(conn, 16)

      body = json_response(get(conn, "/api/v1/organizations/#{org_id}/projects"), 200)

      assert [project] = body["projects"]
      assert project["name"] == project_name
      assert project["organization_id"] == org_id
    end

    test "a 16-character slug resolves to its own org, not a neighbour", %{conn: conn} do
      # Two orgs, one of them 16 characters. The 16-character one must see
      # only its own project — the fix must resolve the slug exactly, not
      # broaden it.
      {slug_16, org_16, project_16} = org_with_project(conn, 16)
      {_slug_other, _org_other, project_other} = org_with_project(conn, 20)

      body = json_response(get(conn, "/api/v1/organizations/#{slug_16}/projects"), 200)

      assert [project] = body["projects"]
      assert project["name"] == project_16
      assert project["organization_id"] == org_16
      refute project["name"] == project_other
    end

    test "an unknown 16-character slug is still rejected, not passed through", %{conn: conn} do
      # The failure mode being fixed is a *false* id classification. A slug
      # that genuinely does not exist must still be rejected, and must not be
      # forwarded as if it were an org id.
      unknown = slug_of_length(16)
      conn = get(conn, "/api/v1/organizations/#{unknown}/projects")
      assert conn.status in [403, 404]
    end
  end
end
