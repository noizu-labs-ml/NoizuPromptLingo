defmodule Starter.Authz.ScopedMemberships.ScopedMembershipReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: Starter.Authz.ScopedMemberships.ScopedMembership
end
