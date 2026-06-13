# Test environment seeds.
# Invoked via Code.eval_file when Mix.env() == :test.
# Minimal fixture — tests that need more data should build their own via factories.

require SeedHelper
import SeedHelper

alias Codefresh.Accounts
alias Codefresh.Organizations

seed {"test_fixture_user_org", "1"} do
  {:ok, user} =
    Accounts.register_user(%{
      "email" => "test-owner@codefre.sh.test",
      "password" => "testpassword"
    })

  {:ok, org} =
    Organizations.create_organization(%{
      "slug" => "test-org",
      "name" => "Test Org"
    })

  {:ok, _} =
    Accounts.create_membership(%{
      organization_id: org.id,
      user_id: user.id,
      role: "owner"
    })

  set_handle("test_user_id", user.id)
  set_handle("test_org_id", org.id)
end

requires_seed [{"test_fixture_user_org", "1"}] do
  seed {"test_fixture_open_invite", "1"} do
    org_id = handle("test_org_id")

    {:ok, _invite, raw_token} =
      Accounts.create_invite_token(%{
        organization_id: org_id,
        role: "editor",
        max_uses: 1_000,
        expires_at:
          DateTime.utc_now()
          |> DateTime.add(24 * 3600, :second)
          |> DateTime.truncate(:second),
        metadata: %{"kind" => "test-open"}
      })

    set_handle("test_invite_token", raw_token)
  end
end
