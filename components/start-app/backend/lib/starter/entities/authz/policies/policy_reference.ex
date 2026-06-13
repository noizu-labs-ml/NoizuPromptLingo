defmodule Starter.Authz.Policies.PolicyReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: Starter.Authz.Policies.Policy
end
