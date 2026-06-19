defmodule NoizuPromptLingua.Users.Media.AssetReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: NoizuPromptLingua.Users.Media.Asset
end
