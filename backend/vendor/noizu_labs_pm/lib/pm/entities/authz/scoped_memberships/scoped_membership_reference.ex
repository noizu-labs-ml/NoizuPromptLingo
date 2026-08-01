defmodule Noizu.PM.Authz.ScopedMemberships.ScopedMembershipReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: Noizu.PM.Authz.ScopedMemberships.ScopedMembership
end
