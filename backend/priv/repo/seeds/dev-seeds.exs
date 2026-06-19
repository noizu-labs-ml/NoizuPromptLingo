dir = Path.dirname(__ENV__.file)
Code.eval_file("#{dir}/prod-seeds.exs")

alias NoizuPromptLingua.Schema.Users.User
alias NoizuPromptLingua.Schema.Organizations.Organization
alias NoizuPromptLingua.Schema.Organizations.Membership
alias NoizuPromptLingua.Schema.Organizations.InviteToken
alias NoizuPromptLingua.Schema.Users.Credentials.UserCredential
alias NoizuPromptLingua.Schema.Versioned.Names.Name
alias NoizuPromptLingua.Schema.Versioned.Descriptions.Description

admin_id = UUID.uuid5(:oid, "NoizuPromptLingua.Dev.Admin")
dev_org_id = UUID.uuid5(:oid, "NoizuPromptLingua.Dev.Organization")
login_provider_id = UUID.uuid5(:oid, "NoizuPromptLingua.Schema.Auth.Providers.Provider@Login")

seed "dev:admin-name" do
  NoizuPromptLingua.Repo.insert!(
    %Name{id: UUID.uuid5(:oid, "NoizuPromptLingua.Dev.Admin.Name"), first: "Admin", last: "User"},
    on_conflict: :nothing,
    conflict_target: :id
  )
end

seed "dev:admin-description" do
  NoizuPromptLingua.Repo.insert!(
    %Description{
      id: UUID.uuid5(:oid, "NoizuPromptLingua.Dev.Admin.Description"),
      title: "Admin",
      body: "Default development admin user"
    },
    on_conflict: :nothing,
    conflict_target: :id
  )
end

seed "dev:admin-user" do
  NoizuPromptLingua.Repo.insert!(
    %User{
      id: admin_id,
      user_name: "admin",
      handle: "admin",
      name_id: UUID.uuid5(:oid, "NoizuPromptLingua.Dev.Admin.Name"),
      description_id: UUID.uuid5(:oid, "NoizuPromptLingua.Dev.Admin.Description"),
      email: "admin@starter.local",
      hashed_password: Bcrypt.hash_pwd_salt("password123"),
      status: :active,
      verified: true,
      flagged: false
    },
    on_conflict: :nothing,
    conflict_target: :id
  )
end

seed "dev:admin-credential" do
  NoizuPromptLingua.Repo.insert!(
    %UserCredential{
      id: UUID.uuid5(:oid, "NoizuPromptLingua.Dev.Admin.Credential"),
      user_id: admin_id,
      auth_provider_id: login_provider_id,
      status: :active,
      settings: %{
        "email" => "admin@starter.local",
        "password" => Bcrypt.hash_pwd_salt("password123")
      },
      state: %{},
      fingerprint: "dev-admin-login"
    },
    on_conflict: :nothing,
    conflict_target: :id
  )
end

seed "dev:organization" do
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

seed "dev:admin-membership" do
  NoizuPromptLingua.Repo.insert!(
    %Membership{
      id: UUID.uuid5(:oid, "NoizuPromptLingua.Dev.Admin.Membership"),
      organization_id: dev_org_id,
      user_id: admin_id,
      role: "owner"
    },
    on_conflict: :nothing,
    conflict_target: :id
  )
end

seed "dev:bootstrap-invite" do
  raw_token = "dev-bootstrap-invite-token-do-not-use-in-prod"
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

  Dev admin credentials:
    Email:    admin@starter.local
    Password: password123
  """)
end

seed "dev:admin-magic-link-token" do
  admin_ref = NoizuPromptLingua.Users.User.ref(admin_id)
  context = Noizu.Context.system()

  token =
    SmartToken.new(%{
      type: :magic_link,
      resource: {:bind, :recipient},
      context: {:bind, :recipient},
      scope: {:auth, :magic_link},
      validity_period: {:unbound, {:relative, [{:day, 365}]}},
      extended_info: %{multi_use: true, limit: 1000}
    })
    |> SmartToken.bind!(%{recipient: admin_ref}, context)

  encoded_key = SmartToken.encoded_key(token)

  IO.puts("""

  ╔══════════════════════════════════════════════════════════════╗
  ║  Dev Magic Link Token (admin)                                ║
  ╚══════════════════════════════════════════════════════════════╝

  Token: #{encoded_key}
  URL:   http://localhost:3000/auth/verify?token=#{encoded_key}
  """)
end
