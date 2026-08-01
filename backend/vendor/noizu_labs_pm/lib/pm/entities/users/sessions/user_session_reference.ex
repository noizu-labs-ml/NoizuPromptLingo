defmodule Noizu.PM.Users.Sessions.UserSessionReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: Noizu.PM.Users.Sessions.UserSession
end
