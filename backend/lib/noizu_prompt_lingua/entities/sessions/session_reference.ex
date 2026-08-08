defmodule NoizuPromptLingua.Sessions.SessionReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: NoizuPromptLingua.Sessions.Session
end
