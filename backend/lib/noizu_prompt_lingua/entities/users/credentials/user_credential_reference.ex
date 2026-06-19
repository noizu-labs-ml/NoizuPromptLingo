defmodule NoizuPromptLingua.Users.Credentials.UserCredentialReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: NoizuPromptLingua.Users.Credentials.UserCredential
end
