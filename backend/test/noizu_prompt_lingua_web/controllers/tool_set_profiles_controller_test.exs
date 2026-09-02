defmodule NoizuPromptLinguaWeb.ToolSetProfilesControllerTest do
  @moduledoc """
  N4a controller contract (PRD-N4 AC-N4-1..5): org-admin auth matrix, index
  composition (profiles from DATA + org sets with shape/member counts), CRUD
  happy paths + structural rejections, built-in immutability, clone semantics
  (profile + set sources, slug reservation), and the in-row `_audit` trail.
  """

  use NoizuPromptLinguaWeb.ConnCase
  @moduletag :capture_log

  alias NoizuPromptLingua.Authz.ScopedMemberships
  alias NoizuPromptLingua.MCP.ToolSets

  @base "/api/v1/organizations"

  @valid_config %{
    "groups" => %{
      "tickets" => %{
        "enabled" => true,
        "tools" => %{"Tickets_Create" => %{"name" => "create_ticket"}}
      }
    }
  }

  setup %{conn: conn} do
    %{user: user, access_token: token} = setup_user_and_token()
    conn = authenticated_conn(conn, token)
    org_id = create_org(conn, "n4a")

    {:ok, conn: conn, user: user, org_id: org_id, base: "#{@base}/#{org_id}/tool-sets"}
  end

  # ---- AC-N4-1: auth matrix ----

  describe "auth matrix" do
    test "unauthenticated request -> 401", %{base: base} do
      assert json_response(get(build_conn(), base), 401)
    end

    test "non-member -> 403", %{base: base} do
      %{access_token: token} = setup_user_and_token()
      assert json_response(get(authenticated_conn(build_conn(), token), base), 403)
    end

    test "viewer-role member -> 403 (below the admin bar)", %{base: base, org_id: org_id} do
      %{access_token: token, user: viewer} = setup_user_and_token()
      {:ok, _} = ScopedMemberships.add_member("organization", org_id, viewer.id, "viewer")

      assert json_response(get(authenticated_conn(build_conn(), token), base), 403)
    end

    test "cross-org slug -> 404 even for an admin of the querying org", %{
      conn: conn,
      base: base
    } do
      body = conn |> post(base, %{tool_set: valid_attrs()}) |> json_response(201)
      other_org = create_org(conn, "n4a-other")

      conn
      |> get("#{@base}/#{other_org}/tool-sets/#{body["tool_set"]["slug"]}")
      |> json_response(404)
    end
  end

  # ---- AC-N4-2: index composition ----

  describe "index" do
    test "lists the 5 built-in profiles from DATA, read-only + cloneable", %{
      conn: conn,
      base: base
    } do
      %{"profiles" => profiles} = conn |> get(base) |> json_response(200)

      assert length(profiles) == 5
      slugs = Enum.map(profiles, & &1["slug"])
      assert slugs == ~w(full agent-ops pm-dev content comms)

      full = Enum.find(profiles, &(&1["slug"] == "full"))
      assert full["cloneable"] == true
      assert full["editable"] == false
      assert full["is_profile"] == true
      assert full["group_count"] == 21
      assert length(full["groups"]) == 21
      assert full["tool_count"] > 0
    end

    test "lists org sets with shape and live member_count for group sets", %{
      conn: conn,
      base: base,
      org_id: org_id
    } do
      group_id = insert_group("member")
      %{user: m1} = setup_user_and_token()
      %{user: m2} = setup_user_and_token()
      {:ok, _} = ScopedMemberships.add_member("organization", org_id, m1.id, "member")
      {:ok, _} = ScopedMemberships.add_member("organization", org_id, m2.id, "member")

      conn
      |> post(base, %{tool_set: valid_attrs()})
      |> json_response(201)

      conn
      |> post(base, %{
        tool_set: valid_attrs(%{"slug" => "proj-set", "project_id" => Ecto.UUID.generate()})
      })
      |> json_response(201)

      group_set =
        (conn
         |> post(base, %{tool_set: valid_attrs(%{"slug" => "alpha-set", "group_id" => group_id})})
         |> json_response(201))["tool_set"]

      %{"sets" => sets} = conn |> get(base) |> json_response(200)
      by_slug = Map.new(sets, &{&1["slug"], &1})

      assert by_slug["release-ops"]["shape"] == "org"
      assert by_slug["release-ops"]["member_count"] == nil
      assert by_slug["proj-set"]["shape"] == "project"
      assert by_slug["alpha-set"]["shape"] == "group"
      assert by_slug["alpha-set"]["group_id"] == group_id
      assert by_slug["alpha-set"]["member_count"] == 2
    end

    test "deactivated set remains listed with is_active false (FR-4-3)", %{
      conn: conn,
      base: base
    } do
      body = conn |> post(base, %{tool_set: valid_attrs()}) |> json_response(201)
      slug = body["tool_set"]["slug"]
      conn |> post("#{base}/#{slug}/deactivate") |> json_response(200)

      %{"sets" => sets} = conn |> get(base) |> json_response(200)
      listed = Enum.find(sets, &(&1["slug"] == slug))

      assert listed
      assert listed["is_active"] == false
    end
  end

  # ---- AC-N4-3: CRUD ----

  describe "create" do
    test "creates a set -> 201 + view", %{conn: conn, base: base} do
      %{"tool_set" => tool_set} =
        conn |> post(base, %{tool_set: valid_attrs()}) |> json_response(201)

      assert tool_set["slug"] == "release-ops"
      assert tool_set["display_name"] == "Release Ops"
      assert tool_set["shape"] == "org"
      assert tool_set["is_active"] == true
      assert tool_set["source"] == "custom"
      assert tool_set["source_profile"] == nil
      assert tool_set["settings"]["allow_api_keys"] == true
      assert tool_set["settings"]["description_verbosity"] == "concise"
      assert is_binary(tool_set["config_digest"])
      assert String.length(tool_set["config_digest"]) == 12
    end

    test "duplicate slug -> 422 with slug field error", %{conn: conn, base: base} do
      conn |> post(base, %{tool_set: valid_attrs()}) |> json_response(201)

      %{"errors" => errors} =
        conn |> post(base, %{tool_set: valid_attrs()}) |> json_response(422)

      assert errors["slug"]
    end

    test "reserved profile slug -> 422 (changeset backstop)", %{conn: conn, base: base} do
      %{"errors" => errors} =
        conn
        |> post(base, %{tool_set: valid_attrs(%{"slug" => "full"})})
        |> json_response(422)

      assert errors["slug"]
    end

    test "unknown config vocabulary key -> 422 (structural only)", %{conn: conn, base: base} do
      bad_config =
        put_in(@valid_config, ["groups", "tickets", "tools", "Tickets_Create", "wibble"], true)

      %{"errors" => errors} =
        conn
        |> post(base, %{tool_set: valid_attrs(%{"config" => bad_config})})
        |> json_response(422)

      assert Enum.any?(errors["config"], &(&1 =~ "unknown key"))
    end

    test "unknown settings key -> 422", %{conn: conn, base: base} do
      attrs =
        valid_attrs(%{"settings" => %{"allow_api_keys" => true, "mystery_key" => 1}})

      %{"errors" => errors} = conn |> post(base, %{tool_set: attrs}) |> json_response(422)

      assert Enum.any?(errors["settings"], &(&1 =~ "unknown key"))
    end
  end

  describe "show" do
    test "returns the row with the N4b effective preview + audit trail", %{conn: conn, base: base} do
      body = conn |> post(base, %{tool_set: valid_attrs()}) |> json_response(201)
      slug = body["tool_set"]["slug"]

      %{"tool_set" => tool_set} =
        conn |> get("#{base}/#{slug}") |> json_response(200)

      assert tool_set["slug"] == slug
      # N4b: the D1-correct effective preview replaced the structural census.
      effective = tool_set["effective"]
      assert is_binary(effective["version"])
      assert length(effective["tools"]) > 0
      assert [%{"action" => "create"}] = tool_set["audit"]
    end

    test "profile slugs resolve to the read-only profile view + preview", %{
      conn: conn,
      base: base
    } do
      %{"profile" => profile} = conn |> get("#{base}/full") |> json_response(200)

      assert profile["is_profile"] == true
      assert profile["group_count"] == 21
      assert profile["preview"]["groups"]["tickets"]["overridden_tools"] == 0
    end

    test "unknown slug -> 404", %{conn: conn, base: base} do
      assert json_response(get(conn, "#{base}/never-existed"), 404)
    end
  end

  describe "update" do
    test "partial update applies; unsubmitted fields untouched", %{conn: conn, base: base} do
      body = conn |> post(base, %{tool_set: valid_attrs()}) |> json_response(201)
      slug = body["tool_set"]["slug"]

      %{"tool_set" => updated} =
        conn
        |> patch("#{base}/#{slug}", %{tool_set: %{"display_name" => "Renamed"}})
        |> json_response(200)

      assert updated["display_name"] == "Renamed"

      %{"tool_set" => shown} = conn |> get("#{base}/#{slug}") |> json_response(200)
      assert shown["config_digest"] == body["tool_set"]["config_digest"]
      assert shown["settings"]["description_verbosity"] == "concise"
    end

    test "settings update preserves system keys and appends audit", %{
      conn: conn,
      base: base,
      user: user
    } do
      body = conn |> post(base, %{tool_set: valid_attrs()}) |> json_response(201)
      slug = body["tool_set"]["slug"]

      conn
      |> patch("#{base}/#{slug}", %{tool_set: %{"settings" => %{"allow_api_keys" => false}}})
      |> json_response(200)

      %{"tool_set" => shown} = conn |> get("#{base}/#{slug}") |> json_response(200)

      assert shown["settings"]["allow_api_keys"] == false
      assert shown["updated_by"] == user.id
      assert length(shown["audit"]) == 2
      assert List.last(shown["audit"])["action"] == "update"
    end

    test "re-activates a deactivated set via is_active (FR-4-3)", %{
      conn: conn,
      base: base,
      org_id: org_id
    } do
      body = conn |> post(base, %{tool_set: valid_attrs()}) |> json_response(201)
      slug = body["tool_set"]["slug"]
      conn |> post("#{base}/#{slug}/deactivate") |> json_response(200)
      assert ToolSets.get_for_request(org_id, slug) == nil

      conn
      |> patch("#{base}/#{slug}", %{tool_set: %{"is_active" => true}})
      |> json_response(200)

      assert ToolSets.get_for_request(org_id, slug)
    end

    test "profile slug -> 422 profile_read_only (FR-4-4)", %{conn: conn, base: base} do
      %{"code" => code} =
        conn
        |> patch("#{base}/full", %{tool_set: %{"display_name" => "Nope"}})
        |> json_response(422)

      assert code == "profile_read_only"
    end

    test "update with no recognized fields returns the row unchanged", %{conn: conn, base: base} do
      body = conn |> post(base, %{tool_set: valid_attrs()}) |> json_response(201)
      slug = body["tool_set"]["slug"]

      %{"tool_set" => tool_set} =
        conn |> patch("#{base}/#{slug}", %{tool_set: %{}}) |> json_response(200)

      assert tool_set["slug"] == slug
    end
  end

  describe "deactivate" do
    test "soft-kills the set; idempotent; serving path loses it (AC-2A-8)", %{
      conn: conn,
      base: base,
      org_id: org_id
    } do
      body = conn |> post(base, %{tool_set: valid_attrs()}) |> json_response(201)
      slug = body["tool_set"]["slug"]

      %{"tool_set" => tool_set} =
        conn |> post("#{base}/#{slug}/deactivate") |> json_response(200)

      assert tool_set["is_active"] == false
      assert ToolSets.get_for_request(org_id, slug) == nil

      conn |> post("#{base}/#{slug}/deactivate") |> json_response(200)
    end

    test "profile slug -> 422 profile_read_only", %{conn: conn, base: base} do
      %{"code" => code} = conn |> post("#{base}/agent-ops/deactivate") |> json_response(422)

      assert code == "profile_read_only"
    end

    test "unknown slug -> 404", %{conn: conn, base: base} do
      assert json_response(post(conn, "#{base}/never-existed/deactivate"), 404)
    end
  end

  # ---- clone ----

  describe "clone" do
    test "from a profile: deep-copied allowlist, provenance, auto-slug", %{
      conn: conn,
      base: base,
      org_id: org_id
    } do
      %{"tool_set" => tool_set} =
        conn |> post("#{base}/clone", %{source: "full"}) |> json_response(201)

      assert tool_set["slug"] == "full-copy"
      assert tool_set["source"] == "clone"
      assert tool_set["source_profile"] == "full"
      assert tool_set["is_active"] == true

      stored = ToolSets.get_by_org_and_slug(org_id, "full-copy")
      assert stored.source_profile == "full"
      assert map_size(stored.config["groups"]) == 21
      # FR-2A-7 allowlist shape: every expanded group enabled.
      assert Enum.all?(Map.values(stored.config["groups"]), &(&1 == %{"enabled" => true}))
    end

    test "from a profile twice: slug suffixes -copy-2 (org-wide namespace)", %{
      conn: conn,
      base: base
    } do
      conn |> post("#{base}/clone", %{source: "content"}) |> json_response(201)

      %{"tool_set" => second} =
        conn |> post("#{base}/clone", %{source: "content"}) |> json_response(201)

      assert second["slug"] == "content-copy-2"
    end

    test "from a set: config deep-copied, cloned_from provenance", %{
      conn: conn,
      base: base,
      org_id: org_id
    } do
      body = conn |> post(base, %{tool_set: valid_attrs()}) |> json_response(201)
      source = body["tool_set"]

      %{"tool_set" => clone} =
        conn
        |> post("#{base}/clone", %{
          source: source["slug"],
          tool_set: %{"display_name" => "My copy"}
        })
        |> json_response(201)

      assert clone["config_digest"] == source["config_digest"]
      assert clone["source"] == "clone"
      assert clone["source_profile"] == nil

      stored = ToolSets.get_by_org_and_slug(org_id, clone["slug"])
      assert stored.settings["cloned_from"] == source["slug"]
      assert stored.config == @valid_config
    end

    test "clone carries caller settings + audit without clobbering provenance", %{
      conn: conn,
      base: base,
      org_id: org_id
    } do
      body = conn |> post(base, %{tool_set: valid_attrs()}) |> json_response(201)
      source_slug = body["tool_set"]["slug"]

      %{"tool_set" => clone} =
        conn
        |> post("#{base}/clone", %{
          source: source_slug,
          tool_set: %{"settings" => %{"instructions" => "Be terse"}}
        })
        |> json_response(201)

      assert clone["settings"]["instructions"] == "Be terse"
      assert [%{"action" => "clone"}] = clone["audit"]

      # Provenance survives next to the caller settings (system keys win).
      stored = ToolSets.get_by_org_and_slug(org_id, clone["slug"])
      assert stored.settings["cloned_from"] == source_slug
      assert stored.settings["instructions"] == "Be terse"
      assert [%{"action" => "clone"} | _] = stored.settings["_audit"]
    end

    test "unknown source -> 404", %{conn: conn, base: base} do
      assert json_response(post(conn, "#{base}/clone", %{source: "nope"}), 404)
    end
  end

  # ---- AC-N4-5: audit ----

  describe "audit trail" do
    test "records actor + action per mutation and stays bounded at 20", %{
      conn: conn,
      base: base,
      user: user
    } do
      body = conn |> post(base, %{tool_set: valid_attrs()}) |> json_response(201)
      slug = body["tool_set"]["slug"]

      # 25 sequential mutations: 1 create + 25 updates -> trail capped at 20.
      Enum.each(1..25, fn n ->
        conn
        |> patch("#{base}/#{slug}", %{tool_set: %{"description" => "v#{n}"}})
        |> json_response(200)
      end)

      %{"tool_set" => shown} = conn |> get("#{base}/#{slug}") |> json_response(200)

      assert length(shown["audit"]) == 20
      assert Enum.all?(shown["audit"], &(&1["actor"] == user.id))
      assert List.last(shown["audit"])["action"] == "update"
      # Older entries rotated off (bounded, last 20).
      assert shown["description"] == "v25"
    end
  end

  # ---- fixtures ----

  defp create_org(conn, prefix) do
    slug = "#{prefix}-#{System.unique_integer([:positive])}"

    conn
    |> post(@base, %{organization: %{slug: slug, name: "N4a #{prefix} org"}})
    |> json_response(201)
    |> get_in(["organization", "id"])
  end

  defp valid_attrs(overrides \\ %{}) do
    Map.merge(
      %{
        "slug" => "release-ops",
        "display_name" => "Release Ops",
        "description" => "Release tooling",
        "config" => @valid_config,
        "settings" => %{"allow_api_keys" => true, "description_verbosity" => "concise"}
      },
      overrides
    )
  end

  defp insert_group(name) do
    # `groups.name` is a postgres enum (role_name_enum) — only seeded role
    # groups exist, so reuse one instead of inserting (N2a tool_sets helper).
    case NoizuPromptLingua.Repo.query!("SELECT id FROM groups WHERE name = $1 LIMIT 1", [name]) do
      %{rows: [[raw]]} ->
        Ecto.UUID.load!(raw)

      %{rows: []} ->
        %{rows: [[raw]]} =
          NoizuPromptLingua.Repo.query!(
            "INSERT INTO groups (id, name, display_name, created_at, updated_at) " <>
              "VALUES (gen_random_uuid(), 'member', 'Member', now(), now()) RETURNING id",
            []
          )

        Ecto.UUID.load!(raw)
    end
  end
end
