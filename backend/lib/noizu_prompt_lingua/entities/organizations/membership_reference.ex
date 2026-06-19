defmodule NoizuPromptLingua.Organizations.MembershipReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: NoizuPromptLingua.Organizations.Membership
end
