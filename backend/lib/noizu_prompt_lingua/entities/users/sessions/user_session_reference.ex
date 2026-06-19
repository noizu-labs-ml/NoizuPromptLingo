defmodule NoizuPromptLingua.Users.Sessions.UserSessionReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: NoizuPromptLingua.Users.Sessions.UserSession
end
