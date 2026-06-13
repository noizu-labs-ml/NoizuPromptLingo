defmodule Derobot.Auth.Providers.ProviderReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: Derobot.Auth.Providers.Provider
end
