defmodule Noizu.PM.Users.Credentials.UserCredentialReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: Noizu.PM.Users.Credentials.UserCredential
end
