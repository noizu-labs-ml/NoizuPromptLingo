defmodule NoizuPromptLingua.MCP.ToolGuardTest do
  @moduledoc """
  RBAC guard for MCP tools (ADR-015 / f015c5bb). Verifies the policy: server-side
  identity from ctx (never args), ordinal-ladder role check via Authz, deny-closed,
  system-principal exemption, and shadow-vs-enforce mode. Mutates a global app env
  (the mode), so async: false.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.MCP.ToolGuard
  alias NoizuPromptLingua.Authz.ScopedMemberships

  setup do
    # default mode is :shadow; tests that need enforcement opt in + restore on exit.
    on_exit(fn -> Application.delete_env(:noizu_prompt_lingua, :mcp_authz_mode) end)
    :ok
  end

  defp enforce, do: Application.put_env(:noizu_prompt_lingua, :mcp_authz_mode, :enforce)
  defp shadow, do: Application.put_env(:noizu_prompt_lingua, :mcp_authz_mode, :shadow)

  defp mk_user do
    uniq = System.unique_integer([:positive])

    {:ok, user} =
      Repo.insert(%NoizuPromptLingua.Schema.Users.User{
        id: Ecto.UUID.generate(),
        email: "guard-#{uniq}@example.com",
        user_name: "guard#{uniq}",
        handle: "g#{uniq}",
        status: :active
      })

    user
  end

  defp mk_org(owner_id) do
    uniq = System.unique_integer([:positive])
    {:ok, org} = NoizuPromptLingua.Organizations.create_organization_with_owner(%{slug: "guard-org-#{uniq}", name: "Guard Org"}, owner_id)
    org
  end

  defp ctx(sub), do: %{assigns: %{auth_claims: %{"sub" => sub}}}
  defp spec(authz), do: %{name: "Test.Tool", authz: authz}

  describe "passthrough + exemptions" do
    test "no authz metadata -> :ok (unguarded, opt-in rollout)" do
      enforce()
      assert ToolGuard.before_call(%{name: "Plain.Tool"}, %{}, ctx("anyone")) == :ok
    end

    test "system principal is exempt even with no identity" do
      enforce()
      sys_ctx = %{assigns: %{system_principal: true}}
      assert ToolGuard.before_call(spec(%{required_role: :owner, resource: :organization}), %{}, sys_ctx) == :ok
    end

    test "resource :global allows any authenticated caller, denies anonymous (enforce)" do
      enforce()
      assert ToolGuard.before_call(spec(%{required_role: :member, resource: :global}), %{}, ctx("someone")) == :ok
      assert {:error, %{reason: :no_identity}} = ToolGuard.before_call(spec(%{resource: :global}), %{}, %{assigns: %{}})
    end
  end

  describe "identity (server-side, from ctx) — deny-closed" do
    test "no identity -> deny in enforce, allow (log-only) in shadow", %{} do
      s = spec(%{required_role: :member, resource: :organization})

      enforce()
      assert {:error, %{reason: :no_identity}} = ToolGuard.before_call(s, %{organization: Ecto.UUID.generate()}, %{assigns: %{}})

      shadow()
      assert ToolGuard.before_call(s, %{organization: Ecto.UUID.generate()}, %{assigns: %{}}) == :ok
    end
  end

  describe "role ladder (enforce)" do
    setup do
      owner = mk_user()
      org = mk_org(owner.id)
      {:ok, owner: owner, org: org}
    end

    test "owner meets required :member -> allow", %{owner: owner, org: org} do
      enforce()
      s = spec(%{action: "chat:rooms:update", required_role: :member, resource: :organization})
      assert ToolGuard.before_call(s, %{organization: org.id}, ctx(owner.id)) == :ok
    end

    test "non-member -> deny :not_a_member", %{org: org} do
      enforce()
      stranger = mk_user()
      s = spec(%{required_role: :member, resource: :organization})
      assert {:error, %{reason: :not_a_member}} = ToolGuard.before_call(s, %{organization: org.id}, ctx(stranger.id))
    end

    test "member acting where owner is required -> deny :insufficient_role", %{org: org} do
      enforce()
      member = mk_user()
      {:ok, _} = ScopedMemberships.add_member("organization", org.id, member.id, "member")
      s = spec(%{required_role: :owner, resource: :organization})
      assert {:error, %{reason: :insufficient_role}} = ToolGuard.before_call(s, %{organization: org.id}, ctx(member.id))
    end

    test "missing required_role defaults to the owner bar (deny-closed) -> member denied", %{org: org} do
      enforce()
      member = mk_user()
      {:ok, _} = ScopedMemberships.add_member("organization", org.id, member.id, "member")
      # no required_role in the blob -> defaults to "owner"; a member is below that.
      s = spec(%{resource: :organization})
      assert {:error, %{reason: :insufficient_role}} = ToolGuard.before_call(s, %{organization: org.id}, ctx(member.id))
    end

    test "resource :project with NO project arg falls back to org-scope (R-a (b))", %{owner: owner, org: org} do
      enforce()
      s = spec(%{required_role: :member, resource: :project})
      # no project arg -> authorize at org; owner of the org passes
      assert ToolGuard.before_call(s, %{organization: org.id}, ctx(owner.id)) == :ok
      # and a non-member is still denied at org scope (fallback is deny-closed, not allow-all)
      stranger = mk_user()
      assert {:error, %{reason: :not_a_member}} = ToolGuard.before_call(s, %{organization: org.id}, ctx(stranger.id))
    end

    test "unresolvable resource -> deny", %{owner: owner} do
      enforce()
      s = spec(%{required_role: :member, resource: :organization})
      # no org arg at all
      assert {:error, %{reason: :resource_unresolved}} = ToolGuard.before_call(s, %{}, ctx(owner.id))
    end

    test "shadow mode logs but never blocks a would-deny", %{org: org} do
      shadow()
      stranger = mk_user()
      s = spec(%{required_role: :member, resource: :organization})
      assert ToolGuard.before_call(s, %{organization: org.id}, ctx(stranger.id)) == :ok
    end
  end

  describe "metadata extraction" do
    test "reads authz from the Tool :meta field too" do
      enforce()
      owner = mk_user()
      org = mk_org(owner.id)
      s = %{name: "Meta.Tool", meta: %{authz: %{required_role: :member, resource: :organization}}}
      assert ToolGuard.before_call(s, %{organization: org.id}, ctx(owner.id)) == :ok
    end
  end
end
