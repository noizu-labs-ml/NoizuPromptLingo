defmodule TheRobotWars.Users.Media.AssetReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: TheRobotWars.Users.Media.Asset
end
