defmodule TheRobotWars.Authz.Policies.PolicyReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: TheRobotWars.Authz.Policies.Policy
end
