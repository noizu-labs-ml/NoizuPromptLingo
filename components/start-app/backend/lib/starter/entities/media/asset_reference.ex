defmodule Starter.Media.AssetReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: Starter.Media.Asset
end
