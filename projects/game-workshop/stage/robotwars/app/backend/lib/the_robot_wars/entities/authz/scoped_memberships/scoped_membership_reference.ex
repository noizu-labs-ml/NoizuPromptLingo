defmodule TheRobotWars.Authz.ScopedMemberships.ScopedMembershipReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: TheRobotWars.Authz.ScopedMemberships.ScopedMembership
end
