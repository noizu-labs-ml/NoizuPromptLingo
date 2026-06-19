defmodule NoizuPromptLingua.Auth.Providers do
  alias NoizuPromptLingua.Auth.Providers.Provider, as: Entity
  alias NoizuPromptLingua.Schema.Auth.Providers.Provider, as: Schema
  use Noizu.Repo
  def_repo(entity: Entity)

  def list(context, options \\ []) do
    settings = Noizu.Entity.Meta.persistence(Entity) |> hd
    NoizuPromptLingua.Repo.all(Schema)
    |> Enum.map(fn record ->
      {:ok, entity} = Entity.from_record(record, settings, context, options)
      {:ok, entity} = __after_get__(entity, context, options)
      entity
    end)
  end

  def get_auth_provider(id, context, options \\ []), do: get(id, context, options)

  def create(auth_provider, context, options \\ []) do
    %Entity{}
    |> change(auth_provider)
    |> create(context, options)
  end

  def update(%Entity{} = auth_provider, attrs, context, options \\ []) do
    auth_provider
    |> change(attrs)
    |> update(context, options)
  end

  def delete(%Entity{} = auth_provider, context, options \\ []) do
    delete(auth_provider, context, options)
  end

  def change(%Entity{} = auth_provider, attrs \\ %{}) do
    attrs =
      Enum.map(attrs, fn
        {"title", value} -> {:title, value}
        {"description", value} -> {:description, value}
        {"settings", value} -> {:settings, value}
        {"id", value} -> {:id, value}
        {k, v} when is_atom(k) -> {k, v}
        _ -> nil
      end)
      |> Enum.reject(&is_nil/1)

    Ecto.Changeset.change(
      {auth_provider, Noizu.Entity.Meta.meta(Entity)[:changeset_fields]},
      attrs
    )
  end

  def login() do
    Entity.ref(UUID.uuid5(:oid, "NoizuPromptLingua.Schema.Auth.Providers.Provider@Login"))
  end

  def smart_token() do
    Entity.ref(UUID.uuid5(:oid, "NoizuPromptLingua.Schema.Auth.Providers.Provider@SmartToken"))
  end

  def oidc() do
    Entity.ref(UUID.uuid5(:oid, "NoizuPromptLingua.Schema.Auth.Providers.Provider@OIDC"))
  end

  def authentik() do
    Entity.ref(UUID.uuid5(:oid, "NoizuPromptLingua.Schema.Auth.Providers.Provider@Authentik"))
  end

  def saml() do
    Entity.ref(UUID.uuid5(:oid, "NoizuPromptLingua.Schema.Auth.Providers.Provider@SAML"))
  end

  def google() do
    Entity.ref(UUID.uuid5(:oid, "NoizuPromptLingua.Schema.Auth.Providers.Provider@Google"))
  end

  def facebook() do
    Entity.ref(UUID.uuid5(:oid, "NoizuPromptLingua.Schema.Auth.Providers.Provider@Facebook"))
  end

  def github() do
    Entity.ref(UUID.uuid5(:oid, "NoizuPromptLingua.Schema.Auth.Providers.Provider@GitHub"))
  end

  def linkedin() do
    Entity.ref(UUID.uuid5(:oid, "NoizuPromptLingua.Schema.Auth.Providers.Provider@LinkedIn"))
  end
end
