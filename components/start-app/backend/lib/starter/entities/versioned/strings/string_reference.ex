defmodule Starter.Versioned.Strings.StringReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: Starter.Versioned.Strings.String
end
