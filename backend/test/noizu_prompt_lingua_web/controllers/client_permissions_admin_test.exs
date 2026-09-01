defmodule NoizuPromptLinguaWeb.ClientPermissionsAdminTest do
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User
  alias NoizuPromptLingua.Schema.McpApiKey
  alias NoizuPromptLingua.Schema.OAuthClient

  @user_ref_type "NoizuPromptLingua.Schema.Users.User"

  setup %{conn: conn} do
    %{user: user, access_token: token} = setup_user_and_token()
    Repo.get!(User, user.id) |> Ecto.Changeset.change(role: :admin) |> Repo.update!()
    {:ok, conn: authenticated_conn(conn, token), user: user}
  end

  defp create_scope(conn, slug) do
    post(conn, "/api/v1/admin/mcp-custom-scopes", %{
      scope: %{slug: slug, name: slug, description: "test scope", config: %{groups: %{}}}
    })
    |> json_response(201)
  end

  defp create_api_key(user_id, label) do
    %McpApiKey{}
    |> McpApiKey.create_changeset(%{
      user_id: user_id,
      label: label,
      key_prefix: "k#{:rand.uniform(9_999_999)}" |> String.slice(0, 8),
      key_hash: "h#{:rand.uniform(9_999_999)}" |> String.slice(0, 8)
    })
    |> Repo.insert!()
  end

  defp create_oauth_client(name) do
    %OAuthClient{}
    |> OAuthClient.changeset(%{
      client_id: "d3_#{name}_#{:rand.uniform(1_000_000)}",
      client_name: name,
      redirect_uris: ["http://localhost/callback"]
    })
    |> Repo.insert!()
  end

  # ── Auth gate ──────────────────────────────────────────────────────────────

  test "non-admin is blocked from client-permission endpoints", %{conn: conn} do
    %{user: _user, access_token: token} = setup_user_and_token()
    plain = authenticated_conn(conn, token)

    assert plain |> get("/api/v1/admin/mcp-custom-scopes/any/clients") |> response(403)
    assert plain |> get("/api/v1/admin/acl/groups") |> response(403)
    assert plain
           |> put("/api/v1/admin/mcp-custom-scopes/any/clients/api_key/none/toolset_config", %{
             toolset_config: %{}
           })
           |> response(403)
  end

  # ── Client listing ─────────────────────────────────────────────────────────

  test "lists api keys and oauth clients (linked: false — no scope association)", %{conn: conn} do
    create_scope(conn, "d3-clients")
    api_key = create_api_key(setup_user_and_token().user.id, "ci-runner")
    oauth = create_oauth_client("Claude Desktop")

    body =
      conn |> get("/api/v1/admin/mcp-custom-scopes/d3-clients/clients") |> json_response(200)

    assert %{"clients" => clients} = body
    api_entry = Enum.find(clients, &(&1["id"] == api_key.id))
    oauth_entry = Enum.find(clients, &(&1["id"] == oauth.id))

    assert api_entry["kind"] == "api_key"
    assert api_entry["label"] =~ "ci-runner"
    assert api_entry["status"] == "active"
    assert api_entry["linked"] == false

    assert oauth_entry["kind"] == "oauth_client"
    assert oauth_entry["label"] == "Claude Desktop"
    assert oauth_entry["linked"] == false
  end

  test "unknown scope slug 404s", %{conn: conn} do
    assert conn |> get("/api/v1/admin/mcp-custom-scopes/nope/clients") |> response(404)
  end

  # ── toolset_config read/write + normalization ──────────────────────────────

  test "PUT normalizes dotted keys to canonical underscore and persists", %{conn: conn} do
    create_scope(conn, "d3-toolset")
    api_key = create_api_key(setup_user_and_token().user.id, "normalizer")
    url = "/api/v1/admin/mcp-custom-scopes/d3-toolset/clients/api_key/#{api_key.id}/toolset_config"

    body =
      conn
      |> put(url, %{
        toolset_config: %{
          groups: %{
            sessions: %{
              tools: %{
                "Session.Create" => %{disabled: true},
                "Session_Create" => %{hidden: true}
              }
            }
          }
        }
      })
      |> json_response(200)

    tools = body["toolset_config"]["groups"]["sessions"]["tools"]
    # Canonical entry wins; the dotted alias merged under it, no dual spellings.
    assert Map.keys(tools) == ["Session_Create"]
    assert tools["Session_Create"]["disabled"] == true
    assert tools["Session_Create"]["hidden"] == true

    fetched = (conn |> get(url) |> json_response(200))["toolset_config"]
    assert fetched == body["toolset_config"]
  end

  test "PUT validates windows + override fields and rejects junk", %{conn: conn} do
    create_scope(conn, "d3-validate")
    api_key = create_api_key(setup_user_and_token().user.id, "validator")
    url = "/api/v1/admin/mcp-custom-scopes/d3-validate/clients/api_key/#{api_key.id}/toolset_config"

    valid = %{
      toolset_config: %{
        groups: %{
          sessions: %{
            hidden: true,
            tools: %{
              "Session_List" => %{
                name_override: "list_sessions",
                hide_until: "2030-01-01T00:00:00Z"
              }
            }
          }
        }
      }
    }

    body = conn |> put(url, valid) |> json_response(200)
    tool = body["toolset_config"]["groups"]["sessions"]["tools"]["Session_List"]
    assert tool["name_override"] == "list_sessions"
    assert tool["hide_until"] == "2030-01-01T00:00:00Z"

    assert conn
           |> put(url, %{toolset_config: %{groups: %{sessions: %{nope: true}}}})
           |> json_response(422)

    assert conn
           |> put(url, %{
             toolset_config: %{
               groups: %{sessions: %{tools: %{"Session_List" => %{bogus: true}}}}
             }
           })
           |> json_response(422)

    # Mutually exclusive windows rejected.
    assert conn
           |> put(url, %{
             toolset_config: %{
               groups: %{
                 sessions: %{
                   tools: %{"Session_List" => %{hide_until: "2030-01-01T00:00:00Z", enable_for_hours: 2}}
                 }
               }
             }
           })
           |> json_response(422)

    # Bad kinds / unknown clients 404.
    assert conn |> get("/api/v1/admin/mcp-custom-scopes/d3-validate/clients/widget/xyz/toolset_config") |> response(404)
    assert conn |> put("/api/v1/admin/mcp-custom-scopes/d3-validate/clients/api_key/00000000-0000-0000-0000-000000000000/toolset_config", %{toolset_config: %{}}) |> response(404)
  end

  test "PUT accepts fetched config back (enabled_at round-trip) and empty resets", %{conn: conn} do
    create_scope(conn, "d3-roundtrip")
    api_key = create_api_key(setup_user_and_token().user.id, "roundtrip")
    url = "/api/v1/admin/mcp-custom-scopes/d3-roundtrip/clients/api_key/#{api_key.id}/toolset_config"

    conn
    |> put(url, %{
      toolset_config: %{groups: %{sessions: %{tools: %{"Session_List" => %{enable_for_hours: 3}}}}}
    })
    |> json_response(200)

    fetched = (conn |> get(url) |> json_response(200))["toolset_config"]
    assert fetched["groups"]["sessions"]["tools"]["Session_List"]["enable_for_hours"] == 3
    # Windows are anchored by `set_at` since the F3 anchor migration
    # (legacy `enabled_at` is read-only fallback, never stamped on write).
    assert fetched["groups"]["sessions"]["tools"]["Session_List"]["set_at"]

    # Round-trip write of exactly what GET returned is accepted (no unknown-field
    # 422 — `set_at` is a known entry key). Re-writing a live window re-stamps
    # its `set_at` anchor (write contract: anchor slides to now), so compare
    # anchors-apart and assert the round-trip is still anchored.
    round = conn |> put(url, %{toolset_config: fetched}) |> json_response(200)
    {round_set_at, round_cfg} =
      pop_in(round["toolset_config"], ["groups", "sessions", "tools", "Session_List", "set_at"])

    {_fetched_set_at, fetched_cfg} =
      pop_in(fetched, ["groups", "sessions", "tools", "Session_List", "set_at"])

    assert round_cfg == fetched_cfg
    assert round_set_at

    # Empty map resets to inherit-everything.
    reset = conn |> put(url, %{toolset_config: %{}}) |> json_response(200)
    assert reset["toolset_config"] == %{}
  end

  test "oauth client toolset_config persists on the oauth_clients row", %{conn: conn} do
    create_scope(conn, "d3-oauth")
    oauth = create_oauth_client("OAuth Normalizer")
    url = "/api/v1/admin/mcp-custom-scopes/d3-oauth/clients/oauth_client/#{oauth.id}/toolset_config"

    body =
      conn
      |> put(url, %{toolset_config: %{groups: %{tickets: %{tools: %{"Ticket.List" => %{disabled: true}}}}}})
      |> json_response(200)

    assert body["toolset_config"]["groups"]["tickets"]["tools"]["Ticket_List"]["disabled"] == true
    assert Repo.reload!(oauth).toolset_config == body["toolset_config"]
  end

  # ── ACL groups ─────────────────────────────────────────────────────────────

  defp unique_name(prefix), do: "#{prefix}-#{:rand.uniform(1_000_000_000)}"

  test "group CRUD + membership (map and string ref forms)", %{conn: conn} do
    %{user: member} = setup_user_and_token()

    created =
      conn
      |> post("/api/v1/admin/acl/groups", %{group: %{name: unique_name("d3-crud"), description: "ops"}})
      |> json_response(201)

    assert %{"group" => %{"id" => group_id, "status" => "active"}} = created

    # Duplicate name rejected.
    assert conn
           |> post("/api/v1/admin/acl/groups", %{group: %{name: created["group"]["name"]}})
           |> json_response(422)

    listed = conn |> get("/api/v1/admin/acl/groups") |> json_response(200)
    assert Enum.any?(listed["groups"], &(&1["id"] == group_id))

    patched =
      conn
      |> patch("/api/v1/admin/acl/groups/#{group_id}", %{group: %{description: "renamed"}})
      |> json_response(200)

    assert patched["group"]["description"] == "renamed"

    # Add members — map form and opaque "type:id" string form.
    conn
    |> post("/api/v1/admin/acl/groups/#{group_id}/members", %{
      member: %{"type" => @user_ref_type, "id" => member.id}
    })
    |> json_response(201)

    conn
    |> post("/api/v1/admin/acl/groups/#{group_id}/members", %{member: "any:any"})
    |> json_response(201)

    with_members = conn |> get("/api/v1/admin/acl/groups") |> json_response(200)
    group = Enum.find(with_members["groups"], &(&1["id"] == group_id))
    assert length(group["members"]) == 2

    # Invalid ref → 422.
    assert conn
           |> post("/api/v1/admin/acl/groups/#{group_id}/members", %{member: "no-separator"})
           |> json_response(422)

    # Remove via string form.
    removed =
      conn
      |> delete("/api/v1/admin/acl/groups/#{group_id}/members", member: "any:any")
      |> json_response(200)

    assert removed["removed"] == 1

    after_remove = conn |> get("/api/v1/admin/acl/groups") |> json_response(200)
    group = Enum.find(after_remove["groups"], &(&1["id"] == group_id))
    assert length(group["members"]) == 1

    # Delete archives (soft) — group leaves the list, rows survive.
    assert conn |> delete("/api/v1/admin/acl/groups/#{group_id}") |> json_response(200)
    listed = conn |> get("/api/v1/admin/acl/groups") |> json_response(200)
    refute Enum.any?(listed["groups"], &(&1["id"] == group_id))

    assert conn
           |> patch("/api/v1/admin/acl/groups/#{group_id}", %{group: %{description: "x"}})
           |> response(404)
  end
end
