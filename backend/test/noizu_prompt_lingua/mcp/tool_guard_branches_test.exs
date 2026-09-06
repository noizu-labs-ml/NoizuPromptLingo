defmodule NoizuPromptLingua.MCP.ToolGuardBranchesTest do
  @moduledoc """
  Residual ToolGuard branches beyond tool_guard_test/key_toolset_guard_test:
  the Phase-4 destructive-elevation conversation (shadow vs enforce, verified
  grant, bearer-token and disabled-config variants), the OAuth PDP-only pass
  for tools without an authz blob, and the PDP-disabled fallbacks of the
  scoped/global role check. Mutates app env — async: false.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Authz.ScopedMemberships
  alias NoizuPromptLingua.MCP.ToolGuard
  alias NoizuPromptLingua.OAuth.Elevation
  alias NoizuPromptLingua.Repo

  setup do
    on_exit(fn ->
      Application.delete_env(:noizu_prompt_lingua, :mcp_authz_mode)
      Application.delete_env(:noizu_prompt_lingua, :mcp_pdp)
      Application.delete_env(:noizu_prompt_lingua, :mcp_elevation)
    end)

    :ok
  end

  defp enforce, do: Application.put_env(:noizu_prompt_lingua, :mcp_authz_mode, :enforce)
  defp shadow, do: Application.put_env(:noizu_prompt_lingua, :mcp_authz_mode, :shadow)
  defp pdp_disabled, do: Application.put_env(:noizu_prompt_lingua, :mcp_pdp, mode: :disabled)

  defp mk_user do
    uniq = System.unique_integer([:positive])

    Repo.insert!(%NoizuPromptLingua.Schema.Users.User{
      id: Ecto.UUID.generate(),
      email: "guardb-#{uniq}@example.com",
      user_name: "guardb#{uniq}",
      handle: "gb#{uniq}",
      status: :active
    })
  end

  defp mk_org(owner_id) do
    uniq = System.unique_integer([:positive])

    {:ok, org} =
      NoizuPromptLingua.Organizations.create_organization_with_owner(
        %{slug: "guardb-org-#{uniq}", name: "GuardB Org"},
        owner_id
      )

    org
  end

  defp ctx(sub, extra_claims \\ %{}),
    do: %{assigns: %{auth_claims: Map.merge(%{"sub" => sub}, extra_claims)}}

  defp destructive_spec(resource \\ :global),
    do: %{
      name: "Destructive.Tool",
      authz: [
        action: "tools:destroy",
        required_role: :member,
        sensitivity: :destructive,
        resource: resource
      ]
    }

  # ── elevation (sensitivity: :destructive) ─────────────────────────────────

  describe "destructive elevation" do
    test "without a grant: shadow logs, enforce denies with an elevation_uri" do
      owner = mk_user()
      org = mk_org(owner.id)
      spec = destructive_spec(:organization)

      shadow()

      assert ToolGuard.before_call(spec, %{organization: org.id}, ctx(owner.id)) == :ok

      enforce()

      assert {:error, denial} =
               ToolGuard.before_call(spec, %{organization: org.id}, ctx(owner.id))

      assert denial.reason == :elevation_required
      assert denial.elevation_uri =~ "/oauth/elevate?txn=elv_"
      assert denial.tool == "tools:destroy"
      assert denial.txn =~ "elv_"
    end

    test "a string sensitivity spelling is treated the same" do
      owner = mk_user()
      org = mk_org(owner.id)

      spec = %{
        destructive_spec(:organization)
        | authz: %{
            action: "tools:zap",
            required_role: :member,
            sensitivity: "destructive",
            resource: :organization
          }
      }

      enforce()

      assert {:error, %{reason: :elevation_required}} =
               ToolGuard.before_call(spec, %{organization: org.id}, ctx(owner.id))
    end

    test "an approved in-process grant satisfies the elevation check" do
      owner = mk_user()
      org = mk_org(owner.id)
      enforce()

      args = %{organization: org.id}
      hash = Elevation.args_hash(args)
      txn = Elevation.create_txn!(%{user_id: owner.id, tool: "tools:destroy", args_hash: hash})
      assert {:ok, _token, _exp} = Elevation.approve!(txn, owner.id)

      assert ToolGuard.before_call(destructive_spec(:organization), args, ctx(owner.id)) == :ok
    end

    test "a bearer elevation token from ctx.assigns is verified" do
      owner = mk_user()
      org = mk_org(owner.id)
      enforce()

      args = %{organization: org.id}
      hash = Elevation.args_hash(args)
      txn = Elevation.create_txn!(%{user_id: owner.id, tool: "tools:destroy", args_hash: hash})
      {:ok, token, _exp} = Elevation.approve!(txn, owner.id)

      token_ctx = %{assigns: %{auth_claims: %{"sub" => owner.id}, elevation_token: token}}
      assert ToolGuard.before_call(destructive_spec(:organization), args, token_ctx) == :ok

      # garbage token -> denial path with is_binary(elev) branch
      bad_ctx = %{assigns: %{auth_claims: %{"sub" => owner.id}, elevation_token: "garbage"}}

      assert {:error, %{reason: :elevation_required}} =
               ToolGuard.before_call(destructive_spec(:organization), args, bad_ctx)
    end

    test "an args-hash mismatch denies even with a live grant" do
      owner = mk_user()
      org = mk_org(owner.id)
      enforce()

      hash = Elevation.args_hash(%{})
      txn = Elevation.create_txn!(%{user_id: owner.id, tool: "tools:destroy", args_hash: hash})
      assert {:ok, _token, _exp} = Elevation.approve!(txn, owner.id)

      assert {:error, %{reason: :elevation_required}} =
               ToolGuard.before_call(
                 destructive_spec(:organization),
                 %{organization: org.id},
                 ctx(owner.id)
               )
    end

    test "elevation disabled by config falls through to the RBAC check" do
      owner = mk_user()
      org = mk_org(owner.id)
      enforce()
      Application.put_env(:noizu_prompt_lingua, :mcp_elevation, enabled: false)

      assert ToolGuard.before_call(
               destructive_spec(:organization),
               %{organization: org.id},
               ctx(owner.id)
             ) == :ok
    end
  end

  # ── OAuth PDP-only pass (tools WITHOUT authz metadata) ────────────────────

  describe "oauth pdp-only pass" do
    test "pdp disabled -> plain :ok for authz-less tools" do
      pdp_disabled()
      assert ToolGuard.before_call(%{name: "Plain.Tool"}, %{}, ctx("anyone")) == :ok
    end

    test "oauth claims without a resolvable user deny in enforce, log in shadow" do
      enforce()
      claims_ctx = %{assigns: %{auth_claims: %{"client_id" => "some-client"}}}

      assert {:error, %{reason: :no_identity}} =
               ToolGuard.before_call(%{name: "Plain.Tool"}, %{}, claims_ctx)

      shadow()

      assert ToolGuard.before_call(%{name: "Plain.Tool"}, %{}, claims_ctx) == :ok
    end

    test "system principal skips the pdp even with client claims" do
      sys_ctx = %{assigns: %{system_principal: true, auth_claims: %{"client_id" => "c"}}}

      assert ToolGuard.before_call(%{name: "Plain.Tool"}, %{}, sys_ctx) == :ok
    end

    test "an authenticated caller passes the local PDP when no axes apply" do
      owner = mk_user()
      assert ToolGuard.before_call(%{name: "Plain.Tool"}, %{}, ctx(owner.id)) == :ok
    end

    test "an unknown oauth client fails the capability axis" do
      owner = mk_user()
      enforce()

      assert {:error, %{reason: :client_not_allowed}} =
               ToolGuard.before_call(
                 %{name: "Plain.Tool"},
                 %{},
                 ctx(owner.id, %{"client_id" => "unknown-client"})
               )
    end
  end

  # ── PDP-disabled fallbacks for the scoped/global RBAC check ───────────────

  describe "pdp-disabled rbac fallbacks" do
    test "global scope with the pdp off allows any authenticated caller" do
      pdp_disabled()
      enforce()

      assert ToolGuard.before_call(
               %{name: "G.Tool", authz: %{required_role: :member, resource: :global}},
               %{},
               ctx(mk_user().id)
             ) == :ok
    end

    test "scoped role ladder still enforced with the pdp off" do
      pdp_disabled()
      enforce()
      owner = mk_user()
      org = mk_org(owner.id)
      member = mk_user()
      {:ok, _} = ScopedMemberships.add_member("organization", org.id, member.id, "member")

      spec = %{name: "S.Tool", authz: %{required_role: :member, resource: :organization}}

      assert ToolGuard.before_call(spec, %{organization: org.id}, ctx(owner.id)) == :ok

      assert {:error, %{reason: :insufficient_role}} =
               ToolGuard.before_call(
                 %{name: "S.Tool", authz: %{required_role: :owner, resource: :organization}},
                 %{organization: org.id},
                 ctx(member.id)
               )
    end
  end
end
