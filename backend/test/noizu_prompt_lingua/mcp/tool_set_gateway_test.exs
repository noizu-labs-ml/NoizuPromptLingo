defmodule NoizuPromptLingua.MCP.ToolSetGatewayTest do
  use NoizuPromptLinguaWeb.ConnCase, async: false

  @moduledoc """
  PRD-N3 AC-N3-1/2/3/6/7/9 — the `MCPSetGatewayController` gate pipeline,
  route-level: real HS256 MCP JWTs minted via `Token.mint/3`, orgs in the app
  DB, projects via the TRP stub. All 404s share ONE body (AC-N3-2, no oracle).

  async: false — tests flip `:tool_sets_enabled` (global Application env).
  """

  alias NoizuPromptLingua.Authz.ScopedMemberships
  alias NoizuPromptLingua.MCP.ToolSets
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Authz.Group
  alias NoizuPromptLingua.Schema.McpApiKey
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.Schema.Projects.Project
  alias NoizuPromptLingua.Schema.Users.User
  alias NoizuPromptLingua.Token
  alias NoizuPromptLingua.TRP.TestStub
  alias NoizuPromptLinguaWeb.MCPSetGatewayController

  @host "tobor.locker"
  @not_found %{"error" => "MCP tool set not found"}

  setup context do
    unless context[:flag_off] || context[:flag_unset] do
      Application.put_env(:noizu_prompt_lingua, :tool_sets_enabled, true)
    end

    on_exit(fn -> Application.delete_env(:noizu_prompt_lingua, :tool_sets_enabled) end)

    # UUID-suffixed slug: localhost Redis outlives the test VM, and
    # `resolve_org_id/1` positives cache under `org:slug:<slug>` for 1h — a
    # repeated cross-run slug resolves to the previous run's rolled-back org.
    org =
      Repo.insert!(%Organization{
        name: "Gateway Org",
        slug: "gateway-org-#{Ecto.UUID.generate()}"
      })

    # resolve_org_id/1 consults the TRP shared-key plane (the org inventory):
    # the stub must know the org or every lookup 404s. Bust the 30s org-list
    # cache — an earlier resolution in the same VM cached a list without us.
    TestStub.seed_org(org.id, org.slug)
    NoizuPromptLingua.TRP.Cache.bust_prefix([:orgs, :list])

    %{org: org}
  end

  describe "flag (AC-N3-9 via the TOOL_SETS_ENABLED kill switch)" do
    @tag :flag_off
    test "tool_sets_enabled false (kill switch) ⇒ 404", %{org: org} do
      Application.put_env(:noizu_prompt_lingua, :tool_sets_enabled, false)
      {:ok, set} = create_set(org.id, "flagged-set")

      conn = call_org(anonymous_conn(), org.slug, set.slug)
      assert conn.status == 404
      assert body(conn) == @not_found
    end

    @tag :flag_unset
    test "flag unset ⇒ 404 in TEST (runtime.exs default-true never evaluates here)", %{
      org: org
    } do
      Application.delete_env(:noizu_prompt_lingua, :tool_sets_enabled)
      {:ok, set} = create_set(org.id, "unset-flag-set")

      conn = call_org(anonymous_conn(), org.slug, set.slug)
      assert conn.status == 404
    end

    test "enabled?/0 is the single resolved-flag reader the gates share", %{org: org} do
      Application.put_env(:noizu_prompt_lingua, :tool_sets_enabled, true)
      assert ToolSets.enabled?() == true

      Application.delete_env(:noizu_prompt_lingua, :tool_sets_enabled)
      assert ToolSets.enabled?() == false

      # B1: non-test envs resolve the flag in config/runtime.exs —
      # TOOL_SETS_ENABLED unset ⇒ true (serving), "false"/"0"/"no" ⇒ kill
      # switch (this 404). The old compile-time default of false left the set
      # gateway 404ing in every env that never set the flag (stage outage).
      {:ok, set} = create_set(org.id, "resolved-flag-set")
      conn = call_org(anonymous_conn(), org.slug, set.slug)
      assert conn.status == 404
      assert body(conn) == @not_found
    end
  end

  describe "404 family (AC-N3-2 — one body, no oracle)" do
    test "unknown org", %{org: _org} do
      conn = call_org(anonymous_conn(), "no-such-org-#{uniq()}", "some-set")
      assert conn.status == 404
      assert body(conn) == @not_found
    end

    test "unknown set slug", %{org: org} do
      conn = call_org(anonymous_conn(), org.slug, "no-such-set")
      assert conn.status == 404
      assert body(conn) == @not_found
    end

    test "inactive set is indistinguishable from unknown", %{org: org} do
      {:ok, set} = create_set(org.id, "inactive-set")
      {:ok, _} = ToolSets.deactivate(set)

      conn = call_org(anonymous_conn(), org.slug, "inactive-set")
      assert conn.status == 404
      assert body(conn) == @not_found
    end

    test "expired set is indistinguishable from unknown", %{org: org} do
      past = DateTime.add(DateTime.utc_now(), -3600, :second)

      {:ok, _set} =
        ToolSets.create(%{
          "organization_id" => org.id,
          "slug" => "expired-set",
          "expires_at" => DateTime.truncate(past, :second)
        })

      conn = call_org(anonymous_conn(), org.slug, "expired-set")
      assert conn.status == 404
      assert body(conn) == @not_found
    end

    test "project mismatch is indistinguishable from unknown (AC-N3-7)", %{org: org} do
      {:ok, project} = seed_project(org.id, "proj-a")
      {:ok, _other} = seed_project(org.id, "proj-b")

      {:ok, set} =
        create_set(org.id, "proj-set", %{
          "project_id" => other_project_id(org.id)
        })

      conn =
        call_org_project(anonymous_conn(), org.slug, project.slug, set.slug)

      assert conn.status == 404
      assert body(conn) == @not_found
      assert project.id != nil
    end

    test "unknown project slug ⇒ 404", %{org: org} do
      {:ok, project} = seed_project(org.id, "proj-c")

      {:ok, set} = create_set(org.id, "proj-set-c", %{"project_id" => project.id})

      conn =
        call_org_project(anonymous_conn(), org.slug, "no-such-project", set.slug)

      assert conn.status == 404
      assert body(conn) == @not_found
    end
  end

  describe "allow_api_keys (AC-N3-3)" do
    test "allow_api_keys false + API-key identity ⇒ 403 authz error", %{org: org} do
      {:ok, set} =
        create_set(org.id, "no-keys-set", %{"settings" => %{"allow_api_keys" => false}})

      caller = key_caller(org)

      conn =
        call_org(
          authenticated_conn(caller.token),
          org.slug,
          set.slug
        )

      assert conn.status == 403
      assert body(conn) == %{"error" => "api keys not allowed on this set"}
    end

    test "allow_api_keys absent + API-key identity passes the gates (default allowed)", %{
      org: org
    } do
      {:ok, set} = create_set(org.id, "keys-ok-set")
      caller = key_caller(org, member?: true)

      result = call_org(authenticated_conn(caller.token), org.slug, set.slug)
      assert_gates_passed(result)
    end
  end

  describe "audience gates (FR-3-6 / AC-N3-6)" do
    test "org-set non-member ⇒ 404", %{org: org} do
      {:ok, set} = create_set(org.id, "org-set")
      caller = key_caller(org, member?: false)

      conn = call_org(authenticated_conn(caller.token), org.slug, set.slug)
      assert conn.status == 404
      assert body(conn) == @not_found
    end

    test "org-set member passes the gates (AC-N3-1 happy path)", %{org: org} do
      {:ok, set} = create_set(org.id, "org-set-happy")
      caller = key_caller(org, member?: true)

      result = call_org(authenticated_conn(caller.token), org.slug, set.slug)
      assert_gates_passed(result)
    end

    test "group-set: member of the org but NOT the set's group ⇒ 404", %{org: org} do
      role_group = member_group()
      {:ok, set} = create_set(org.id, "group-set", %{"group_id" => role_group.id})

      # Admin-role member: active org membership, WRONG role group for this set.
      caller = key_caller(org, member?: true, role: "admin")

      conn = call_org(authenticated_conn(caller.token), org.slug, set.slug)
      assert conn.status == 404
      assert body(conn) == @not_found
    end

    test "group-set: membership carrying the set's group passes", %{org: org} do
      role_group = member_group()
      {:ok, set} = create_set(org.id, "group-set-ok", %{"group_id" => role_group.id})

      caller = key_caller(org, member?: true, role: "member")

      result = call_org(authenticated_conn(caller.token), org.slug, set.slug)
      assert_gates_passed(result)
    end

    test "project-set with matching binding passes (AC-N3-7)", %{org: org} do
      {:ok, project} = seed_project(org.id, "proj-match")
      {:ok, set} = create_set(org.id, "proj-set-match", %{"project_id" => project.id})

      caller = key_caller(org, member?: true)

      result =
        call_org_project(authenticated_conn(caller.token), org.slug, project.slug, set.slug)

      assert_gates_passed(result)
    end
  end

  describe "serving supervision (B1 last-mile)" do
    test "the set endpoint's supervisor family is running (initialize cannot no-process 500)" do
      # The gateway serve path starts sessions under
      # Module.concat(ToolSetEndpoint, SessionSupervisor) (lib transport). The
      # module was missing from the application tree, so every initialize that
      # got past the (newly fixed) B1 gates 500'd on `no process`.
      assert Process.whereis(NoizuPromptLingua.MCP.ToolSetEndpoint.SessionSupervisor),
             "ToolSetEndpoint.SessionSupervisor must be in the supervision tree"

      assert Process.whereis(NoizuPromptLingua.MCP.ToolSetEndpoint.Registry)
    end
  end

  describe "serving roundtrip (route-metadata enrichment)" do
    test "tools/list serves the set catalog — resolved org id reaches the resolver", %{org: org} do
      # Stage finding: the gateway's route metadata carried only URL slugs, so
      # the per-request principal had set_slug but NO set_org_id and
      # ToolsetResolver resolved :none — initialize 200 with tools: [].
      {:ok, set} =
        create_set(org.id, "serving-set", %{
          "config" => %{
            "groups" => %{
              "markdown" => %{"enabled" => true, "tools" => %{}}
            }
          }
        })

      caller = key_caller(org, member?: true)

      init =
        Jason.encode!(%{
          "jsonrpc" => "2.0",
          "id" => 1,
          "method" => "initialize",
          "params" => %{
            "protocolVersion" => "2025-06-18",
            "capabilities" => %{},
            "clientInfo" => %{"name" => "gateway-e2e", "version" => "1"}
          }
        })

      conn =
        Plug.Test.conn(:post, "/org/#{org.slug}/set/#{set.slug}/mcp", init)
        |> Map.put(:host, @host)
        |> Plug.Conn.put_req_header("content-type", "application/json")
        |> Plug.Conn.put_req_header("accept", "application/json, text/event-stream")
        |> Plug.Conn.put_req_header("authorization", "Bearer " <> caller.token)
        |> MCPSetGatewayController.handle_org(%{"org_slug" => org.slug, "set_slug" => set.slug})

      assert conn.status == 200,
             "initialize failed: #{inspect(conn.status)} #{inspect(conn.resp_body)}"

      assert [sid] = Plug.Conn.get_resp_header(conn, "mcp-session-id")

      notify = %{"jsonrpc" => "2.0", "method" => "notifications/initialized"}

      Plug.Test.conn(:post, "/org/#{org.slug}/set/#{set.slug}/mcp", Jason.encode!(notify))
      |> Map.put(:host, @host)
      |> Plug.Conn.put_req_header("content-type", "application/json")
      |> Plug.Conn.put_req_header("accept", "application/json, text/event-stream")
      |> Plug.Conn.put_req_header("authorization", "Bearer " <> caller.token)
      |> Plug.Conn.put_req_header("mcp-session-id", sid)
      |> MCPSetGatewayController.handle_org(%{"org_slug" => org.slug, "set_slug" => set.slug})

      list_conn =
        Plug.Test.conn(
          :post,
          "/org/#{org.slug}/set/#{set.slug}/mcp",
          Jason.encode!(%{"jsonrpc" => "2.0", "id" => 2, "method" => "tools/list"})
        )
        |> Map.put(:host, @host)
        |> Plug.Conn.put_req_header("content-type", "application/json")
        |> Plug.Conn.put_req_header("accept", "application/json, text/event-stream")
        |> Plug.Conn.put_req_header("authorization", "Bearer " <> caller.token)
        |> Plug.Conn.put_req_header("mcp-session-id", sid)
        |> MCPSetGatewayController.handle_org(%{"org_slug" => org.slug, "set_slug" => set.slug})

      assert list_conn.status == 200

      tools =
        list_conn.resp_body
        |> decode_jsonrpc_body()
        |> Map.fetch!("result")
        |> Map.fetch!("tools")

      names = Enum.map(tools, & &1["name"])
      assert "Markdown.Convert" in names, "expected the set catalog, got: #{inspect(names)}"
    end
  end

  # Non-final frames upgrade the POST to SSE (`data: <json>` lines); final
  # replies come back plain JSON. Take the frame carrying the result.
  defp decode_jsonrpc_body("data:" <> _ = body) do
    body
    |> String.split("\n")
    |> Enum.flat_map(fn line ->
      case String.trim(line) do
        "data:" <> json -> [Jason.decode!(json)]
        _ -> []
      end
    end)
    |> Enum.find(%{}, &Map.has_key?(&1, "result"))
  end

  defp decode_jsonrpc_body(body), do: Jason.decode!(body)

  test "unauthenticated request defers to the transport challenge (401, not 404)", %{org: org} do
    {:ok, set} = create_set(org.id, "anon-set")

    conn = call_org(anonymous_conn(), org.slug, set.slug)

    case conn do
      %Plug.Conn{} = c -> assert c.status == 401
      {:serving_reached, _msg} -> :ok
    end
  end

  # ── fixtures ──────────────────────────────────────────────────────────────

  defp uniq, do: Integer.to_string(System.unique_integer([:positive]))

  defp create_set(org_id, slug, extra \\ %{}) do
    ToolSets.create(
      Map.merge(
        %{"organization_id" => org_id, "slug" => slug, "display_name" => slug},
        extra
      )
    )
  end

  defp create_user do
    n = uniq()

    Repo.insert!(%User{
      id: Ecto.UUID.generate(),
      email: "n3-#{n}@example.com",
      user_name: "n3u#{n}",
      handle: "n3h#{n}",
      status: :active,
      verified: false,
      flagged: false
    })
  end

  defp create_api_key(user_id) do
    Repo.insert!(%McpApiKey{
      id: Ecto.UUID.generate(),
      user_id: user_id,
      key_prefix: "mcp_t",
      key_hash: Ecto.UUID.generate(),
      status: "active"
    })
  end

  defp key_caller(org, opts \\ []) do
    user = create_user()
    key = create_api_key(user.id)

    if Keyword.get(opts, :member?, false) do
      role = Keyword.get(opts, :role, "member")
      {:ok, _} = ScopedMemberships.add_member("organization", org.id, user.id, role)
    end

    {:ok, token, _exp} =
      Token.mint(%{id: user.id, email: user.email, name: user.user_name}, %{id: key.id},
        alg: :hs256
      )

    %{user: user, key: key, token: token}
  end

  # The role group rows (owner/admin/lead/member/viewer) are seeded by
  # AuthzTestSchema; the "member" row is the audience group for group-sets.
  defp member_group do
    Repo.get_by!(Group, name: "member")
  end

  defp seed_project(org_id, slug) do
    row = TestStub.seed_project(org_id, %{slug: slug, name: slug})
    ensure_project_row!(org_id, row.id, slug)
    {:ok, row}
  end

  # A project id that belongs to NO seeded project (mismatch probe).
  defp other_project_id(org_id) do
    stray = Ecto.UUID.generate()
    stray_slug = "stray-#{uniq()}"
    TestStub.seed_project(org_id, %{id: stray, slug: stray_slug})
    ensure_project_row!(org_id, stray, stray_slug)
    stray
  end

  # Liquibase 083 enforces mcp_tool_sets.project_id → projects(id); the TRP
  # stub alone doesn't put the project in the app DB, so mirror it there.
  # Sandbox-scoped: rolled back at the end of each test.
  defp ensure_project_row!(org_id, id, slug) do
    case Repo.get(Project, id) do
      nil ->
        Repo.insert!(%Project{id: id, organization_id: org_id, name: slug, slug: slug})

      _project ->
        :ok
    end
  end

  # ── conn helpers ──────────────────────────────────────────────────────────

  defp anonymous_conn do
    build_conn()
    |> Map.put(:host, @host)
    |> Map.put(:remote_ip, {127, 0, 0, 1})
    |> Plug.Conn.put_req_header("authorization", "")
  end

  defp authenticated_conn(token) do
    build_conn()
    |> Map.put(:host, @host)
    |> Map.put(:remote_ip, {127, 0, 0, 1})
    |> Plug.Conn.put_req_header("authorization", "Bearer " <> token)
  end

  defp call_org(conn, org_slug, set_slug) do
    safe(&MCPSetGatewayController.handle_org/2, conn, %{
      "org_slug" => org_slug,
      "set_slug" => set_slug
    })
  end

  defp call_org_project(conn, org_slug, project_slug, set_slug) do
    safe(&MCPSetGatewayController.handle_org_project/2, conn, %{
      "org_slug" => org_slug,
      "project_slug" => project_slug,
      "set_slug" => set_slug
    })
  end

  # A crash past the gates (inside transport session serving) means the gate
  # pipeline passed — the transport layer is not under test here.
  defp safe(fun, conn, params) do
    fun.(conn, params)
  rescue
    e -> {:serving_reached, Exception.message(e)}
  end

  defp assert_gates_passed(result) do
    case result do
      %Plug.Conn{} = conn -> refute conn.status in [403, 404]
      {:serving_reached, _msg} -> :ok
    end
  end

  defp body(conn), do: conn.resp_body && Jason.decode!(conn.resp_body)
end
