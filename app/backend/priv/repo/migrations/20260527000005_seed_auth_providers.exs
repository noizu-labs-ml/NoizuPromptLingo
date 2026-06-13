defmodule Derobot.Repo.Migrations.SeedAuthProviders do
  use Ecto.Migration

  def up do
    providers = [
      {"Login", "Derobot.Schema.Auth.Providers.Provider@Login"},
      {"SmartToken", "Derobot.Schema.Auth.Providers.Provider@SmartToken"},
      {"OIDC", "Derobot.Schema.Auth.Providers.Provider@OIDC"},
      {"SAML", "Derobot.Schema.Auth.Providers.Provider@SAML"},
      {"Google", "Derobot.Schema.Auth.Providers.Provider@Google"},
      {"Facebook", "Derobot.Schema.Auth.Providers.Provider@Facebook"},
      {"GitHub", "Derobot.Schema.Auth.Providers.Provider@GitHub"},
      {"LinkedIn", "Derobot.Schema.Auth.Providers.Provider@LinkedIn"}
    ]

    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:microsecond)

    for {title, oid_seed} <- providers do
      id = UUID.uuid5(:oid, oid_seed)

      execute("""
      INSERT INTO auth_providers (id, title, inserted_at, updated_at)
      VALUES ('#{id}', '#{title}', '#{now}', '#{now}')
      ON CONFLICT (id) DO NOTHING
      """)
    end
  end

  def down do
    execute("DELETE FROM auth_providers")
  end
end
