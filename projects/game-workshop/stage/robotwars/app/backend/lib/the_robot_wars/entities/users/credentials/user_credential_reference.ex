defmodule TheRobotWars.Users.Credentials.UserCredentialReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: TheRobotWars.Users.Credentials.UserCredential
end
