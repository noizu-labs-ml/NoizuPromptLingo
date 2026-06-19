defmodule NoizuPromptLingua.Authz.Policies.PolicyReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: NoizuPromptLingua.Authz.Policies.Policy
end
