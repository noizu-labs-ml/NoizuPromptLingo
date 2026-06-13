defmodule Derobot.Users.Credentials do
  alias Derobot.Users.Credentials.UserCredential, as: Entity
  alias Derobot.Schema.Users.Credentials.UserCredential, as: Schema
  use Noizu.Repo
  import Ecto.Query, only: [from: 2]

  def_repo(entity: Derobot.Users.Credentials.UserCredential)

  def list(context, options \\ []) do
    settings = Noizu.Entity.Meta.persistence(Entity) |> hd

    Derobot.Repo.all(Schema)
    |> Enum.map(fn record ->
      {:ok, entity} = Entity.from_record(record, settings, context, options)
      {:ok, entity} = __after_get__(entity, context, options)
      entity
    end)
  end

  def get_credential(id, context, options \\ []), do: get(id, context, options)

  def register(user, {:login, {email, password}}, context, _options) do
    {:ok, auth_provider} = Derobot.Auth.Providers.login()
    hashed_password = Bcrypt.hash_pwd_salt(password)

    {:ok, credential} =
      %Derobot.Users.Credentials.UserCredential{
        user: user,
        auth_provider: auth_provider,
        status: :active,
        settings: %{email: email, password: hashed_password},
        state: %{},
        fingerprint: "#{email}:#{hashed_password}",
        time_stamp: Noizu.Entity.TimeStamp.now()
      }
      |> Derobot.EntityRepo.create(context)

    {:ok, credential}
  end

  def authenticate({:login, {email, password}}, context, options) do
    {:ok, auth_provider} = Derobot.Auth.Providers.login()
    {:ok, auth_provider_id} = Derobot.Auth.Providers.Provider.id(auth_provider)

    with :valid <- valid_login?(email, password) do
      q =
        from u in Schema,
          where: u.auth_provider_id == ^auth_provider_id,
          where: u.status == :active,
          where: u.settings["email"] == ^email,
          select: u

      case Derobot.Repo.all(q) do
        [] ->
          {:error, :invalid_credentials}

        [credential] ->
          if Bcrypt.verify_pass(password, credential.settings["password"]) do
            with {:ok, credential_entity} <-
                   Derobot.Users.Credentials.UserCredential.entity(credential.id, context),
                 {:ok, user} <- Noizu.EntityReference.Protocol.entity(credential_entity.user, context) do
              %Derobot.Users.Sessions.UserSession{
                user: user,
                credential: credential_entity,
                status: :active,
                details: %{},
                time_stamp: Noizu.Entity.TimeStamp.now()
              }
              |> Derobot.EntityRepo.create(context, options)
            end
          else
            {:error, {:login, :invalid_credentials}}
          end

        _error ->
          {:error, {:login, :internal_error}}
      end
    end
  end

  def update_password(user, new_password, context) do
    {:ok, auth_provider} = Derobot.Auth.Providers.login()
    {:ok, auth_provider_id} = Derobot.Auth.Providers.Provider.id(auth_provider)

    email =
      case user do
        %{email: e} -> e
        _ -> nil
      end

    q =
      from c in Schema,
        where: c.user_id == ^user.id,
        where: c.auth_provider_id == ^auth_provider_id,
        where: c.status == :active,
        limit: 1

    case Derobot.Repo.one(q) do
      nil ->
        {:error, :credential_not_found}

      credential ->
        hashed = Bcrypt.hash_pwd_salt(new_password)

        credential
        |> Ecto.Changeset.change(%{
          settings: %{"email" => email || credential.settings["email"], "password" => hashed},
          fingerprint: "#{email || credential.settings["email"]}:#{hashed}"
        })
        |> Derobot.Repo.update()
    end
  end

  def standardize_email(email) do
    email |> String.trim() |> String.downcase()
  end

  def valid_login?(email, password) do
    email = standardize_email(email)
    password = String.trim(password)

    cond do
      String.length(email) < 3 -> {:error, :invalid_email}
      String.length(password) < 6 -> {:error, :invalid_password}
      :else -> :valid
    end
  end

  def login_available?(email, _context, _options \\ nil) do
    q = from u in Schema, where: u.settings["email"] == ^email, select: u

    case Derobot.Repo.all(q) do
      [] -> :valid
      [_ | _] -> {:error, {:login, :registered}}
      error -> {:error, {:login, {:internal, error}}}
    end
  end
end
