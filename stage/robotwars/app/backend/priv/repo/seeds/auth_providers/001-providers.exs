alias TheRobotWars.Schema.Auth.Providers.Provider

login_id = UUID.uuid5(:oid, "TheRobotWars.Schema.Auth.Providers.Provider@Login")
smart_token_id = UUID.uuid5(:oid, "TheRobotWars.Schema.Auth.Providers.Provider@SmartToken")

seed "auth-provider:login" do
  TheRobotWars.Repo.insert!(
    %Provider{
      id: login_id,
      title: "Login",
      description: "Email and password authentication"
    },
    on_conflict: :nothing,
    conflict_target: :id
  )
end

seed "auth-provider:smart-token" do
  TheRobotWars.Repo.insert!(
    %Provider{
      id: smart_token_id,
      title: "SmartToken",
      description: "Magic link token authentication"
    },
    on_conflict: :nothing,
    conflict_target: :id
  )
end
