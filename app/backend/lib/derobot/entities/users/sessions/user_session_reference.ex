defmodule Derobot.Users.Sessions.UserSessionReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: Derobot.Users.Sessions.UserSession
end
