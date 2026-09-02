defmodule NoizuPromptLingua.MCP.AclProviderConformanceTest do
  @moduledoc """
  AC-2B-4 matrix (PRD-5 §4.2 semantics over the legacy effective_toolset_acl
  fixtures): `NoizuPromptLingua.MCP.AclProvider` always answers for every
  offered tool (default-allow posture — the lib fail-closed never fires
  spuriously), per-tool / kind-wildcard / global / scope-wide deny shapes
  hide+disable at weight 300, allow and no-match are no-ops.
  """
  use NoizuPromptLingua.DataCase, async: true

  require Noizu.EntityReference.Records
  alias Noizu.EntityReference.Records, as: R

  alias Noizu.MCP.ACL.Resource
  alias Noizu.MCP.Auth.Principal
  alias NoizuPromptLingua.Acl
  alias NoizuPromptLingua.MCP.AclProvider
  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.Schema.MCPCustomScope
  alias NoizuPromptLingua.Schema.McpTool

  @action "mcp.tool"

  defp user do
    uniq = System.unique_integer([:positive])

    %NoizuPromptLingua.Schema.Users.User{
      id: Ecto.UUID.generate(),
      email: "n2bacl-#{uniq}@example.com",
      user_name: "n2bacl#{uniq}",
      handle: "n2bacl#{uniq}",
      status: :active
    }
    |> NoizuPromptLingua.Repo.insert!()
  end

  defp principal_for(user_id),
    do: %Principal{
      subject: "principal-#{user_id}",
      authenticator: :api_key,
      metadata: %{"user_id" => user_id}
    }

  defp tool_res(name), do: %Resource{kind: :tool, id: name}

  defp rule!(subject_ref, resource_ref, effect) do
    {:ok, _} =
      Acl.create_rule(%{
        subject_ref: subject_ref,
        resource_ref: resource_ref,
        action: @action,
        effect: effect
      })
  end

  # ── always-answers / default-allow posture ─────────────────────────────────

  describe "always-answers (AC-2B-4)" do
    test "a subject with NO rules is allowed on every offered tool" do
      user = user()
      principal = principal_for(user.id)

      offered = [tool_res("Ticket_List"), tool_res("Chat_Send"), tool_res("Sessions_Create")]

      verdicts = AclProvider.check_all(principal, offered, :call, %{}, [])

      assert verdicts == %{
               "Ticket_List" => :allow,
               "Chat_Send" => :allow,
               "Sessions_Create" => :allow
             }
    end

    test "an identity-less principal gets NO ACL pass but still always answers" do
      principal = %Principal{subject: "key-only", authenticator: :api_key, metadata: %{}}

      verdicts =
        AclProvider.check_all(
          principal,
          [tool_res("Ticket_List"), tool_res("Chat_Send")],
          :call,
          %{},
          []
        )

      assert MapSet.new(Map.values(verdicts)) == MapSet.new([:allow])
      assert map_size(verdicts) == 2
    end

    test "check/5 answers a single resource" do
      user = user()

      assert :allow =
               AclProvider.check(principal_for(user.id), tool_res("Ticket_List"), :call, %{}, [])
    end

    test "supported_kinds is [:tool, :toolset]" do
      assert AclProvider.supported_kinds() == [:tool, :toolset]
    end
  end

  # ── deny shapes (the legacy effective_toolset_acl fixture matrix) ──────────

  describe "deny shapes" do
    test "per-tool deny denies exactly that tool" do
      user = user()
      principal = principal_for(user.id)

      rule!(
        R.ref(module: NoizuPromptLingua.Users.User, id: user.id),
        R.ref(module: McpTool, id: "Ticket_List"),
        "deny"
      )

      verdicts =
        AclProvider.check_all(
          principal,
          [tool_res("Ticket_List"), tool_res("Chat_Send")],
          :call,
          %{},
          []
        )

      assert verdicts == %{"Ticket_List" => :deny, "Chat_Send" => :allow}
    end

    test "kind wildcard {:ref, McpTool, :any} denies every tool" do
      user = user()
      principal = principal_for(user.id)

      rule!(
        R.ref(module: NoizuPromptLingua.Users.User, id: user.id),
        R.ref(module: McpTool, id: :any),
        "deny"
      )

      verdicts =
        AclProvider.check_all(
          principal,
          [tool_res("Ticket_List"), tool_res("Chat_Send")],
          :call,
          %{},
          []
        )

      assert verdicts == %{"Ticket_List" => :deny, "Chat_Send" => :deny}
    end

    test "global {:ref, :any, :any} denies everything" do
      user = user()
      principal = principal_for(user.id)

      rule!(
        R.ref(module: NoizuPromptLingua.Users.User, id: user.id),
        R.ref(module: :any, id: :any),
        "deny"
      )

      verdicts = AclProvider.check_all(principal, [tool_res("Ticket_List")], :call, %{}, [])
      assert verdicts == %{"Ticket_List" => :deny}
    end

    test "scope-wide deny (opts[:scope_id]) denies every tool the scope serves" do
      user = user()
      principal = principal_for(user.id)

      {:ok, scope} =
        MCPCustomScopes.create(%{
          "slug" => "n2bacl-#{System.unique_integer([:positive])}",
          "name" => "n2bacl",
          "kind" => "custom",
          "config" => %{}
        })

      rule!(
        R.ref(module: NoizuPromptLingua.Users.User, id: user.id),
        R.ref(module: MCPCustomScope, id: scope.id),
        "deny"
      )

      verdicts =
        AclProvider.check_all(
          principal,
          [tool_res("Ticket_List"), tool_res("Chat_Send")],
          :call,
          %{}, scope_id: scope.id)

      assert verdicts == %{"Ticket_List" => :deny, "Chat_Send" => :deny}
    end

    test "an explicit allow rule is a no-op :allow" do
      user = user()
      principal = principal_for(user.id)

      rule!(
        R.ref(module: NoizuPromptLingua.Users.User, id: user.id),
        R.ref(module: McpTool, id: "Ticket_List"),
        "allow"
      )

      assert AclProvider.check_all(principal, [tool_res("Ticket_List")], :call, %{}, []) ==
               %{"Ticket_List" => :allow}
    end
  end

  # ── kind :toolset ──────────────────────────────────────────────────────────

  describe "toolset kind" do
    test "a kind-wide deny denies the toolset; otherwise allow" do
      user = user()
      principal = principal_for(user.id)
      toolset_res = %Resource{kind: :toolset, id: "set:team"}

      assert :allow = AclProvider.check(principal, toolset_res, :call, %{}, [])

      rule!(
        R.ref(module: NoizuPromptLingua.Users.User, id: user.id),
        R.ref(module: McpTool, id: :any),
        "deny"
      )

      assert :deny = AclProvider.check(principal, toolset_res, :call, %{}, [])
    end
  end
end
