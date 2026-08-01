defmodule Noizu.PM.Versioned.Names.NameReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: Noizu.PM.Versioned.Names.Name
end
