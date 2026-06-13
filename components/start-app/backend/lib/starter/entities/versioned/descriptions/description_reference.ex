defmodule Starter.Versioned.Descriptions.DescriptionReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: Starter.Versioned.Descriptions.Description
end
