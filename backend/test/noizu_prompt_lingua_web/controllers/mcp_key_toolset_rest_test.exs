defmodule NoizuPromptLinguaWeb.McpKeyToolsetRestTest do
  use NoizuPromptLinguaWeb.ConnCase

  # Per-key toolset REST: user-scoped (own keys) + admin (cross-user).
  # Masking rule: prefix only; key_hash / raw values never serialized.

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User

  setup %{conn: conn} do
    %{user: user, access_token: token} = setup_user_and_token()
    {:ok, conn: authenticated_conn(conn, token), user: user}
  end

  defp admin_user do
    uniq = System.unique_integer([:positive])

    user =
      %NoizuPromptLingua.Schema.Users.User{
        id: Ecto.UUID.generate(),
        email: "adm-#{uniq}@example.com",
        user_name: "adm#{uniq}",
        handle: "a#{uniq}",
        status: :active,
        role: :admin
      }
      |> Repo.insert!()

    session =
      %NoizuPromptLingua.Schema.Users.Sessions.UserSession{
        id: Ecto.UUID.generate(),
        user_id: user.id,
        status: :active,
        details: %{}
      }
      |> Repo.insert!()

    session_entity = %NoizuPromptLingua.Users.Sessions.UserSession{
      id: session.id,
      user: {:ref, NoizuPromptLingua.Users.User, user.id},
      status: :active,
      details: %{}
    }

    {:ok, token, _claims} =
      NoizuPromptLingua.Guardian.encode_and_sign(session_entity, %{},
        token_type: "access",
        ttl: {1, :hour}
      )

    %{user: user, token: token}
  end

  defp create_key(conn, attrs \\ %{}) do
    resp =
      conn
      |> post("/api/v1/auth/mcp-keys", %{key: Map.merge(%{label: "rest"}, attrs)})
      |> json_response(201)

    %{key: resp["key"], raw_key: resp["raw_key"]}
  end

  describe "user-scoped endpoints" do
    test "show returns masked key with toolset", %{conn: conn} do
      %{key: key} = create_key(conn)

      body = conn |> get("/api/v1/auth/mcp-keys/#{key["id"]}") |> json_response(200)

      assert body["key"]["id"] == key["id"]
      assert body["key"]["key_prefix"] == key["key_prefix"]
      assert Map.has_key?(body["key"], "toolset_config")
      refute Map.has_key?(body["key"], "key_hash")
      refute body["key"]["key_prefix"] == body["raw_key"]
    end

    test "show of another user's key 404s", %{conn: conn} do
      uniq = System.unique_integer([:positive])

      other =
        %NoizuPromptLingua.Schema.Users.User{
          id: Ecto.UUID.generate(),
          email: "x-#{uniq}@example.com",
          user_name: "x#{uniq}",
          handle: "x#{uniq}",
          status: :active
        }
        |> Repo.insert!()

      {:ok, other_key, _} =
        NoizuPromptLingua.MCPApiKeys.generate_api_key(other.id, "foreign")

      assert %{"error" => _} =
               conn |> get("/api/v1/auth/mcp-keys/#{other_key.id}") |> json_response(404)
    end

    test "update applies toolset_config, label, status", %{conn: conn} do
      %{key: key} = create_key(conn)

      body =
        conn
        |> patch("/api/v1/auth/mcp-keys/#{key["id"]}", %{
          label: "renamed",
          toolset_config: %{
            groups: %{
              tickets: %{tools: %{"Ticket.List" => %{disabled: true}}},
              projects: %{hidden: true}
            }
          }
        })
        |> json_response(200)

      assert body["key"]["label"] == "renamed"

      assert body["key"]["toolset_config"]["groups"]["tickets"]["tools"]["Ticket.List"][
               "disabled"
             ] == true

      assert body["key"]["toolset_config"]["groups"]["projects"]["hidden"] == true

      # absent toolset arg never wipes stored config
      body2 =
        conn
        |> patch("/api/v1/auth/mcp-keys/#{key["id"]}", %{label: "again"})
        |> json_response(200)

      assert body2["key"]["toolset_config"]["groups"]["projects"]["hidden"] == true
    end

    test "update via toolset_from_scope adopts scope config", %{conn: conn} do
      {:ok, scope} =
        NoizuPromptLingua.MCPCustomScopes.create(%{
          "slug" => "rest-adopt",
          "name" => "Rest Adopt",
          "config" => %{"groups" => %{"sessions" => %{"hidden" => true}}}
        })

      %{key: key} = create_key(conn)

      body =
        conn
        |> patch("/api/v1/auth/mcp-keys/#{key["id"]}", %{toolset_from_scope: scope.slug})
        |> json_response(200)

      assert body["key"]["toolset_config"]["groups"]["sessions"]["hidden"] == true
    end

    test "clone carries toolset, returns raw once", %{conn: conn} do
      toolset = %{groups: %{tickets: %{disabled: true}}}
      %{key: key} = create_key(conn, %{toolset_config: toolset})

      body =
        conn
        |> post("/api/v1/auth/mcp-keys/#{key["id"]}/clone", %{label: "twin"})
        |> json_response(201)

      assert body["key"]["label"] == "twin"
      assert body["key"]["toolset_config"]["groups"]["tickets"]["disabled"] == true
      assert is_binary(body["raw_key"]) and body["raw_key"] != ""
      assert body["key"]["id"] != key["id"]
    end
  end

  describe "admin endpoints" do
    setup %{conn: conn} do
      %{user: admin, token: admin_token} = admin_user()
      {:ok, admin_conn: authenticated_conn(conn, admin_token), admin: admin}
    end

    test "admin lists all keys and shows one by id", %{
      conn: conn,
      admin_conn: admin_conn,
      user: user
    } do
      %{key: _key} = create_key(conn)

      list = admin_conn |> get("/api/v1/admin/mcp-keys") |> json_response(200)
      assert Enum.any?(list["keys"], &(&1["user_id"] == user.id or &1["label"] == "rest"))
      refute Enum.any?(list["keys"], &Map.has_key?(&1, "key_hash"))

      shown = list["keys"] |> hd()
      body = admin_conn |> get("/api/v1/admin/mcp-keys/#{shown["id"]}") |> json_response(200)
      assert body["key"]["id"] == shown["id"]
    end

    test "admin updates toolset on any user's key", %{conn: conn, admin_conn: admin_conn} do
      %{key: key} = create_key(conn)

      body =
        admin_conn
        |> patch("/api/v1/admin/mcp-keys/#{key["id"]}", %{
          toolset_config: %{groups: %{chat: %{disabled: true}}}
        })
        |> json_response(200)

      assert body["key"]["toolset_config"]["groups"]["chat"]["disabled"] == true
      _ = conn
    end

    test "admin clones another user's key, optionally reassigning owner", %{
      conn: conn,
      admin_conn: admin_conn,
      admin: admin,
      user: user
    } do
      toolset = %{groups: %{wiki: %{hidden: true}}}
      %{key: key} = create_key(conn, %{toolset_config: toolset})

      body =
        admin_conn
        |> post("/api/v1/admin/mcp-keys/#{key["id"]}/clone", %{})
        |> json_response(201)

      assert body["key"]["toolset_config"]["groups"]["wiki"]["hidden"] == true
      cloned = NoizuPromptLingua.MCPApiKeys.get(body["key"]["id"])
      assert cloned.user_id == user.id

      body2 =
        admin_conn
        |> post("/api/v1/admin/mcp-keys/#{key["id"]}/clone", %{user_id: admin.id})
        |> json_response(201)

      cloned2 = NoizuPromptLingua.MCPApiKeys.get(body2["key"]["id"])
      assert cloned2.user_id == admin.id
    end

    test "non-admin caller is forbidden from admin key endpoints", %{conn: conn} do
      assert conn |> get("/api/v1/admin/mcp-keys") |> response(403)
    end
  end
end
