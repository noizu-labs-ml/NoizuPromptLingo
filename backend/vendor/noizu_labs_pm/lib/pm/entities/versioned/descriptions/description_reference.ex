defmodule Noizu.PM.Versioned.Descriptions.DescriptionReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: Noizu.PM.Versioned.Descriptions.Description
end
