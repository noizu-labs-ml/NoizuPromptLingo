defmodule Starter.Organizations.InviteTokenReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: Starter.Organizations.InviteToken
end
