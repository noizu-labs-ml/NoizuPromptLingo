defmodule NoizuPromptLingua.Authz.ScopedMemberships.ScopedMembershipReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: NoizuPromptLingua.Authz.ScopedMemberships.ScopedMembership
end
