defmodule TheRobotWars.Versioned.Descriptions.DescriptionReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: TheRobotWars.Versioned.Descriptions.Description
end
