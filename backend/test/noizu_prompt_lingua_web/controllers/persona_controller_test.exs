defmodule NoizuPromptLinguaWeb.PersonaControllerTest do
  @moduledoc """
  HTTP contract for the org-scoped persona surface: CRUD plus the persona's
  journal (work log) and knowledge base subresources. Covers the authz matrix
  (viewer read-only / member write / non-member + unknown-org denials), the
  project-validation branch (via the TRP stub backing Projects.get_project/1),
  and the not-found paths for every id-addressed route.
  """

  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Authz.ScopedMemberships

  setup %{conn: conn} do
    %{user: user, access_token: token} = setup_user_and_token()
    conn = authenticated_conn(conn, token)

    slug = "persona-org-#{System.unique_integer([:positive])}"

    org_id =
      conn
      |> post("/api/v1/organizations", %{organization: %{slug: slug, name: "Persona Org"}})
      |> json_response(201)
      |> get_in(["organization", "id"])

    {:ok, conn: conn, user: user, org_id: org_id}
  end

  # ── index ─────────────────────────────────────────────────────────────────

  describe "GET index" do
    test "lists org personas with the status vocabulary", %{conn: conn, org_id: org_id} do
      post_persona(conn, org_id, %{slug: "alpha", name: "Alpha"})
      post_persona(conn, org_id, %{slug: "beta", name: "Beta", status: "archived", tags: ["ops"]})

      body = json_response(get(conn, "/api/v1/organizations/#{org_id}/personas"), 200)
      assert length(body["personas"]) == 2
      assert body["statuses"] == ["active", "archived"]
      names = Enum.map(body["personas"], & &1["name"])
      assert "Alpha" in names and "Beta" in names
    end

    test "status and tag filters narrow the list (empty-string filters ignored)", %{
      conn: conn,
      org_id: org_id
    } do
      post_persona(conn, org_id, %{slug: "flt-a", name: "A", tags: ["ops"]})
      post_persona(conn, org_id, %{slug: "flt-b", name: "B", status: "archived"})

      body =
        json_response(get(conn, "/api/v1/organizations/#{org_id}/personas?status=archived"), 200)

      assert Enum.map(body["personas"], & &1["slug"]) == ["flt-b"]

      body = json_response(get(conn, "/api/v1/organizations/#{org_id}/personas?tag=ops"), 200)
      assert Enum.map(body["personas"], & &1["slug"]) == ["flt-a"]

      body = json_response(get(conn, "/api/v1/organizations/#{org_id}/personas?status="), 200)
      assert length(body["personas"]) == 2
    end

    test "project_id returns the effective list (project + org-level)", %{
      conn: conn,
      org_id: org_id
    } do
      # Seed the project under THIS org's id so validate_project's
      # organization_id comparison matches. Bust the TRP read cache first —
      # the shared ETS may hold a stale org list from an earlier test.
      _ = NoizuPromptLingua.TRP.TestStub.seed_org(org_id, "stub-pers")
      project_id = NoizuPromptLingua.TRP.TestStub.seed_project(org_id, %{name: "Eff"}).id

      NoizuPromptLingua.TRP.Cache.bust_prefix([:orgs])
      NoizuPromptLingua.TRP.Cache.bust_prefix([:project])

      %{"id" => org_scoped} = post_persona(conn, org_id, %{slug: "eff-org", name: "Org Level"})

      %{"id" => project_scoped, "project_id" => bound_project} =
        post_persona(conn, org_id, %{
          slug: "eff-proj",
          name: "Project Bound",
          project_id: project_id
        })

      assert bound_project == project_id

      # With a project_id the list is always the effective list: the project's
      # own personas folded together with org-level (no-project) ones.
      body =
        json_response(
          get(conn, "/api/v1/organizations/#{org_id}/personas?project_id=#{project_id}"),
          200
        )

      ids = Enum.map(body["personas"], & &1["id"])
      assert org_scoped in ids and project_scoped in ids
    end
  end

  # ── create ────────────────────────────────────────────────────────────────

  describe "POST create" do
    test "creates with the full attr set", %{conn: conn, org_id: org_id} do
      persona =
        post_persona(conn, org_id, %{
          slug: "full",
          name: "Full",
          role: "researcher",
          bio: "bio here",
          avatar: "https://example.com/a.png",
          tags: ["x", "y"]
        })

      assert persona["slug"] == "full"
      assert persona["role"] == "researcher"
      assert persona["bio"] == "bio here"
      assert persona["tags"] == ["x", "y"]
      assert persona["status"] == "active"
      assert persona["organization_id"] == org_id
      assert is_nil(persona["project_id"])
    end

    test "missing required slug -> 422 per-field errors", %{conn: conn, org_id: org_id} do
      body =
        conn
        |> post("/api/v1/organizations/#{org_id}/personas", %{persona: %{"name" => "No Slug"}})
        |> json_response(422)

      assert body["errors"]["slug"]
    end

    test "duplicate slug in the same org -> 422", %{conn: conn, org_id: org_id} do
      post_persona(conn, org_id, %{slug: "dup-slug", name: "First"})

      body =
        conn
        |> post("/api/v1/organizations/#{org_id}/personas", %{
          persona: %{slug: "dup-slug", name: "Second"}
        })
        |> json_response(422)

      # Composite unique_constraint([:organization_id, :slug]) reports on its
      # first field.
      assert body["errors"]["organization_id"] == ["has already been taken"]
    end

    test "project in another stub org -> 422 project mismatch", %{conn: conn, org_id: org_id} do
      other_stub = NoizuPromptLingua.TRP.TestStub.seed_org("stub-org-pers2", "stub-pers2")

      foreign_project =
        NoizuPromptLingua.TRP.TestStub.seed_project(other_stub, %{name: "Theirs"}).id

      body =
        conn
        |> post("/api/v1/organizations/#{org_id}/personas", %{
          persona: %{slug: "cross", name: "Cross", project_id: foreign_project}
        })
        |> json_response(422)

      assert body["error"] == "Project does not belong to this organization"
    end

    test "unknown project id -> 422 project mismatch", %{conn: conn, org_id: org_id} do
      body =
        conn
        |> post("/api/v1/organizations/#{org_id}/personas", %{
          persona: %{slug: "ghost", name: "Ghost", project_id: Ecto.UUID.generate()}
        })
        |> json_response(422)

      assert body["error"] == "Project does not belong to this organization"
    end
  end

  # ── show / update / delete ────────────────────────────────────────────────

  describe "show/update/delete" do
    test "show returns persona with journal + knowledge payload", %{conn: conn, org_id: org_id} do
      %{"id" => id} = post_persona(conn, org_id, %{slug: "showy", name: "Showy"})

      body = json_response(get(conn, "/api/v1/organizations/#{org_id}/personas/#{id}"), 200)
      assert body["persona"]["id"] == id
      assert body["journal"] == []
      assert body["knowledge_base"] == []
    end

    test "show unknown id -> 404", %{conn: conn, org_id: org_id} do
      assert json_response(
               get(conn, "/api/v1/organizations/#{org_id}/personas/#{Ecto.UUID.generate()}"),
               404
             )["error"]
    end

    test "a persona of another org is 404 under this org (no cross-org leak)", %{
      conn: conn,
      org_id: org_id
    } do
      # The same owner has a second org; its persona must not surface via org A.
      other_slug = "persona-org-#{System.unique_integer([:positive])}"

      other_org_id =
        conn
        |> post("/api/v1/organizations", %{organization: %{slug: other_slug, name: "Other"}})
        |> json_response(201)
        |> get_in(["organization", "id"])

      %{"id" => id} = post_persona(conn, other_org_id, %{slug: "theirs", name: "T"})

      assert json_response(get(conn, "/api/v1/organizations/#{org_id}/personas/#{id}"), 404)[
               "error"
             ] == "Persona not found"
    end

    test "update renames and reports validation errors", %{conn: conn, org_id: org_id} do
      %{"id" => id} = post_persona(conn, org_id, %{slug: "up", name: "Up"})

      body =
        conn
        |> put("/api/v1/organizations/#{org_id}/personas/#{id}", %{
          persona: %{name: "Renamed", bio: "new bio", status: "archived"}
        })
        |> json_response(200)

      assert body["persona"]["name"] == "Renamed"
      assert body["persona"]["bio"] == "new bio"
      assert body["persona"]["status"] == "archived"

      body =
        conn
        |> put("/api/v1/organizations/#{org_id}/personas/#{id}", %{persona: %{status: "bogus"}})
        |> json_response(422)

      assert body["errors"]["status"]
    end

    test "delete removes the persona, unknown id -> 404", %{conn: conn, org_id: org_id} do
      %{"id" => id} = post_persona(conn, org_id, %{slug: "gone", name: "G"})

      assert json_response(
               delete(conn, "/api/v1/organizations/#{org_id}/personas/#{id}"),
               200
             )["message"] == "Persona deleted"

      assert json_response(get(conn, "/api/v1/organizations/#{org_id}/personas/#{id}"), 404)

      assert json_response(
               delete(conn, "/api/v1/organizations/#{org_id}/personas/#{Ecto.UUID.generate()}"),
               404
             )["error"]
    end
  end

  # ── journal ───────────────────────────────────────────────────────────────

  describe "journal" do
    setup %{conn: conn, org_id: org_id} do
      %{"id" => persona_id} = post_persona(conn, org_id, %{slug: "jrnl", name: "J"})
      {:ok, persona_id: persona_id}
    end

    test "add entry stamps the actor and lists newest-first", %{
      conn: conn,
      user: user,
      org_id: org_id,
      persona_id: persona_id
    } do
      base = "/api/v1/organizations/#{org_id}/personas/#{persona_id}/journal"

      entry =
        conn
        |> post(base, %{entry: %{title: "t1", body: "did a thing", tags: ["w"]}})
        |> json_response(201)
        |> Map.get("entry")

      assert entry["title"] == "t1"
      assert entry["category"] == "work_log"
      assert entry["actor"] == user.id

      _ =
        conn
        |> post(base, %{entry: %{category: "decision", body: "chose A"}})
        |> json_response(201)

      listed = json_response(get(conn, base), 200)["journal"]
      assert length(listed) == 2
      # Same-second inserts make desc(inserted_at) order unstable; assert set.
      assert listed |> Enum.map(& &1["category"]) |> Enum.sort() == ["decision", "work_log"]

      filtered = json_response(get(conn, base <> "?category=work_log"), 200)["journal"]
      assert length(filtered) == 1
      assert hd(filtered)["title"] == "t1"
    end

    test "add entry validation: missing body and bad category -> 422", %{
      conn: conn,
      org_id: org_id,
      persona_id: persona_id
    } do
      base = "/api/v1/organizations/#{org_id}/personas/#{persona_id}/journal"

      assert json_response(post(conn, base, %{entry: %{title: "no body"}}), 422)["errors"]["body"]

      assert json_response(post(conn, base, %{entry: %{category: "nonsense", body: "x"}}), 422)[
               "errors"
             ]["category"]
    end

    test "delete entry, then again -> 404", %{conn: conn, org_id: org_id, persona_id: persona_id} do
      base = "/api/v1/organizations/#{org_id}/personas/#{persona_id}/journal"

      entry =
        conn |> post(base, %{entry: %{body: "temp"}}) |> json_response(201) |> Map.get("entry")

      assert json_response(delete(conn, base <> "/#{entry["id"]}"), 200)["message"] ==
               "Entry deleted"

      assert json_response(delete(conn, base <> "/#{entry["id"]}"), 404)["error"]
    end
  end

  # ── knowledge base ────────────────────────────────────────────────────────

  describe "knowledge base" do
    setup %{conn: conn, org_id: org_id} do
      %{"id" => persona_id} = post_persona(conn, org_id, %{slug: "kb", name: "K"})
      {:ok, persona_id: persona_id}
    end

    test "add, list (full shape), tag filter", %{
      conn: conn,
      org_id: org_id,
      persona_id: persona_id
    } do
      base = "/api/v1/organizations/#{org_id}/personas/#{persona_id}/knowledge"

      entry =
        post_entry(conn, base, %{
          slug: "kb-1",
          title: "Article",
          body: "text",
          tags: ["howto"],
          source: "manual"
        })

      assert entry["slug"] == "kb-1"
      assert entry["body"] == "text"
      assert entry["source"] == "manual"

      _ = post_entry(conn, base, %{slug: "kb-2", title: "Other", body: "b2", tags: ["ref"]})

      listed = json_response(get(conn, base), 200)["knowledge_base"]
      assert length(listed) == 2
      # Full shape includes body + timestamps.
      assert hd(listed)["body"]
      assert hd(listed)["updated_at"]

      filtered = json_response(get(conn, base <> "?tag=ref"), 200)["knowledge_base"]
      assert Enum.map(filtered, & &1["slug"]) == ["kb-2"]
    end

    test "show embeds knowledge summary (no body) in the persona payload", %{
      conn: conn,
      org_id: org_id,
      persona_id: persona_id
    } do
      base = "/api/v1/organizations/#{org_id}/personas/#{persona_id}"
      post_entry(conn, base <> "/knowledge", %{slug: "kb-s", title: "S", body: "secret body"})

      body = json_response(get(conn, base), 200)
      [kb] = body["knowledge_base"]
      assert kb["slug"] == "kb-s"
      # Summary shape: no body leakage.
      assert Map.has_key?(kb, "body") == false
    end

    test "duplicate slug -> 422; missing body -> 422", %{
      conn: conn,
      org_id: org_id,
      persona_id: persona_id
    } do
      base = "/api/v1/organizations/#{org_id}/personas/#{persona_id}/knowledge"
      post_entry(conn, base, %{slug: "kb-d", title: "D", body: "b"})

      assert json_response(
               post(conn, base, %{entry: %{slug: "kb-d", title: "D2", body: "b2"}}),
               422
             )["errors"]["persona_id"]

      assert json_response(post(conn, base, %{entry: %{slug: "kb-e", title: "E"}}), 422)["errors"][
               "body"
             ]
    end

    test "update entry, unknown entry -> 404", %{
      conn: conn,
      org_id: org_id,
      persona_id: persona_id
    } do
      base = "/api/v1/organizations/#{org_id}/personas/#{persona_id}/knowledge"
      entry = post_entry(conn, base, %{slug: "kb-u", title: "U", body: "old"})

      body =
        conn
        |> put(base <> "/#{entry["id"]}", %{entry: %{body: "new"}})
        |> json_response(200)

      assert body["entry"]["body"] == "new"
      assert body["entry"]["title"] == "U"

      assert json_response(
               put(conn, base <> "/#{Ecto.UUID.generate()}", %{entry: %{body: "x"}}),
               404
             )["error"]
    end

    test "delete entry, then again -> 404", %{conn: conn, org_id: org_id, persona_id: persona_id} do
      base = "/api/v1/organizations/#{org_id}/personas/#{persona_id}/knowledge"
      entry = post_entry(conn, base, %{slug: "kb-x", title: "X", body: "b"})

      assert json_response(delete(conn, base <> "/#{entry["id"]}"), 200)["message"] ==
               "Entry deleted"

      assert json_response(delete(conn, base <> "/#{entry["id"]}"), 404)["error"]
    end
  end

  # ── authz matrix ──────────────────────────────────────────────────────────

  describe "authz matrix" do
    setup %{conn: conn, org_id: org_id} do
      %{"id" => persona_id} = post_persona(conn, org_id, %{slug: "authz", name: "Z"})
      {:ok, persona_id: persona_id}
    end

    test "viewer can read everything but cannot write", %{
      org_id: org_id,
      persona_id: persona_id
    } do
      viewer = member_conn(org_id, "viewer")
      base = "/api/v1/organizations/#{org_id}/personas"

      assert json_response(get(viewer, base), 200)["personas"]
      assert json_response(get(viewer, "#{base}/#{persona_id}"), 200)["persona"]
      assert json_response(get(viewer, "#{base}/#{persona_id}/journal"), 200)["journal"]

      assert json_response(get(viewer, "#{base}/#{persona_id}/knowledge"), 200)["knowledge_base"]

      writes = [
        {:post, base, %{persona: %{slug: "v1", name: "V"}}},
        {:put, "#{base}/#{persona_id}", %{persona: %{name: "X"}}},
        {:delete, "#{base}/#{persona_id}", nil},
        {:post, "#{base}/#{persona_id}/journal", %{entry: %{body: "b"}}},
        {:delete, "#{base}/#{persona_id}/journal/#{Ecto.UUID.generate()}", nil},
        {:post, "#{base}/#{persona_id}/knowledge", %{entry: %{slug: "s", title: "t", body: "b"}}},
        {:put, "#{base}/#{persona_id}/knowledge/#{Ecto.UUID.generate()}", %{entry: %{body: "x"}}},
        {:delete, "#{base}/#{persona_id}/knowledge/#{Ecto.UUID.generate()}", nil}
      ]

      for {method, path, body} <- writes do
        resp =
          case method do
            :post -> post(viewer, path, body)
            :put -> put(viewer, path, body)
            :delete -> delete(viewer, path)
          end

        assert json_response(resp, 403)["error"] == "Insufficient permissions"
      end
    end

    test "member can create/update/delete (member bar)", %{
      org_id: org_id,
      persona_id: persona_id
    } do
      member = member_conn(org_id, "member")
      base = "/api/v1/organizations/#{org_id}/personas"

      assert json_response(post(member, base, %{persona: %{slug: "m1", name: "M"}}), 201)[
               "persona"
             ]["slug"] == "m1"

      assert json_response(put(member, "#{base}/#{persona_id}", %{persona: %{name: "MM"}}), 200)[
               "persona"
             ]["name"] == "MM"

      assert json_response(delete(member, "#{base}/#{persona_id}"), 200)["message"]
    end

    test "non-member is 403 not_a_member; unknown org slug 404; unknown org uuid 403", %{
      conn: conn,
      org_id: org_id
    } do
      %{access_token: token} = setup_user_and_token()
      outsider = authenticated_conn(Phoenix.ConnTest.build_conn(), token)

      assert json_response(get(outsider, "/api/v1/organizations/#{org_id}/personas"), 403)[
               "error"
             ] == "Not a member of this organization"

      assert json_response(get(conn, "/api/v1/organizations/no-such-org-xyz/personas"), 404)[
               "error"
             ] == "Organization not found"

      assert json_response(
               get(conn, "/api/v1/organizations/#{Ecto.UUID.generate()}/personas"),
               403
             )["error"]
    end
  end

  # ── helpers ───────────────────────────────────────────────────────────────

  defp post_persona(conn, org_id, attrs) do
    conn
    |> post("/api/v1/organizations/#{org_id}/personas", %{persona: attrs})
    |> json_response(201)
    |> Map.get("persona")
  end

  defp post_entry(conn, base, attrs) do
    conn |> post(base, %{entry: attrs}) |> json_response(201) |> Map.get("entry")
  end

  defp member_conn(org_id, role) do
    %{user: user, access_token: token} = setup_user_and_token()
    {:ok, _} = ScopedMemberships.add_member("organization", org_id, user.id, role)
    authenticated_conn(Phoenix.ConnTest.build_conn(), token)
  end
end
