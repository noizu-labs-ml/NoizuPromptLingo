# Dev environment seeds.
# Invoked from priv/repo/seeds.exs via Code.eval_file when Mix.env() == :dev.
#
# Bootstraps:
#   - one admin user (admin@codefre.sh.local / devpassword123)
#   - one admin org (slug: codefresh-dev)
#   - owner membership
#   - five invite tokens, one per persona in docs/personas/
#   - one open dev invite (multi-use, 1-year, role=editor)
#
# Raw invite tokens are printed to stdout for local signup testing.
# Re-running is safe: `seed` blocks are idempotent (tracked by seed_helper).

require SeedHelper
import SeedHelper

alias Codefresh.Accounts
alias Codefresh.Organizations

seed {"bootstrap_admin_user", "1"} do
  {:ok, user} =
    Accounts.register_user(%{
      "email" => "admin@codefre.sh.local",
      "password" => "devpassword123"
    })

  set_handle("admin_user_id", user.id)

  IO.puts("")
  IO.puts("[dev-seed] admin user created")
  IO.puts("  email:    admin@codefre.sh.local")
  IO.puts("  password: devpassword123")
end

requires_seed [{"bootstrap_admin_user", "1"}] do
  seed {"bootstrap_admin_org", "1"} do
    {:ok, org} =
      Organizations.create_organization(%{
        "slug" => "codefresh-dev",
        "name" => "CodeFresh Dev"
      })

    set_handle("admin_org_id", org.id)

    user_id = handle("admin_user_id")
    user = Accounts.get_user!(user_id)

    {:ok, _membership} =
      Accounts.create_membership(%{
        organization_id: org.id,
        user_id: user.id,
        role: "owner"
      })

    IO.puts("[dev-seed] admin org created")
    IO.puts("  slug: codefresh-dev")
    IO.puts("  admin is owner")
  end
end

requires_seed [{"bootstrap_admin_org", "1"}] do
  seed {"bootstrap_keith_owner", "1"} do
    # Project owner — direct login (no invite-token round-trip needed in dev)
    {:ok, user} =
      Accounts.register_user(%{
        "email" => "keith.brings@noizu.com",
        "password" => "changeme123$!"
      })

    org_id = handle("admin_org_id")

    {:ok, _membership} =
      Accounts.create_membership(%{
        organization_id: org_id,
        user_id: user.id,
        role: "owner"
      })

    set_handle("keith_user_id", user.id)

    IO.puts("")
    IO.puts("[dev-seed] project owner seeded")
    IO.puts("  email:    keith.brings@noizu.com")
    IO.puts("  password: changeme123$!")
    IO.puts("  org:      codefresh-dev (owner)")
  end
end

requires_seed [{"bootstrap_admin_org", "1"}] do
  seed {"persona_invite_tokens", "1"} do
    org_id = handle("admin_org_id")
    admin_id = handle("admin_user_id")

    invites = [
      {"priya@codefre.sh.local", "editor", "priya-ml-engineer (Senior ML Engineer)"},
      {"marcus@codefre.sh.local", "admin", "marcus-qa-lead (QA Lead)"},
      {"yuki@codefre.sh.local", "editor", "yuki-red-teamer (Red Teamer)"},
      {"alex@codefre.sh.local", "viewer", "alex-oss-maintainer (OSS)"},
      {"sofia@codefre.sh.local", "viewer", "sofia-product-manager (PM)"}
    ]

    IO.puts("")
    IO.puts("[dev-seed] persona invite tokens (expire in 30 days):")
    IO.puts("  POST /api/v1/auth/register with {user: {email, password}, invite_token: <token>}")

    for {email, role, label} <- invites do
      {:ok, _invite, raw_token} =
        Accounts.create_invite_token(%{
          organization_id: org_id,
          email: email,
          role: role,
          invited_by_user_id: admin_id,
          expires_at:
            DateTime.utc_now()
            |> DateTime.add(30 * 24 * 3600, :second)
            |> DateTime.truncate(:second),
          metadata: %{"persona" => label}
        })

      IO.puts("")
      IO.puts("  #{label}")
      IO.puts("    email: #{email}   role: #{role}")
      IO.puts("    token: #{raw_token}")
    end

    IO.puts("")
  end
end

requires_seed [{"bootstrap_admin_org", "1"}] do
  seed {"open_dev_invite", "1"} do
    # Multi-use, email-unbound, one-year expiry — for ad-hoc local experimentation
    org_id = handle("admin_org_id")
    admin_id = handle("admin_user_id")

    {:ok, _invite, raw_token} =
      Accounts.create_invite_token(%{
        organization_id: org_id,
        role: "editor",
        invited_by_user_id: admin_id,
        max_uses: 100,
        expires_at:
          DateTime.utc_now()
          |> DateTime.add(365 * 24 * 3600, :second)
          |> DateTime.truncate(:second),
        metadata: %{"kind" => "dev-open"}
      })

    IO.puts("[dev-seed] open dev invite (role=editor, max_uses=100, 1 year):")
    IO.puts("    #{raw_token}")
    IO.puts("")
  end
end
