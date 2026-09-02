defmodule NoizuPromptLinguaWeb.ToolSetProfilesValidateTest do
  @moduledoc """
  N4b controller contract (PRD-N4 AC-N4-6..8): the validate dry-run
  (Validator.compile/3 against the LIVE catalog — 200 warnings | 422 issues,
  never persists), save-time config rejection behind `:tool_sets_enabled`
  (R8), the D1-correct `effective` show preview (cross-checked against a live
  `handle_list_tools/2` for an equivalent caller), the arg-enum seeds and the
  real-groups group-options feed.

  Fixtures are real catalog tools: `Markdown.Convert` (markdown group; enum
  arg `type` = auto/url/html/markdown, required string `source`) and its
  sibling `Markdown.View`.
  """

  use NoizuPromptLinguaWeb.ConnCase
  @moduletag :capture_log

  alias Noizu.MCP.Ctx
  alias NoizuPromptLingua.Authz.ScopedMemberships
  alias NoizuPromptLingua.MCP.PrincipalMapper
  alias NoizuPromptLingua.MCP.ToolSetEndpoint
  alias NoizuPromptLingua.MCP.ToolSets
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Authz.ScopedMembership

  @base "/api/v1/organizations"

  # Serving-shaped config: rename + enum prune + arg rename on a REAL tool
  # (the same shape the N3 endpoint e2e drives through handle_list_tools).
  @valid_config %{
    "groups" => %{
      "markdown" => %{
        "enabled" => true,
        "tools" => %{
          "Markdown.Convert" => %{
            "name" => "md_convert",
            "args" => %{
              "source" => %{"rename" => "input"},
              "type" => %{"enum_remove" => ["html"]}
            }
          }
        }
      }
    }
  }

  @unknown_tool_config %{
    "groups" => %{
      "tickets" => %{"enabled" => true, "tools" => %{"Tickets_Create" => %{"name" => "nope"}}}
    }
  }

  setup %{conn: conn} do
    %{user: user, access_token: token} = setup_user_and_token()
    conn = authenticated_conn(conn, token)
    org_id = create_org(conn, "n4b")

    {:ok, conn: conn, user: user, org_id: org_id, base: "#{@base}/#{org_id}/tool-sets"}
  end

  # ---- AC-N4-6: validate dry-run ----

  describe "validate (FR-4-6)" do
    test "serving-shaped config -> 200 ok:true + warnings list", %{conn: conn, base: base} do
      %{"ok" => ok, "warnings" => warnings} =
        conn
        |> post("#{base}/validate", %{tool_set: %{"config" => @valid_config}})
        |> json_response(200)

      assert ok == true
      assert is_list(warnings)
    end

    test "inline config without persisting: row count unchanged across both outcomes", %{
      conn: conn,
      base: base
    } do
      before = row_count()

      conn
      |> post("#{base}/validate", %{tool_set: %{"config" => @valid_config}})
      |> json_response(200)

      conn
      |> post("#{base}/validate", %{tool_set: %{"config" => @unknown_tool_config}})
      |> json_response(422)

      assert row_count() == before
    end

    test "absent config -> 200 ok:true (empty candidate is valid)", %{conn: conn, base: base} do
      %{"ok" => true, "warnings" => warnings} =
        conn |> post("#{base}/validate", %{tool_set: %{}}) |> json_response(200)

      assert warnings == []
    end

    test "unknown tool -> 422 issue code unknown_tool", %{conn: conn, base: base} do
      %{"ok" => false, "issues" => issues} =
        conn
        |> post("#{base}/validate", %{tool_set: %{"config" => @unknown_tool_config}})
        |> json_response(422)

      issue = Enum.find(issues, &(&1["code"] == "unknown_tool"))
      assert issue
      assert issue["tool"] == "Tickets_Create"
      assert issue["message"] =~ "Tickets_Create"
    end

    test "enum superset -> 422 issue code prune_not_subset", %{conn: conn, base: base} do
      config =
        put_in(
          @valid_config,
          ["groups", "markdown", "tools", "Markdown.Convert", "args", "type", "enum_remove"],
          [
            "bogus"
          ]
        )

      %{"ok" => false, "issues" => issues} =
        conn |> post("#{base}/validate", %{tool_set: %{"config" => config}}) |> json_response(422)

      issue = Enum.find(issues, &(&1["code"] == "prune_not_subset"))
      assert issue
      # The lib's op-level checks carry the field, not the tool context.
      assert issue["field"] == "type"
      assert issue["meta"]["base"] == ["auto", "html", "markdown", "url"]
      assert issue["meta"]["values"] == ["bogus"]
    end

    test "equal wire names across two tools -> 422 issue code name_collision", %{
      conn: conn,
      base: base
    } do
      config = %{
        "groups" => %{
          "markdown" => %{
            "enabled" => true,
            "tools" => %{
              "Markdown.Convert" => %{"name" => "same_name"},
              "Markdown.View" => %{"name" => "same_name"}
            }
          }
        }
      }

      %{"ok" => false, "issues" => issues} =
        conn |> post("#{base}/validate", %{tool_set: %{"config" => config}}) |> json_response(422)

      issue = Enum.find(issues, &(&1["code"] == "name_collision"))
      assert issue
      assert is_list(issue["meta"]["tools"])
    end

    test "wire-name charset violation -> 422 issue code name_charset", %{conn: conn, base: base} do
      config =
        put_in(
          @valid_config,
          ["groups", "markdown", "tools", "Markdown.Convert", "name"],
          "bad name!"
        )

      %{"ok" => false, "issues" => issues} =
        conn |> post("#{base}/validate", %{tool_set: %{"config" => config}}) |> json_response(422)

      assert Enum.any?(issues, &(&1["code"] == "name_charset"))
    end

    test "unknown arg field -> 422 issue code unknown_field", %{conn: conn, base: base} do
      config =
        put_in(
          @valid_config,
          ["groups", "markdown", "tools", "Markdown.Convert", "args", "wibble"],
          %{
            "hide" => true
          }
        )

      %{"ok" => false, "issues" => issues} =
        conn |> post("#{base}/validate", %{tool_set: %{"config" => config}}) |> json_response(422)

      issue = Enum.find(issues, &(&1["code"] == "unknown_field"))
      assert issue
      assert issue["field"] == "wibble"
    end
  end

  # ---- R8: save-time rejection behind the serving flag ----

  describe "save-time rejection (R8)" do
    setup do
      Application.put_env(:noizu_prompt_lingua, :tool_sets_enabled, true)
      on_exit(fn -> Application.delete_env(:noizu_prompt_lingua, :tool_sets_enabled) end)
      :ok
    end

    test "create with an uncompilable config -> 422 ok:false issues; nothing stored", %{
      conn: conn,
      base: base,
      org_id: org_id
    } do
      before = row_count()

      %{"ok" => false, "issues" => issues} =
        conn
        |> post(base, %{tool_set: valid_attrs(%{"config" => @unknown_tool_config})})
        |> json_response(422)

      assert Enum.any?(issues, &(&1["code"] == "unknown_tool"))
      assert row_count() == before
      assert ToolSets.get_by_org_and_slug(org_id, "release-ops") == nil
    end

    test "create with a serving-shaped config still -> 201", %{conn: conn, base: base} do
      %{"tool_set" => tool_set} =
        conn
        |> post(base, %{tool_set: valid_attrs(%{"config" => @valid_config})})
        |> json_response(201)

      assert tool_set["slug"] == "release-ops"
    end

    test "update with an uncompilable config -> 422; stored config unchanged", %{
      conn: conn,
      base: base,
      org_id: org_id
    } do
      body =
        conn
        |> post(base, %{tool_set: valid_attrs(%{"config" => @valid_config})})
        |> json_response(201)

      slug = body["tool_set"]["slug"]
      digest = body["tool_set"]["config_digest"]

      %{"ok" => false, "issues" => issues} =
        conn
        |> patch("#{base}/#{slug}", %{tool_set: %{"config" => @unknown_tool_config}})
        |> json_response(422)

      assert Enum.any?(issues, &(&1["code"] == "unknown_tool"))

      stored = ToolSets.get_by_org_and_slug(org_id, slug)
      assert stored.config == @valid_config
    end
  end

  describe "save-time gate off (pre-flip posture)" do
    test "flag off: structural-only contract — unknown-tool config stores (N4a behavior)", %{
      conn: conn,
      base: base
    } do
      assert Application.get_env(:noizu_prompt_lingua, :tool_sets_enabled, false) == false

      %{"tool_set" => tool_set} =
        conn
        |> post(base, %{tool_set: valid_attrs(%{"config" => @unknown_tool_config})})
        |> json_response(201)

      assert tool_set["slug"] == "release-ops"
    end
  end

  # ---- AC-N4-7: effective preview (D1) ----

  describe "show effective preview (FR-4-7)" do
    test "renames, prunes, provenance and version; matches a live tools/list (D1)", %{
      conn: conn,
      base: base,
      org_id: org_id
    } do
      body =
        conn
        |> post(base, %{tool_set: valid_attrs(%{"config" => @valid_config})})
        |> json_response(201)

      slug = body["tool_set"]["slug"]

      %{"tool_set" => tool_set} = conn |> get("#{base}/#{slug}") |> json_response(200)
      effective = tool_set["effective"]

      assert is_binary(effective["version"])

      tool = Enum.find(effective["tools"], &(&1["name"] == "md_convert"))
      assert tool
      assert tool["base_name"] == "Markdown.Convert"
      assert tool["renamed"] == true
      assert tool["visible"] == true and tool["callable"] == true
      # enum_remove ["html"] — the removed value, keyed by the ORIGINAL field.
      assert tool["pruned_args"] == %{"type" => ["html"]}
      # set_name + field ops carry their static-layer provenance.
      assert Enum.any?(tool["provenance"], &(&1["op"] == "set_name"))
      assert Enum.any?(tool["provenance"], &(&1["field"] == "type"))

      # D1 cross-check: a live tools/list through the N3 endpoint for an
      # equivalent api-key caller names EXACTLY the visible subset of the
      # effective surface (protocol_list filters visible=false — statically
      # hidden tools like Project.Create never reach the wire; the admin
      # preview shows them, flagged).
      {:ok, wire_tools, _cursor} =
        ToolSetEndpoint.handle_list_tools(nil, ctx_for_set(slug, org_id))

      wire_names = MapSet.new(Enum.map(wire_tools, & &1.name))
      visible_names = MapSet.new(for t <- effective["tools"], t["visible"], do: t["name"])

      assert wire_names == visible_names

      assert Enum.any?(
               effective["tools"],
               &(&1["visible"] == false and &1["reason"] == "hidden_by_spec")
             )

      # ...and the effective ENUM matches too (names AND schemas, AC-N4-7).
      # (No type rename here — the wire property keeps the base key "type".)
      wire_convert = Enum.find(wire_tools, &(&1.name == "md_convert"))
      assert "html" not in wire_convert.input_schema["properties"]["type"]["enum"]
    end

    test "disabled tool renders visible/callable false", %{conn: conn, base: base} do
      # NOTE: pop_in here hands back {popped_value, map} — the map is SECOND.
      {_, config} =
        @valid_config
        |> put_in(["groups", "markdown", "tools", "Markdown.Convert", "enabled"], false)
        |> pop_in(["groups", "markdown", "tools", "Markdown.Convert", "name"])

      body =
        conn |> post(base, %{tool_set: valid_attrs(%{"config" => config})}) |> json_response(201)

      slug = body["tool_set"]["slug"]

      %{"tool_set" => tool_set} = conn |> get("#{base}/#{slug}") |> json_response(200)
      tool = Enum.find(tool_set["effective"]["tools"], &(&1["base_name"] == "Markdown.Convert"))

      assert tool["visible"] == false
      assert tool["callable"] == false
    end

    test "stored-but-invalid config (pre-flip) surfaces the lib's D5 issues", %{
      conn: conn,
      base: base
    } do
      # Passes the N2a structural changeset (a name is a free string) but
      # cannot COMPILE — the charset violation D5-disables the set at serve
      # time, and the preview surfaces the lib's own issues.
      config =
        put_in(
          @valid_config,
          ["groups", "markdown", "tools", "Markdown.Convert", "name"],
          "bad name!"
        )

      body =
        conn |> post(base, %{tool_set: valid_attrs(%{"config" => config})}) |> json_response(201)

      slug = body["tool_set"]["slug"]

      %{"tool_set" => tool_set} = conn |> get("#{base}/#{slug}") |> json_response(200)
      effective = tool_set["effective"]

      assert effective["tools"] == []
      assert Enum.any?(effective["issues"], &(&1["code"] == "name_charset"))
    end

    test "profile slugs carry the effective preview too", %{conn: conn, base: base} do
      %{"profile" => profile} = conn |> get("#{base}/full") |> json_response(200)

      assert is_binary(profile["effective"]["version"])
      assert length(profile["effective"]["tools"]) > 0
    end
  end

  # ---- arg-enum seeds ----

  describe "arg-enum helper" do
    test "returns the base enum values of a real enum arg", %{conn: conn, base: base} do
      %{"tool" => tool, "arg" => arg, "values" => values} =
        conn |> get("#{base}/arg-enum?tool=Markdown.Convert&arg=type") |> json_response(200)

      assert tool == "Markdown.Convert"
      assert arg == "type"
      assert values == ["auto", "url", "html", "markdown"]
    end

    test "non-enum arg -> 404 code not_enum", %{conn: conn, base: base} do
      %{"code" => code} =
        conn |> get("#{base}/arg-enum?tool=Markdown.Convert&arg=source") |> json_response(404)

      assert code == "not_enum"
    end

    test "unknown tool -> 404 code unknown_tool", %{conn: conn, base: base} do
      %{"code" => code} =
        conn |> get("#{base}/arg-enum?tool=Nope.Nothing&arg=type") |> json_response(404)

      assert code == "unknown_tool"
    end

    test "missing params -> 422", %{conn: conn, base: base} do
      assert json_response(get(conn, "#{base}/arg-enum"), 422)
    end
  end

  # ---- group selector completeness ----

  describe "group-options" do
    test "lists REAL authz groups with kind labels + expires_at-aware counts", %{
      conn: conn,
      base: base,
      org_id: org_id
    } do
      %{"groups" => before} = conn |> get("#{base}/group-options") |> json_response(200)
      assert length(before) > 0

      member_before = count_for(before, "member")
      admin_before = count_for(before, "admin")

      # Two active "member" memberships...
      %{user: m1} = setup_user_and_token()
      %{user: m2} = setup_user_and_token()
      {:ok, _} = ScopedMemberships.add_member("organization", org_id, m1.id, "member")
      {:ok, _} = ScopedMemberships.add_member("organization", org_id, m2.id, "member")

      # ...and one EXPIRED "admin" membership — it must not count.
      %{user: expired} = setup_user_and_token()
      {:ok, _} = insert_expired_membership(org_id, expired.id, "admin")

      %{"groups" => groups} = conn |> get("#{base}/group-options") |> json_response(200)
      by_name = Map.new(groups, &{&1["name"], &1})

      assert by_name["member"]["kind"] == "ladder_role"
      assert by_name["member"]["member_count"] == member_before + 2
      # Expired membership excluded (list_for_resource/2 filters expires_at).
      assert by_name["admin"]["member_count"] == admin_before
      # Every row exposes the group TABLE id — usable as a group-set group_id.
      assert is_binary(by_name["member"]["id"])
      assert by_name["member"]["display_name"]
    end

    test "group-options id works as a group-set group_id (selector round-trip)", %{
      conn: conn,
      base: base
    } do
      %{"groups" => groups} = conn |> get("#{base}/group-options") |> json_response(200)
      member = Enum.find(groups, &(&1["name"] == "member"))

      %{"tool_set" => tool_set} =
        conn
        |> post(base, %{
          tool_set: valid_attrs(%{"slug" => "via-options", "group_id" => member["id"]})
        })
        |> json_response(201)

      assert tool_set["shape"] == "group"
      assert tool_set["group_id"] == member["id"]
      assert tool_set["member_count"] != nil
    end
  end

  # ---- fixtures ----

  defp create_org(conn, prefix) do
    slug = "#{prefix}-#{System.unique_integer([:positive])}"

    conn
    |> post(@base, %{organization: %{slug: slug, name: "N4b #{prefix} org"}})
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

  defp row_count do
    Repo.aggregate(NoizuPromptLingua.Schema.MCPToolSet, :count, :id)
  end

  defp count_for(groups, name),
    do: (Enum.find(groups, &(&1["name"] == name)) || %{})["member_count"] || 0

  defp insert_group(name) do
    # `groups.name` is a postgres enum (role_name_enum) — only seeded role
    # groups exist, so reuse one instead of inserting (N2a tool_sets helper).
    case Repo.query!("SELECT id FROM groups WHERE name = $1 LIMIT 1", [name]) do
      %{rows: [[raw]]} ->
        Ecto.UUID.load!(raw)

      %{rows: []} ->
        %{rows: [[raw]]} =
          Repo.query!(
            "INSERT INTO groups (id, name, display_name, created_at, updated_at) " <>
              "VALUES (gen_random_uuid(), $1, $1, now(), now()) RETURNING id",
            [name]
          )

        Ecto.UUID.load!(raw)
    end
  end

  defp insert_expired_membership(org_id, user_id, role_name) do
    %ScopedMembership{}
    |> ScopedMembership.changeset(%{
      group_id: insert_group(role_name),
      resource_type: "organization",
      resource_id: org_id,
      member_type: "user",
      member_id: user_id,
      expires_at: DateTime.add(DateTime.utc_now(), -3600)
    })
    |> Repo.insert()
  end

  defp ctx_for_set(slug, org_id) do
    {:ok, principal} =
      PrincipalMapper.from_claims(%{
        "sub" => "user-1",
        "api_key_id" => "key-1",
        "set_slug" => slug,
        "set_org_id" => org_id
      })

    %Ctx{server: ToolSetEndpoint, auth: principal}
  end
end
