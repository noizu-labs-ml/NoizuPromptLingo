defmodule Derobot.Users.Credentials.UserCredentialReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: Derobot.Users.Credentials.UserCredential
end
