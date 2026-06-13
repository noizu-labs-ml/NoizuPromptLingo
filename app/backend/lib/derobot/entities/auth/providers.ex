defmodule Derobot.Auth.Providers do
  alias Derobot.Auth.Providers.Provider, as: Entity
  alias Derobot.Schema.Auth.Providers.Provider, as: Schema
  use Noizu.Repo

  def_repo(entity: Derobot.Auth.Providers.Provider)

  def list(context, options \\ []) do
    settings = Noizu.Entity.Meta.persistence(Entity) |> hd

    Derobot.Repo.all(Schema)
    |> Enum.map(fn record ->
      {:ok, entity} = Entity.from_record(record, settings, context, options)
      {:ok, entity} = __after_get__(entity, context, options)
      entity
    end)
  end

  def get_auth_provider(id, context, options \\ []), do: get(id, context, options)

  def login, do: Entity.ref(UUID.uuid5(:oid, "Derobot.Schema.Auth.Providers.Provider@Login"))
  def smart_token, do: Entity.ref(UUID.uuid5(:oid, "Derobot.Schema.Auth.Providers.Provider@SmartToken"))
  def oidc, do: Entity.ref(UUID.uuid5(:oid, "Derobot.Schema.Auth.Providers.Provider@OIDC"))
  def saml, do: Entity.ref(UUID.uuid5(:oid, "Derobot.Schema.Auth.Providers.Provider@SAML"))
  def google, do: Entity.ref(UUID.uuid5(:oid, "Derobot.Schema.Auth.Providers.Provider@Google"))
  def facebook, do: Entity.ref(UUID.uuid5(:oid, "Derobot.Schema.Auth.Providers.Provider@Facebook"))
  def github, do: Entity.ref(UUID.uuid5(:oid, "Derobot.Schema.Auth.Providers.Provider@GitHub"))
  def linkedin, do: Entity.ref(UUID.uuid5(:oid, "Derobot.Schema.Auth.Providers.Provider@LinkedIn"))
end
