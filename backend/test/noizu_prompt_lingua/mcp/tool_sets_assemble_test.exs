defmodule NoizuPromptLingua.MCP.ToolSetsAssembleTest do
  @moduledoc """
  AC-2B-3/5 through the composed stack: the 100/200/300 weight sandwich
  (set static hide + grant show ⇒ visible; grant deny + ACL deny ⇒ denied;
  ACL allow + static hide ⇒ hidden), the SET-RESOLUTION CEILING (grants
  narrow/adjust WITHIN the set's include list — never add tools), and
  immutable profiles ignoring grant ops while ACL still applies.
  """
  use NoizuPromptLingua.DataCase, async: false

  require Noizu.EntityReference.Records
  alias Noizu.EntityReference.Records, as: R

  alias Noizu.MCP.Permission.Grant
  alias Noizu.MCP.Toolset.Custom
  alias Noizu.MCP.Toolset.Override
  alias NoizuPromptLingua.MCP.{AclProvider, ToolSets, ToolsetNegotiations, ToolsetProvider}
  alias NoizuPromptLingua.MCP.Toolsets.Profiles
  alias NoizuPromptLingua.Repo

  @providers [persistence: ToolsetProvider, acl: AclProvider]
  @tool "Ticket.Create"

  setup do
    Repo.query!("DELETE FROM npl_mcp_toolset_store", [])
    :ok
  end

  describe "the 100/200/300 weight sandwich (AC-2B-3)" do
    test "set static hide (100) + grant show (200) ⇒ visible" do
      principal = principal("sandwich-1")
      tool = @tool
      toolset = build_toolset(%{@tool => [%Override{op: :set_visible, value: false}]})

      :ok =
        ToolsetProvider.put(
          "toolset_grants",
          "grant-show",
          %Grant{
            id: "grant-show",
            toolset_slug: toolset.slug,
            authenticator: "sandwich",
            subject: principal.subject,
            effect: :allow,
            tool_overrides: %{@tool => [%Override{op: :set_visible, value: true}]}
          },
          []
        )

      assert %{^tool => %{visible: true, callable: true}} = entries(toolset, principal)
    end

    test "grant deny (200) + ACL deny (300) ⇒ denied (weights, not layer names, decide)" do
      {principal, user_id} = principal_with_user("sandwich-2")

      tool = @tool
      toolset = build_toolset(%{})

      # Grant deny: the lib folds a targeted deny as visible+callable false
      # at weight 200 (deny targets exactly the tools its overrides list).
      :ok =
        ToolsetProvider.put(
          "toolset_grants",
          "grant-deny",
          %Grant{
            id: "grant-deny",
            toolset_slug: toolset.slug,
            authenticator: "sandwich",
            subject: principal.subject,
            effect: :deny,
            tool_overrides: %{@tool => [%Override{op: :set_visible, value: false}]}
          },
          []
        )

      # ACL deny at 300 on the same tool.
      acl_deny!(user_id, @tool)

      assert %{^tool => %{visible: false, callable: false}} = entries(toolset, principal)
    end

    test "ACL allow + static hide ⇒ hidden (ACL never un-hides)" do
      {principal, user_id} = principal_with_user("sandwich-3")

      tool = @tool

      toolset =
        build_toolset(%{@tool => [%Override{op: :set_visible, target: @tool, value: false}]})

      acl_allow!(user_id, @tool)

      assert %{^tool => %{visible: false}} = entries(toolset, principal)
    end
  end

  describe "the set-resolution ceiling (conformance-tested)" do
    test "a grant can never ADD a tool outside the set's include list" do
      principal = principal("ceiling-1")

      # The set's include is the hard ceiling: Ticket.Create only.
      toolset =
        build_toolset(%{
          @tool => [%Override{op: :set_name, target: @tool, value: "list_tickets"}]
        })

      # A grant carrying ops for Chat.AddMember — OUTSIDE the include list.
      :ok =
        ToolsetProvider.put(
          "toolset_grants",
          "grant-add",
          %Grant{
            id: "grant-add",
            toolset_slug: toolset.slug,
            authenticator: "sandwich",
            subject: principal.subject,
            effect: :allow,
            tool_overrides: %{
              "Chat.AddMember" => [%Override{op: :set_name, value: "sneaky_send"}],
              @tool => [%Override{op: :set_description, value: "within ceiling"}]
            }
          },
          []
        )

      entries = entries(toolset, principal)

      # The ceiling holds: only the include tool is served — under its static
      # rename plus the grant adjustment; the outside tool never materializes.
      assert Map.keys(entries) == ["list_tickets"]
      assert entries["list_tickets"].visible
      assert entries["list_tickets"].definition.description == "within ceiling"
    end
  end

  describe "immutable profiles (AC-2B-5, PRD-3 AC-3.5)" do
    test "grant ops never mutate a profile; the surface stays the base slice" do
      principal = principal("profile-1")
      profile = Profiles.custom("full")
      assert profile.immutable

      # A grant targeting a tool the profile serves — ignored (immutable).
      tool = Enum.fetch!(profile.include, 0)

      :ok =
        ToolsetProvider.put(
          "toolset_grants",
          "grant-profile",
          %Grant{
            id: "grant-profile",
            toolset_slug: profile.slug,
            authenticator: "sandwich",
            subject: principal.subject,
            effect: :allow,
            tool_overrides: %{tool => [%Override{op: :set_name, value: "hijacked_name"}]}
          },
          []
        )

      assert {:ok, entries, _version} = Custom.catalog(profile, %{auth: principal}, @providers)
      renamed = Enum.filter(entries, &(&1.definition.name == "hijacked_name"))
      assert renamed == []
    end
  end

  describe "negotiation records ride the consent writer (N2b prep)" do
    test "record/2 persists a negotiation the provider serves back" do
      assert :ok =
               ToolsetNegotiations.record(
                 [
                   toolset_slug: "set:team",
                   authenticator: "sandwich",
                   subject: "subject-9",
                   tool: "Ticket.Create",
                   required_scopes: ["tickets:write"],
                   granted: false,
                   elevation_uri: "https://idp.example/consent"
                 ],
                 []
               )

      {:ok, [negotiation]} =
        ToolsetProvider.list(
          "toolset_negotiations",
          %{toolset_slug: "set:team", authenticator: "sandwich"},
          []
        )

      assert negotiation.tool == "Ticket_Create"
      assert negotiation.granted == false
      assert negotiation.metadata_overrides == %{"elevation_uri" => "https://idp.example/consent"}
      assert negotiation.metadata["subject"] == "subject-9"
    end

    test "on_acl_denied is env-gated OFF by default (verdicts never write)" do
      assert :disabled =
               ToolsetNegotiations.on_acl_denied("Ticket.Create", principal("denied-1"), [])
    end
  end

  # ── helpers ───────────────────────────────────────────────────────────────

  # A minimal %Custom{} over the UniverseToolset base whose include list is
  # the hard ceiling; `tools` carries the static (weight-100) layer.
  defp build_toolset(static_ops) do
    %Custom{
      slug: "set:assemble-#{System.unique_integer([:positive])}",
      base: NoizuPromptLingua.MCP.UniverseToolset,
      immutable: false,
      include: [@tool],
      exclude: [],
      tools: static_ops,
      metadata: %{}
    }
  end

  defp entries(toolset, principal) do
    assert {:ok, entries, _version} = Custom.catalog(toolset, %{auth: principal}, @providers)

    Map.new(entries, fn entry -> {entry.definition.name, entry} end)
  end

  defp principal(subject),
    do: %Noizu.MCP.Auth.Principal{subject: subject, authenticator: "sandwich", metadata: %{}}

  defp principal_with_user(subject) do
    uniq = System.unique_integer([:positive])

    user =
      %NoizuPromptLingua.Schema.Users.User{
        id: Ecto.UUID.generate(),
        email: "assemble-#{uniq}@example.com",
        user_name: "assemble#{uniq}",
        handle: "assemble#{uniq}",
        status: :active
      }
      |> Repo.insert!()

    # The ACL provider resolves its subject through the principal's
    # membership identity (PrincipalMapper shape).
    principal = %Noizu.MCP.Auth.Principal{
      subject: subject,
      authenticator: "sandwich",
      metadata: %{"user_id" => user.id}
    }

    {principal, user.id}
  end

  defp rule!(user_id, resource, effect) do
    {:ok, _} =
      NoizuPromptLingua.Acl.create_rule(%{
        subject_ref: R.ref(module: NoizuPromptLingua.Users.User, id: user_id),
        resource_ref: resource,
        action: "mcp.tool",
        effect: effect
      })
  end

  defp acl_deny!(user_id, tool) do
    rule!(user_id, R.ref(module: NoizuPromptLingua.Schema.McpTool, id: tool), "deny")
  end

  defp acl_allow!(user_id, tool) do
    rule!(user_id, R.ref(module: NoizuPromptLingua.Schema.McpTool, id: tool), "allow")
  end
end
