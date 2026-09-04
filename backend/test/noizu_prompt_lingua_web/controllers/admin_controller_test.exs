defmodule NoizuPromptLinguaWeb.AdminControllerTest do
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.OAuthClient
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.Schema.Users.User
  alias NoizuPromptLingua.Domains.Assets.MediaProviders
  alias NoizuPromptLingua.Domains.Marketing.Signups, as: MarketingSignups
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCPCustomScopes

  @admin "/api/v1/admin"

  setup %{conn: conn} do
    %{user: user, access_token: token} = setup_user_and_token()
    Repo.get!(User, user.id) |> Ecto.Changeset.change(role: :admin) |> Repo.update!()
    {:ok, conn: authenticated_conn(conn, token), user: user}
  end

  defp insert_user(overrides \\ %{}) do
    uniq = System.unique_integer([:positive])

    base = %{
      email: "u#{uniq}@example.com",
      user_name: "u#{uniq}",
      handle: "h#{uniq}",
      status: :active,
      verified: false,
      flagged: false
    }

    Repo.insert!(struct(User, Map.merge(base, overrides)))
  end

  defp org_fixture do
    uniq = System.unique_integer([:positive])
    Repo.insert!(%Organization{name: "Org #{uniq}", slug: "org-#{uniq}"})
  end

  defp key_fixture(user_id, label \\ "pat") do
    {:ok, key, _raw} = MCPApiKeys.generate_api_key(user_id, label)
    key
  end

  defp oauth_client_fixture do
    uniq = System.unique_integer([:positive])

    Repo.insert!(%OAuthClient{
      client_id: "cli-#{uniq}",
      client_name: "Test Client #{uniq}"
    })
  end

  # ── Auth matrix ────────────────────────────────────────────────────────────

  describe "admin surface auth" do
    test "401 without credentials" do
      conn = build_conn() |> get("#{@admin}/users")
      assert json_response(conn, 401)["error"] =~ "unauthenticated"
    end

    test "403 for authenticated non-admin", %{conn: conn} do
      %{access_token: token} = setup_user_and_token()

      conn
      |> authenticated_conn(token)
      |> get("#{@admin}/users")
      |> json_response(403)
      |> then(&assert(&1["error"] == "Admin access required"))
    end
  end

  # ── Users ──────────────────────────────────────────────────────────────────

  describe "users" do
    test "lists users with pagination echo", %{conn: conn, user: user} do
      body = conn |> get("#{@admin}/users?page=1&per_page=50") |> json_response(200)

      assert %{"users" => users, "total" => total, "page" => 1, "per_page" => 50} = body
      assert is_integer(total) and total >= 1
      assert Enum.any?(users, &(&1["email"] == user.email))
    end

    test "shows a user and returns 404 for unknown id", %{conn: conn, user: user} do
      body = conn |> get("#{@admin}/users/#{user.id}") |> json_response(200)
      assert body["user"]["email"] == user.email
      assert body["user"]["handle"] == user.handle

      conn |> get("#{@admin}/users/#{Ecto.UUID.generate()}") |> json_response(404)
    end

    test "updates another user's role", %{conn: conn} do
      other = insert_user()

      body =
        conn
        |> patch("#{@admin}/users/#{other.id}", %{user: %{role: "moderator"}})
        |> json_response(200)

      assert body["user"]["role"] == "moderator"
      assert Repo.get!(User, other.id).role == :moderator
    end

    test "refuses to change own role (self-lockout guard)", %{conn: conn, user: user} do
      conn
      |> patch("#{@admin}/users/#{user.id}", %{user: %{role: "user"}})
      |> json_response(403)
      |> then(&assert(&1["error"] =~ "cannot change your own role"))
    end

    test "rejects invalid role vocab", %{conn: conn} do
      other = insert_user()

      conn
      |> patch("#{@admin}/users/#{other.id}", %{user: %{role: "wizard"}})
      |> json_response(422)
      |> then(&assert(&1["error"] == "Invalid role"))
    end

    test "400 without user.role, 404 for unknown user", %{conn: conn} do
      conn
      |> patch("#{@admin}/users/#{Ecto.UUID.generate()}", %{})
      |> json_response(400)
      |> then(&assert(&1["error"] == "user.role required"))

      conn
      |> patch("#{@admin}/users/#{Ecto.UUID.generate()}", %{user: %{role: "moderator"}})
      |> json_response(404)
    end
  end

  # ── Organizations ──────────────────────────────────────────────────────────

  describe "organizations" do
    test "lists organizations", %{conn: conn} do
      org = org_fixture()
      body = conn |> get("#{@admin}/organizations") |> json_response(200)

      assert %{"organizations" => orgs, "total" => total} = body
      assert is_integer(total) and total >= 1
      assert Enum.any?(orgs, &(&1["slug"] == org.slug))
    end

    test "shows an organization with members, 404 unknown", %{conn: conn} do
      org = org_fixture()
      body = conn |> get("#{@admin}/organizations/#{org.id}") |> json_response(200)

      assert body["organization"]["slug"] == org.slug
      assert is_list(body["members"])

      conn |> get("#{@admin}/organizations/#{Ecto.UUID.generate()}") |> json_response(404)
    end
  end

  # ── GitHub integration ─────────────────────────────────────────────────────

  describe "github tokens" do
    test "create masks the token value, list, delete, 404 on re-delete", %{conn: conn} do
      org = org_fixture()

      created =
        conn
        |> post("#{@admin}/organizations/#{org.id}/github/tokens", %{
          token: %{label: "ci", token: "ghp_secret1234"}
        })
        |> json_response(201)

      token = created["token"]
      assert token["label"] == "ci"
      assert String.starts_with?(token["token_preview"], "ghp_")
      assert token["token_preview"] =~ "•"
      refute Map.has_key?(token, "token")
      refute created |> Jason.encode!() |> String.contains?("ghp_secret1234")

      listed =
        conn |> get("#{@admin}/organizations/#{org.id}/github/tokens") |> json_response(200)

      assert Enum.any?(listed["tokens"], &(&1["id"] == token["id"]))

      conn
      |> delete("#{@admin}/organizations/#{org.id}/github/tokens/#{token["id"]}")
      |> json_response(200)

      conn
      |> delete("#{@admin}/organizations/#{org.id}/github/tokens/#{token["id"]}")
      |> json_response(404)
    end

    test "422 when token params are missing", %{conn: conn} do
      org = org_fixture()

      conn
      |> post("#{@admin}/organizations/#{org.id}/github/tokens", %{token: %{label: "bare"}})
      |> json_response(422)
      |> then(&assert(Map.has_key?(&1, "errors")))
    end
  end

  describe "github repos + grants" do
    setup %{conn: conn} do
      org = org_fixture()

      {:ok, token} =
        Repo.insert(
          struct(NoizuPromptLingua.Schema.GithubToken, %{
            organization_id: org.id,
            label: "repo-pat",
            token: "ghp_repos"
          })
        )

      %{conn: conn, org: org, token: token}
    end

    test "repo CRUD round-trip", %{conn: conn, org: org, token: token} do
      created =
        conn
        |> post("#{@admin}/organizations/#{org.id}/github/repos", %{
          repo: %{repo_full_name: "noizu-labs/demo", token_id: token.id}
        })
        |> json_response(201)

      assert created["repo"]["repo_full_name"] == "noizu-labs/demo"
      assert created["repo"]["token_label"] == "repo-pat"
      assert created["repo"]["default_acl"] == "private"

      listed = conn |> get("#{@admin}/organizations/#{org.id}/github/repos") |> json_response(200)
      assert Enum.any?(listed["repos"], &(&1["id"] == created["repo"]["id"]))

      updated =
        conn
        |> patch("#{@admin}/organizations/#{org.id}/github/repos/#{created["repo"]["id"]}", %{
          repo: %{token_id: token.id}
        })
        |> json_response(200)

      assert updated["repo"]["token_label"] == "repo-pat"

      conn
      |> patch("#{@admin}/organizations/#{org.id}/github/repos/#{Ecto.UUID.generate()}", %{
        repo: %{token_id: token.id}
      })
      |> json_response(404)

      conn
      |> delete("#{@admin}/organizations/#{org.id}/github/repos/#{created["repo"]["id"]}")
      |> json_response(200)

      conn
      |> delete("#{@admin}/organizations/#{org.id}/github/repos/#{created["repo"]["id"]}")
      |> json_response(404)
    end

    test "422 when repo params are missing", %{conn: conn, org: org} do
      conn
      |> post("#{@admin}/organizations/#{org.id}/github/repos", %{repo: %{token_id: nil}})
      |> json_response(422)
      |> then(&assert(Map.has_key?(&1, "errors")))
    end

    test "grant/revoke access with level validation", %{conn: conn, org: org, token: token} do
      group =
        conn
        |> post("#{@admin}/acl/groups", %{group: %{name: "gh-grant-#{System.unique_integer()}"}})
        |> json_response(201)
        |> get_in(["group", "id"])

      repo =
        conn
        |> post("#{@admin}/organizations/#{org.id}/github/repos", %{
          repo: %{repo_full_name: "noizu-labs/grants", token_id: token.id}
        })
        |> json_response(201)
        |> get_in(["repo", "id"])

      granted =
        conn
        |> post("#{@admin}/organizations/#{org.id}/github/repos/#{repo}/grants", %{
          group_id: group,
          level: "write"
        })
        |> json_response(201)

      assert length(granted["grants"]) == 1
      assert is_binary(hd(granted["grants"])["id"])
      assert is_binary(hd(granted["grants"])["group_id"])

      listed =
        conn
        |> get("#{@admin}/organizations/#{org.id}/github/repos/#{repo}/grants")
        |> json_response(200)

      assert length(listed["grants"]) == 1

      grant_id =
        listed["grants"] |> hd() |> Map.get("id")

      conn
      |> delete("#{@admin}/organizations/#{org.id}/github/repos/#{repo}/grants/#{grant_id}")
      |> json_response(200)

      conn
      |> delete("#{@admin}/organizations/#{org.id}/github/repos/#{repo}/grants/#{grant_id}")
      |> json_response(404)

      conn
      |> post("#{@admin}/organizations/#{org.id}/github/repos/#{repo}/grants", %{
        group_id: group,
        level: "root"
      })
      |> json_response(400)
      |> then(&assert(&1["error"] =~ "read' or 'write"))
    end
  end

  # ── MCP API keys ───────────────────────────────────────────────────────────

  describe "user mcp keys" do
    test "creates a key (raw returned once) and rejects bad expires_at", %{conn: conn, user: user} do
      created =
        conn
        |> post("#{@admin}/users/#{user.id}/mcp-keys", %{key: %{label: "cli"}})
        |> json_response(201)

      assert created["raw_key"] not in [nil, ""]
      assert created["key"]["label"] == "cli"
      refute Map.has_key?(created["key"], "key_hash")

      conn
      |> post("#{@admin}/users/#{user.id}/mcp-keys", %{
        key: %{label: "bad", expires_at: "not-a-date"}
      })
      |> json_response(422)
      |> then(&assert(&1["error"] =~ "expires_at"))
    end

    test "lists and revokes user keys", %{conn: conn, user: user} do
      key = key_fixture(user.id, "revoke-me")

      listed =
        conn
        |> get("#{@admin}/users/#{user.id}/mcp-keys")
        |> json_response(200)

      assert Enum.any?(listed["keys"], &(&1["id"] == key.id))

      revoked =
        conn
        |> delete("#{@admin}/users/#{user.id}/mcp-keys/#{key.id}")
        |> json_response(200)

      assert revoked["key"]["status"] == "revoked"

      # revoking an already-revoked key is idempotent
      conn
      |> delete("#{@admin}/users/#{user.id}/mcp-keys/#{key.id}")
      |> json_response(200)

      conn
      |> delete("#{@admin}/users/#{user.id}/mcp-keys/#{Ecto.UUID.generate()}")
      |> json_response(404)
    end

    test "default MCP endpoint for a user", %{conn: conn, user: user} do
      body = conn |> get("#{@admin}/users/#{user.id}/mcp-default-endpoint") |> json_response(200)

      assert %{"scope" => scope, "servers" => [server | _], "ala_carte" => ala_carte} = body
      assert scope["slug"]
      assert server["required"] == true
      assert server["default"] == true
      assert is_list(ala_carte)
    end
  end

  describe "all mcp keys (admin surface)" do
    test "list/show/update/clone across users", %{conn: conn, user: user} do
      key = key_fixture(user.id, "admin-visible")

      listed = conn |> get("#{@admin}/mcp-keys") |> json_response(200)
      assert Enum.any?(listed["keys"], &(&1["id"] == key.id))

      shown = conn |> get("#{@admin}/mcp-keys/#{key.id}") |> json_response(200)
      assert shown["key"]["id"] == key.id

      updated =
        conn
        |> patch("#{@admin}/mcp-keys/#{key.id}", %{label: "renamed"})
        |> json_response(200)

      assert updated["key"]["label"] == "renamed"

      other = insert_user()

      cloned =
        conn
        |> post("#{@admin}/mcp-keys/#{key.id}/clone", %{user_id: other.id, label: "clone"})
        |> json_response(201)

      assert cloned["raw_key"] not in [nil, ""]
      assert Repo.get(NoizuPromptLingua.Schema.McpApiKey, cloned["key"]["id"]).user_id == other.id

      conn |> get("#{@admin}/mcp-keys/#{Ecto.UUID.generate()}") |> json_response(404)

      conn
      |> patch("#{@admin}/mcp-keys/#{Ecto.UUID.generate()}", %{label: "x"})
      |> json_response(404)

      conn
      |> post("#{@admin}/mcp-keys/#{Ecto.UUID.generate()}/clone", %{})
      |> json_response(404)
    end

    test "update can copy toolset from a scope", %{conn: conn, user: user} do
      slug = "ts-src-#{System.unique_integer([:positive])}"

      {:ok, _} =
        MCPCustomScopes.create(%{
          slug: slug,
          name: "TS Src",
          kind: "custom",
          config: %{groups: %{sessions: %{tools: %{"Session.Create" => %{disabled: true}}}}}
        })

      key = key_fixture(user.id, "toolset-src")

      updated =
        conn
        |> patch("#{@admin}/mcp-keys/#{key.id}", %{toolset_from_scope: slug})
        |> json_response(200)

      assert is_map(updated["key"]["toolset_config"])
      assert Map.has_key?(updated["key"]["toolset_config"], "groups")
    end
  end

  # ── OAuth clients ──────────────────────────────────────────────────────────

  describe "oauth clients" do
    test "lists and revokes clients", %{conn: conn} do
      client = oauth_client_fixture()

      listed = conn |> get("#{@admin}/oauth-clients") |> json_response(200)
      assert Enum.any?(listed["clients"], &(&1["client_id"] == client.client_id))

      revoked =
        conn
        |> delete("#{@admin}/oauth-clients/#{client.client_id}")
        |> json_response(200)

      assert revoked["client"]["status"] == "revoked"

      # revoke is idempotent; unknown ids 404
      conn |> delete("#{@admin}/oauth-clients/#{client.client_id}") |> json_response(200)
      conn |> delete("#{@admin}/oauth-clients/nonexistent") |> json_response(404)
    end
  end

  # ── LLM model catalog ──────────────────────────────────────────────────────

  describe "llm model catalog" do
    test "CRUD round-trip", %{conn: conn} do
      listed = conn |> get("#{@admin}/llm-models") |> json_response(200)
      assert is_list(listed["models"])

      created =
        conn
        |> post("#{@admin}/llm-models", %{
          model: %{provider: "stub", model: "stub-1", label: "Stub One", enabled: true}
        })
        |> json_response(201)

      assert created["model"]["provider"] == "stub"
      model_id = created["model"]["id"]

      updated =
        conn
        |> patch("#{@admin}/llm-models/#{model_id}", %{model: %{label: "Renamed"}})
        |> json_response(200)

      assert updated["model"]["label"] == "Renamed"

      conn
      |> patch("#{@admin}/llm-models/#{Ecto.UUID.generate()}", %{model: %{label: "x"}})
      |> json_response(404)

      conn
      |> post("#{@admin}/llm-models", %{model: %{provider: "stub", model: "no-label"}})
      |> json_response(422)
      |> then(&assert(Map.has_key?(&1, "errors")))

      conn |> delete("#{@admin}/llm-models/#{model_id}") |> json_response(200)
      conn |> delete("#{@admin}/llm-models/#{model_id}") |> json_response(404)
    end
  end

  # ── Marketing ──────────────────────────────────────────────────────────────

  describe "marketing settings + signups" do
    test "settings GET/PUT with cap coercion", %{conn: conn} do
      body = conn |> get("#{@admin}/marketing/settings") |> json_response(200)
      assert %{"settings" => _, "counts" => _} = body

      updated =
        conn
        |> put("#{@admin}/marketing/settings", %{
          settings: %{beta_signup_cap: "25", promo_cap: "", signups_open: false}
        })
        |> json_response(200)

      assert updated["settings"]["beta_signup_cap"] == 25
      assert updated["settings"]["promo_cap"] == nil
      assert updated["settings"]["signups_open"] == false
    end

    test "PUT rejects non-numeric caps and missing settings object", %{conn: conn} do
      conn
      |> put("#{@admin}/marketing/settings", %{settings: %{beta_signup_cap: "abc"}})
      |> json_response(422)
      |> then(&assert(Map.has_key?(&1, "errors")))

      conn
      |> put("#{@admin}/marketing/settings", %{nope: true})
      |> json_response(422)
      |> then(&assert(&1["error"] =~ "settings"))
    end

    test "signup listing with source filter and pagination defaults", %{conn: conn} do
      uniq = System.unique_integer([:positive])
      {:ok, _} = MarketingSignups.register_signup("demo#{uniq}@example.com", "demo")
      {:ok, _} = MarketingSignups.register_signup("landing#{uniq}@example.com", "landing")

      body = conn |> get("#{@admin}/marketing/signups") |> json_response(200)
      assert body["total"] >= 2
      assert body["page"] == 1

      filtered =
        conn
        |> get("#{@admin}/marketing/signups?source=demo")
        |> json_response(200)

      assert Enum.all?(filtered["signups"], &(&1["source"] == "demo"))

      defaulted =
        conn
        |> get("#{@admin}/marketing/signups?page=0&per_page=0")
        |> json_response(200)

      assert defaulted["page"] == 1 and defaulted["per_page"] == 50
    end
  end

  # ── Media providers ────────────────────────────────────────────────────────

  describe "media providers" do
    test "registry + config CRUD with api_key masking", %{conn: conn} do
      org = org_fixture()
      entry = hd(MediaProviders.registry())
      provider = to_string(entry.slug)

      listed =
        conn
        |> get("#{@admin}/organizations/#{org.id}/media-providers")
        |> json_response(200)

      assert Enum.any?(listed["registry"], &(&1["slug"] == provider))
      assert listed["configs"] == []

      created =
        conn
        |> post("#{@admin}/organizations/#{org.id}/media-providers", %{
          config: %{
            provider: provider,
            modality: to_string(entry.modality),
            api_key: "sk-supersecret",
            default_model: "m1",
            enabled: true
          }
        })
        |> json_response(201)

      assert created["config"]["api_key_set"] == true
      refute created |> Jason.encode!() |> String.contains?("sk-supersecret")
      config_id = created["config"]["id"]

      updated =
        conn
        |> patch("#{@admin}/organizations/#{org.id}/media-providers/#{config_id}", %{
          config: %{default_model: "m2"}
        })
        |> json_response(200)

      assert updated["config"]["default_model"] == "m2"
      assert updated["config"]["api_key_set"] == true

      relisted =
        conn
        |> get("#{@admin}/organizations/#{org.id}/media-providers")
        |> json_response(200)

      assert Enum.any?(relisted["configs"], &(&1["id"] == config_id))

      conn
      |> patch("#{@admin}/organizations/#{org.id}/media-providers/#{Ecto.UUID.generate()}", %{
        config: %{default_model: "x"}
      })
      |> json_response(404)

      conn
      |> delete("#{@admin}/organizations/#{org.id}/media-providers/#{Ecto.UUID.generate()}")
      |> json_response(404)

      conn
      |> delete("#{@admin}/organizations/#{org.id}/media-providers/#{config_id}")
      |> json_response(200)
    end
  end

  # ── Custom scopes ──────────────────────────────────────────────────────────

  describe "custom scopes (beyond the existing suite)" do
    test "list + show + 404s", %{conn: conn} do
      listed = conn |> get("#{@admin}/mcp-custom-scopes") |> json_response(200)
      assert Enum.any?(listed["scopes"], &(&1["slug"] == "tobor"))

      shown = conn |> get("#{@admin}/mcp-custom-scopes/tobor") |> json_response(200)
      assert shown["scope"]["slug"] == "tobor"

      conn
      |> get("#{@admin}/mcp-custom-scopes/nope-#{System.unique_integer()}")
      |> json_response(404)

      conn
      |> patch("#{@admin}/mcp-custom-scopes/nope-#{System.unique_integer()}", %{
        scope: %{name: "x"}
      })
      |> json_response(404)

      conn
      |> delete("#{@admin}/mcp-custom-scopes/nope-#{System.unique_integer()}")
      |> json_response(404)

      conn
      |> post("#{@admin}/mcp-custom-scopes/nope-#{System.unique_integer()}/clone", %{})
      |> json_response(404)
    end

    test "create rejects missing fields and missing scope object", %{conn: conn} do
      conn
      |> post("#{@admin}/mcp-custom-scopes", %{scope: %{slug: "no-name", kind: "custom"}})
      |> json_response(422)
      |> then(&assert(Map.has_key?(&1, "errors")))

      conn
      |> post("#{@admin}/mcp-custom-scopes", %{nope: true})
      |> json_response(400)
      |> then(&assert(&1["error"] == "scope required"))
    end

    test "update without scope object is a 400", %{conn: conn} do
      conn
      |> patch("#{@admin}/mcp-custom-scopes/tobor", %{nope: true})
      |> json_response(400)
      |> then(&assert(&1["error"] == "scope required"))
    end

    test "disabling a required core group on all_in_one requires typed confirmation", %{
      conn: conn,
      user: user
    } do
      slug = "aio-#{System.unique_integer([:positive])}"

      conn
      |> post("#{@admin}/mcp-custom-scopes", %{
        scope: %{slug: slug, name: "AIO", kind: "all_in_one", config: %{groups: %{}}}
      })
      |> json_response(201)

      denied =
        conn
        |> patch("#{@admin}/mcp-custom-scopes/#{slug}", %{
          scope: %{config: %{groups: %{sessions: %{disabled: true}}}}
        })
        |> json_response(422)

      assert denied["confirm_required"] == true
      assert "sessions" in denied["required_groups"]

      confirmed =
        conn
        |> patch("#{@admin}/mcp-custom-scopes/#{slug}", %{
          confirm: MCPCustomScopes.confirm_phrase(),
          scope: %{config: %{groups: %{sessions: %{disabled: true}}}}
        })
        |> json_response(200)

      entry = confirmed["scope"]["config"]["groups"]["sessions"]
      assert entry["disabled"] == true
      assert entry["disabled_confirmed_at"]
      assert entry["disabled_confirmed_by"] == user.id
    end

    test "account-default and org-default scopes cannot be deleted", %{conn: conn, user: user} do
      # account default (created via the default-endpoint probe)
      endpoint =
        conn |> get("#{@admin}/users/#{user.id}/mcp-default-endpoint") |> json_response(200)

      conn
      |> delete("#{@admin}/mcp-custom-scopes/#{endpoint["scope"]["slug"]}")
      |> json_response(403)
      |> then(&assert(&1["error"] =~ "cannot be deleted"))

      # org default
      org = org_fixture()
      org_scope = MCPCustomScopes.ensure_org_default(org.id)

      conn
      |> delete("#{@admin}/mcp-custom-scopes/#{org_scope.slug}")
      |> json_response(403)
    end
  end

  # ── Scope clients + per-client toolset_config ─────────────────────────────

  describe "scope clients + toolset_config" do
    setup %{user: user} do
      %{key: key_fixture(user.id, "client-pat"), client: oauth_client_fixture()}
    end

    test "lists api keys + oauth clients for a scope, 404 unknown slug", %{
      conn: conn,
      key: key,
      client: client
    } do
      slug = "clients-#{System.unique_integer([:positive])}"

      conn
      |> post("#{@admin}/mcp-custom-scopes", %{
        scope: %{slug: slug, name: "Clients", kind: "custom"}
      })
      |> json_response(201)

      listed = conn |> get("#{@admin}/mcp-custom-scopes/#{slug}/clients") |> json_response(200)

      api_entry = Enum.find(listed["clients"], &(&1["id"] == key.id))
      assert api_entry["kind"] == "api_key"
      assert api_entry["linked"] == false
      assert api_entry["label"] =~ "client-pat"

      oauth_entry = Enum.find(listed["clients"], &(&1["id"] == client.id))
      assert oauth_entry["kind"] == "oauth_client"
      assert oauth_entry["linked"] == false

      conn
      |> get("#{@admin}/mcp-custom-scopes/ghost-#{System.unique_integer()}/clients")
      |> json_response(404)
    end

    test "GET toolset_config defaults to empty map; unknown kind/id 404", %{conn: conn, key: key} do
      body =
        conn
        |> get("#{@admin}/mcp-custom-scopes/tobor/clients/api_key/#{key.id}/toolset_config")
        |> json_response(200)

      assert body["toolset_config"] == %{}

      conn
      |> get("#{@admin}/mcp-custom-scopes/tobor/clients/banana/#{key.id}/toolset_config")
      |> json_response(404)

      conn
      |> get(
        "#{@admin}/mcp-custom-scopes/tobor/clients/api_key/#{Ecto.UUID.generate()}/toolset_config"
      )
      |> json_response(404)
    end

    test "PUT stores canonicalized tool entries and round-trips", %{conn: conn, key: key} do
      url = "#{@admin}/mcp-custom-scopes/tobor/clients/api_key/#{key.id}/toolset_config"

      put =
        conn
        |> put(url, %{
          toolset_config: %{
            groups: %{
              sessions: %{tools: %{"session.create" => %{disabled: true, name_override: "SC"}}}
            }
          }
        })
        |> json_response(200)

      tools = put["toolset_config"]["groups"]["sessions"]["tools"]
      assert Map.has_key?(tools, "session_create")
      assert tools["session_create"]["disabled"] == true
      assert tools["session_create"]["disabled"] == true

      fetched = conn |> get(url) |> json_response(200)
      assert fetched["toolset_config"] == put["toolset_config"]

      # window entry with set_at anchor round-trips idempotently
      windowed =
        conn
        |> put(url, %{
          toolset_config: %{
            groups: %{
              sessions: %{
                tools: %{
                  "session_create" => %{
                    hide_until: "2099-01-01T00:00:00Z",
                    set_at: "2026-01-01T00:00:00Z"
                  }
                }
              }
            }
          }
        })
        |> json_response(200)

      assert windowed["toolset_config"]["groups"]["sessions"]["tools"]["session_create"][
               "hide_until"
             ] =~
               "2099"
    end

    test "PUT collapses dotted aliases into canonical keys", %{conn: conn, key: key} do
      url = "#{@admin}/mcp-custom-scopes/tobor/clients/api_key/#{key.id}/toolset_config"

      put =
        conn
        |> put(url, %{
          toolset_config: %{
            groups: %{
              sessions: %{
                tools: %{
                  "session.create" => %{disabled: true},
                  "session_create" => %{hidden: true}
                }
              }
            }
          }
        })
        |> json_response(200)

      # dotted (F5 alias) and canonical spellings collapse to one canonical key;
      # the canonical entry wins on per-field merge
      put =
        conn
        |> put(url, %{
          toolset_config: %{
            groups: %{
              sessions: %{
                tools: %{
                  "session.create" => %{disabled: true},
                  "session_create" => %{hidden: true}
                }
              }
            }
          }
        })
        |> json_response(200)

      tools = put["toolset_config"]["groups"]["sessions"]["tools"]
      assert map_size(tools) == 1
      entry = tools["session_create"]
      assert entry["disabled"] == true and entry["hidden"] == true
    end

    test "PUT empty config resets to %{}", %{conn: conn, key: key} do
      url = "#{@admin}/mcp-custom-scopes/tobor/clients/api_key/#{key.id}/toolset_config"

      conn
      |> put(url, %{toolset_config: %{groups: %{sessions: %{disabled: true}}}})
      |> json_response(200)

      reset = conn |> put(url, %{toolset_config: %{}}) |> json_response(200)
      assert reset["toolset_config"] == %{}
    end

    test "PUT validation errors surface as structured 422s", %{conn: conn, key: key} do
      url = "#{@admin}/mcp-custom-scopes/tobor/clients/api_key/#{key.id}/toolset_config"

      # unknown top-level field
      conn
      |> put(url, %{toolset_config: %{groups: %{}, wat: 1}})
      |> json_response(422)
      |> then(&assert(hd(&1["errors"]) =~ "unknown field"))

      # not an object with groups
      conn
      |> put(url, %{toolset_config: "nope"})
      |> json_response(422)
      |> then(&assert(hd(&1["errors"]) =~ "groups"))

      # group entry not an object
      conn
      |> put(url, %{toolset_config: %{groups: %{sessions: "nope"}}})
      |> json_response(422)
      |> then(&assert(hd(&1["errors"]) =~ "groups.sessions"))

      # unknown tool-entry field
      conn
      |> put(url, %{
        toolset_config: %{groups: %{sessions: %{tools: %{"session_create" => %{wat: 1}}}}}
      })
      |> json_response(422)
      |> then(&assert(hd(&1["errors"]) =~ "unknown field"))

      # disabled must be boolean
      conn
      |> put(url, %{toolset_config: %{groups: %{sessions: %{disabled: "yes"}}}})
      |> json_response(422)
      |> then(&assert(hd(&1["errors"]) =~ "boolean"))

      # name_override must be string
      conn
      |> put(url, %{
        toolset_config: %{
          groups: %{sessions: %{tools: %{"session_create" => %{name_override: 5}}}}
        }
      })
      |> json_response(422)
      |> then(&assert(hd(&1["errors"]) =~ "string"))

      # invalid window datetime
      conn
      |> put(url, %{
        toolset_config: %{
          groups: %{sessions: %{tools: %{"session_create" => %{hide_until: "soon"}}}}
        }
      })
      |> json_response(422)
      |> then(&assert(hd(&1["errors"]) =~ "invalid datetime"))

      # mutually exclusive window fields
      conn
      |> put(url, %{
        toolset_config: %{
          groups: %{
            sessions: %{
              tools: %{
                "session_create" => %{hide_until: "2099-01-01T00:00:00Z", enable_for_hours: 2}
              }
            }
          }
        }
      })
      |> json_response(422)
      |> then(&assert(hd(&1["errors"]) =~ "mutually exclusive"))
    end

    test "PUT missing toolset_config is 400; unknown client is 404", %{conn: conn, key: key} do
      conn
      |> put("#{@admin}/mcp-custom-scopes/tobor/clients/api_key/#{key.id}/toolset_config", %{
        nope: 1
      })
      |> json_response(400)
      |> then(&assert(&1["error"] == "toolset_config required"))

      conn
      |> put(
        "#{@admin}/mcp-custom-scopes/tobor/clients/api_key/#{Ecto.UUID.generate()}/toolset_config",
        %{
          toolset_config: %{groups: %{}}
        }
      )
      |> json_response(404)
    end

    test "oauth client toolset_config by row id and public client_id", %{
      conn: conn,
      client: client
    } do
      by_row =
        conn
        |> put(
          "#{@admin}/mcp-custom-scopes/tobor/clients/oauth_client/#{client.id}/toolset_config",
          %{
            toolset_config: %{groups: %{sessions: %{hidden: true}}}
          }
        )
        |> json_response(200)

      assert by_row["toolset_config"]["groups"]["sessions"]["hidden"] == true

      by_public =
        conn
        |> put(
          "#{@admin}/mcp-custom-scopes/tobor/clients/oauth-client/#{client.client_id}/toolset_config",
          %{
            toolset_config: %{groups: %{}}
          }
        )
        |> json_response(200)

      assert by_public["toolset_config"] == %{"groups" => %{}}
    end
  end

  # ── ACL groups ─────────────────────────────────────────────────────────────

  describe "acl groups" do
    test "create/list/update/archive round-trip", %{conn: conn} do
      created =
        conn
        |> post("#{@admin}/acl/groups", %{
          group: %{name: "ops-#{System.unique_integer()}", description: "ops"}
        })
        |> json_response(201)

      assert created["group"]["status"] == "active"
      assert created["group"]["members"] == []
      group_id = created["group"]["id"]

      listed = conn |> get("#{@admin}/acl/groups") |> json_response(200)
      assert Enum.any?(listed["groups"], &(&1["id"] == group_id))

      updated =
        conn
        |> patch("#{@admin}/acl/groups/#{group_id}", %{group: %{description: "updated"}})
        |> json_response(200)

      assert updated["group"]["description"] == "updated"

      conn
      |> patch("#{@admin}/acl/groups/#{Ecto.UUID.generate()}", %{group: %{name: "x"}})
      |> json_response(404)

      conn |> delete("#{@admin}/acl/groups/#{group_id}") |> json_response(200)

      # archive is idempotent
      conn |> delete("#{@admin}/acl/groups/#{group_id}") |> json_response(200)

      # archived groups no longer update
      conn
      |> patch("#{@admin}/acl/groups/#{group_id}", %{group: %{name: "x"}})
      |> json_response(404)
    end

    test "create without group object is 400", %{conn: conn} do
      conn
      |> post("#{@admin}/acl/groups", %{nope: 1})
      |> json_response(400)
      |> then(&assert(&1["error"] == "group required"))
    end

    test "member add/remove with ref maps and strings", %{conn: conn, user: user} do
      group =
        conn
        |> post("#{@admin}/acl/groups", %{group: %{name: "members-#{System.unique_integer()}"}})
        |> json_response(201)
        |> get_in(["group", "id"])

      added =
        conn
        |> post("#{@admin}/acl/groups/#{group}/members", %{
          member: %{type: "user", id: user.id},
          expires_at: "2030-01-01T00:00:00Z"
        })
        |> json_response(201)

      assert Enum.any?(added["group"]["members"], &(&1["ref_string"] == "user:#{user.id}"))

      other = insert_user()

      conn
      |> post("#{@admin}/acl/groups/#{group}/members", %{member: "user:#{other.id}"})
      |> json_response(201)

      removed =
        conn
        |> delete("#{@admin}/acl/groups/#{group}/members", %{member: "user:#{user.id}"})
        |> json_response(200)

      assert is_integer(removed["removed"])
    end

    test "duplicate member add surfaces the unique constraint as 422", %{conn: conn, user: user} do
      group =
        conn
        |> post("#{@admin}/acl/groups", %{group: %{name: "dupm-#{System.unique_integer()}"}})
        |> json_response(201)
        |> get_in(["group", "id"])

      conn
      |> post("#{@admin}/acl/groups/#{group}/members", %{member: %{type: "user", id: user.id}})
      |> json_response(201)

      conn
      |> post("#{@admin}/acl/groups/#{group}/members", %{member: %{type: "user", id: user.id}})
      |> json_response(422)
      |> then(&assert(Map.has_key?(&1, "errors")))
    end

    test "member validation errors", %{conn: conn, user: user} do
      group =
        conn
        |> post("#{@admin}/acl/groups", %{group: %{name: "mval-#{System.unique_integer()}"}})
        |> json_response(201)
        |> get_in(["group", "id"])

      conn
      |> post("#{@admin}/acl/groups/#{group}/members", %{member: "no-colon"})
      |> json_response(422)
      |> then(&assert(&1["error"] =~ "ERP ref"))

      conn
      |> post("#{@admin}/acl/groups/#{group}/members", %{
        member: %{type: "user", id: user.id},
        expires_at: "soon"
      })
      |> json_response(422)
      |> then(&assert(&1["error"] =~ "ISO8601"))

      conn
      |> post("#{@admin}/acl/groups/#{group}/members", %{})
      |> json_response(400)

      conn
      |> post("#{@admin}/acl/groups/#{Ecto.UUID.generate()}/members", %{
        member: %{type: "user", id: user.id}
      })
      |> json_response(404)

      conn
      |> delete("#{@admin}/acl/groups/#{group}/members", %{member: "bogus"})
      |> json_response(422)

      conn
      |> delete("#{@admin}/acl/groups/#{group}/members", %{})
      |> json_response(400)

      conn
      |> delete("#{@admin}/acl/groups/#{Ecto.UUID.generate()}/members", %{
        member: "user:#{user.id}"
      })
      |> json_response(404)
    end
  end

  # ── MCP prompts ────────────────────────────────────────────────────────────

  describe "mcp prompts" do
    test "CRUD + version publishing", %{conn: conn} do
      slug = "prompt-#{System.unique_integer([:positive])}"

      created =
        conn
        |> post("#{@admin}/mcp-prompts", %{
          prompt: %{slug: slug, name: "Prompt", description: "d"}
        })
        |> json_response(201)

      assert created["prompt"]["slug"] == slug

      listed = conn |> get("#{@admin}/mcp-prompts") |> json_response(200)
      assert Enum.any?(listed["prompts"], &(&1["slug"] == slug))

      updated =
        conn
        |> patch("#{@admin}/mcp-prompts/#{slug}", %{prompt: %{name: "Renamed"}})
        |> json_response(200)

      assert updated["prompt"]["name"] == "Renamed"

      published =
        conn
        |> post("#{@admin}/mcp-prompts/#{slug}/versions", %{
          template: "Hello {{name}}",
          change_note: "n1"
        })
        |> json_response(201)

      assert published["prompt"]["slug"] == slug

      conn
      |> post("#{@admin}/mcp-prompts/#{slug}/versions", %{version: %{template: "V2 {{x}}"}})
      |> json_response(201)

      conn
      |> post("#{@admin}/mcp-prompts/#{slug}/versions", %{change_note: "no template"})
      |> json_response(400)
      |> then(&assert(&1["error"] == "template required"))

      conn
      |> post("#{@admin}/mcp-prompts/ghost-#{System.unique_integer()}/versions", %{template: "t"})
      |> json_response(404)

      conn
      |> patch("#{@admin}/mcp-prompts/ghost-#{System.unique_integer()}", %{prompt: %{name: "x"}})
      |> json_response(404)

      conn
      |> patch("#{@admin}/mcp-prompts/#{slug}", %{nope: 1})
      |> json_response(400)

      conn |> delete("#{@admin}/mcp-prompts/#{slug}") |> json_response(200)
      conn |> delete("#{@admin}/mcp-prompts/#{slug}") |> json_response(404)
    end

    test "create without prompt object is 400", %{conn: conn} do
      conn
      |> post("#{@admin}/mcp-prompts", %{nope: 1})
      |> json_response(400)
      |> then(&assert(&1["error"] == "prompt required"))
    end
  end

  # ── MCP resources + templates ──────────────────────────────────────────────

  describe "mcp resources" do
    test "CRUD round-trip", %{conn: conn} do
      uri = "file:///res-#{System.unique_integer([:positive])}.txt"

      created =
        conn
        |> post("#{@admin}/mcp-resources", %{resource: %{uri: uri, name: "Res", content: "abc"}})
        |> json_response(201)

      assert created["resource"]["uri"] == uri
      resource_id = created["resource"]["id"]

      listed = conn |> get("#{@admin}/mcp-resources") |> json_response(200)
      assert Enum.any?(listed["resources"], &(&1["uri"] == uri))

      updated =
        conn
        |> patch("#{@admin}/mcp-resources/#{resource_id}", %{resource: %{name: "Res2"}})
        |> json_response(200)

      assert updated["resource"]["name"] == "Res2"

      conn
      |> patch("#{@admin}/mcp-resources/#{Ecto.UUID.generate()}", %{resource: %{name: "x"}})
      |> json_response(404)

      conn
      |> patch("#{@admin}/mcp-resources/#{resource_id}", %{nope: 1})
      |> json_response(400)

      conn
      |> post("#{@admin}/mcp-resources", %{nope: 1})
      |> json_response(400)

      conn |> delete("#{@admin}/mcp-resources/#{resource_id}") |> json_response(200)
      conn |> delete("#{@admin}/mcp-resources/#{resource_id}") |> json_response(404)
    end
  end

  describe "mcp resource templates" do
    test "CRUD round-trip", %{conn: conn} do
      template_uri = "file:///tpl-#{System.unique_integer([:positive])}/{path}"

      created =
        conn
        |> post("#{@admin}/mcp-resource-templates", %{
          template: %{uri_template: template_uri, name: "Tpl", description: "d"}
        })
        |> json_response(201)

      assert created["template"]["uri_template"] == template_uri
      template_id = created["template"]["id"]

      listed = conn |> get("#{@admin}/mcp-resource-templates") |> json_response(200)
      assert Enum.any?(listed["templates"], &(&1["uri_template"] == template_uri))

      updated =
        conn
        |> patch("#{@admin}/mcp-resource-templates/#{template_id}", %{template: %{name: "Tpl2"}})
        |> json_response(200)

      assert updated["template"]["name"] == "Tpl2"

      conn
      |> patch("#{@admin}/mcp-resource-templates/#{Ecto.UUID.generate()}", %{
        template: %{name: "x"}
      })
      |> json_response(404)

      conn
      |> patch("#{@admin}/mcp-resource-templates/#{template_id}", %{nope: 1})
      |> json_response(400)

      conn
      |> post("#{@admin}/mcp-resource-templates", %{nope: 1})
      |> json_response(400)

      conn |> delete("#{@admin}/mcp-resource-templates/#{template_id}") |> json_response(200)
      conn |> delete("#{@admin}/mcp-resource-templates/#{template_id}") |> json_response(404)
    end
  end
end
