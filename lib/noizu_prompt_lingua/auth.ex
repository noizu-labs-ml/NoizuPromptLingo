defmodule NoizuPromptLingua.Auth do
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{User, McpApiKey}
  import Ecto.Query

  def find_or_create_user(%{"sub" => sub, "email" => email} = attrs) do
    case Repo.get_by(User, sub: sub) do
      nil ->
        %User{}
        |> User.changeset(%{sub: sub, email: email, name: attrs["name"]})
        |> Repo.insert()

      user ->
        user
        |> User.changeset(%{email: email, name: attrs["name"]})
        |> Repo.update()
    end
  end

  def generate_api_key(user_id, label \\ "default") do
    raw_key = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    prefix = String.slice(raw_key, 0, 8)
    hash = Bcrypt.hash_pwd_salt(raw_key)

    result =
      %McpApiKey{}
      |> McpApiKey.create_changeset(%{
        user_id: user_id,
        label: label,
        key_prefix: prefix,
        key_hash: hash
      })
      |> Repo.insert()

    case result do
      {:ok, key} -> {:ok, key, raw_key}
      error -> error
    end
  end

  def verify_api_key(raw_key) do
    prefix = String.slice(raw_key, 0, 8)

    McpApiKey
    |> where([k], k.key_prefix == ^prefix and k.status == "active")
    |> Repo.all()
    |> Enum.find(fn key -> Bcrypt.verify_pass(raw_key, key.key_hash) end)
    |> case do
      nil ->
        Bcrypt.no_user_verify()
        nil

      key ->
        key
        |> Ecto.Changeset.change(last_used_at: DateTime.utc_now())
        |> Repo.update()

        Repo.preload(key, :user)
    end
  end

  def list_api_keys(user_id) do
    McpApiKey
    |> where([k], k.user_id == ^user_id and k.status == "active")
    |> order_by([k], [desc: k.inserted_at])
    |> Repo.all()
  end

  def get_active_key(key_id, user_id) do
    McpApiKey
    |> where([k], k.id == ^key_id and k.user_id == ^user_id and k.status == "active")
    |> Repo.one()
    |> case do
      nil -> {:error, :not_found}
      key -> key
    end
  end

  def revoke_api_key(key_id, user_id) do
    McpApiKey
    |> where([k], k.id == ^key_id and k.user_id == ^user_id)
    |> Repo.one()
    |> case do
      nil -> {:error, :not_found}
      key ->
        key
        |> Ecto.Changeset.change(status: "revoked")
        |> Repo.update()
    end
  end
end
