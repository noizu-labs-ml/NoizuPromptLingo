defmodule TheRobotWars.Users.UserReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: TheRobotWars.Users.User
end
