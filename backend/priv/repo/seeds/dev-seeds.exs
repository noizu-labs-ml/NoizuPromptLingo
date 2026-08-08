# Code.eval_file/2 runs this in a fresh scope, so re-import the seed macro.
# The begin_session()/end_session() state from seeds.exs lives in this process.
require SeedHelper
import SeedHelper

dir = Path.dirname(__ENV__.file)
Code.eval_file("#{dir}/prod-seeds.exs")

alias NoizuPromptLingua.Schema.Users.User
alias NoizuPromptLingua.Schema.Organizations.Organization
alias NoizuPromptLingua.Schema.Organizations.Membership
alias NoizuPromptLingua.Schema.Organizations.InviteToken
alias NoizuPromptLingua.Schema.Versioned.Names.Name
alias NoizuPromptLingua.Schema.Versioned.Descriptions.Description

admin_id = UUID.uuid5(:oid, "NoizuPromptLingua.Dev.TestAccount")
dev_org_id = UUID.uuid5(:oid, "NoizuPromptLingua.Dev.Organization")

seed {"dev:test-account-name", "1"} do
  NoizuPromptLingua.Repo.insert!(
    %Name{id: UUID.uuid5(:oid, "NoizuPromptLingua.Dev.TestAccount.Name"), first: "Test", last: "User"},
    on_conflict: :nothing,
    conflict_target: :id
  )
end

seed {"dev:test-account-description", "1"} do
  NoizuPromptLingua.Repo.insert!(
    %Description{
      id: UUID.uuid5(:oid, "NoizuPromptLingua.Dev.TestAccount.Description"),
      title: "Test account",
      body: "Portfolio smoke-test account"
    },
    on_conflict: :nothing,
    conflict_target: :id
  )
end

seed {"dev:test-account-user", "1"} do
  NoizuPromptLingua.Repo.insert!(
    %User{
      id: admin_id,
      user_name: "test",
      handle: "test",
      name_id: UUID.uuid5(:oid, "NoizuPromptLingua.Dev.TestAccount.Name"),
      description_id: UUID.uuid5(:oid, "NoizuPromptLingua.Dev.TestAccount.Description"),
      email: "test@portfolio.local",
      status: :active,
      verified: true,
      flagged: false
    },
    on_conflict: :nothing,
    conflict_target: :id
  )
end

seed {"dev:organization", "1"} do
  NoizuPromptLingua.Repo.insert!(
    %Organization{
      id: dev_org_id,
      slug: "dev",
      name: "Dev Org"
    },
    on_conflict: :nothing,
    conflict_target: :id
  )
end

seed {"dev:test-account-membership", "1"} do
  NoizuPromptLingua.Repo.insert!(
    %Membership{
      id: UUID.uuid5(:oid, "NoizuPromptLingua.Dev.TestAccount.Membership"),
      organization_id: dev_org_id,
      user_id: admin_id,
      role: "owner"
    },
    on_conflict: :nothing,
    conflict_target: :id
  )
end

seed {"dev:bootstrap-invite", "1"} do
  raw_token = "iansaysyoucanjoin"
  token_hash = Bcrypt.hash_pwd_salt(raw_token)
  key_prefix = String.slice(raw_token, 0, 8)

  NoizuPromptLingua.Repo.insert!(
    %InviteToken{
      id: UUID.uuid5(:oid, "NoizuPromptLingua.Dev.BootstrapInvite"),
      organization_id: dev_org_id,
      created_by_user_id: admin_id,
      token_hash: token_hash,
      key_prefix: key_prefix,
      max_uses: nil,
      uses: 0,
      revoked: false
    },
    on_conflict: :nothing,
    conflict_target: :id
  )

  IO.puts("""

  ╔══════════════════════════════════════════════════════════════╗
  ║  Dev Bootstrap Invite Token                                  ║
  ║  #{raw_token}  ║
  ║  Use this token to register additional users in dev mode.   ║
  ╚══════════════════════════════════════════════════════════════╝

  Dev test user:
    Email:    test@portfolio.local
    Sign in via Authentik SSO.
  """)
end
