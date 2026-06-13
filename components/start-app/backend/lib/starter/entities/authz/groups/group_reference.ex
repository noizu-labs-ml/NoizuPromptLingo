defmodule Starter.Authz.Groups.GroupReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: Starter.Authz.Groups.Group
end
