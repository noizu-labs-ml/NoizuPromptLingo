defmodule NoizuPromptLingua.MCPApiKeys do
  @moduledoc """
  Context for MCP API keys — long-lived credentials a user presents to mint
  short-lived MCP JWTs via `POST /api/mcp/token`.

  The raw key is generated as 32 random bytes, base64url-encoded, and shown to
  the caller exactly once. We persist only an 8-char prefix (for lookup) and a
  bcrypt hash of the full key. Ported from the legacy project's `Auth` module.
  """

  alias NoizuPromptLingua.Schema.McpApiKey, as: KeySchema

  import Ecto.Query

  @doc """
  Generates a new API key for `user_id`. Returns `{:ok, key, raw_key}` — the
  `raw_key` is the only chance to see the secret and must be returned to the
  user immediately.

  Accepts `expires_at: %DateTime{} | nil` in `opts` for a key that stops
  verifying after a given time (see `parse_expires_at/1` to build it from a
  request param).
  """
  def generate_api_key(user_id, label \\ "default", opts \\ []) do
    raw_key = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    key_prefix = String.slice(raw_key, 0, 8)
    key_hash = Bcrypt.hash_pwd_salt(raw_key)

    attrs =
      %{
        user_id: user_id,
        label: label,
        key_prefix: key_prefix,
        key_hash: key_hash
      }
      |> maybe_put_expires_at(Keyword.get(opts, :expires_at))

    case %KeySchema{} |> KeySchema.create_changeset(attrs) |> NoizuPromptLingua.Repo.insert() do
      {:ok, key} -> {:ok, key, raw_key}
      {:error, _} = err -> err
    end
  end

  defp maybe_put_expires_at(attrs, nil), do: attrs
  defp maybe_put_expires_at(attrs, %DateTime{} = dt), do: Map.put(attrs, :expires_at, dt)

  @doc """
  Parses an optional `expires_at` request param into `{:ok, %DateTime{} | nil}`
  for `generate_api_key/3`, or `:error` if it's present but not a valid,
  future ISO8601 timestamp. `nil`/blank means "no expiry".
  """
  def parse_expires_at(nil), do: {:ok, nil}
  def parse_expires_at(""), do: {:ok, nil}

  def parse_expires_at(str) when is_binary(str) do
    case DateTime.from_iso8601(str) do
      {:ok, dt, _offset} ->
        if DateTime.compare(dt, DateTime.utc_now()) == :gt do
          {:ok, dt}
        else
          :error
        end

      {:error, _} ->
        :error
    end
  end

  def parse_expires_at(_), do: :error

  @doc """
  Verifies a raw API key (during sign-in, not JWT). Looks up by prefix among
  active keys, bcrypt-verifies the full key, and stamps last_used_at on success.
  Returns the key with its user preloaded, or nil.
  """
  def verify_api_key(raw_key) when is_binary(raw_key) do
    prefix = String.slice(raw_key, 0, 8)
    now = DateTime.utc_now()

    KeySchema
    |> where([k], k.key_prefix == ^prefix and k.status == "active")
    |> where([k], is_nil(k.expires_at) or k.expires_at > ^now)
    |> preload([k], [:user])
    |> NoizuPromptLingua.Repo.all()
    |> Enum.find(fn key -> Bcrypt.verify_pass(raw_key, key.key_hash) end)
    |> case do
      nil ->
        nil

      key ->
        key
        |> KeySchema.status_changeset(%{last_used_at: DateTime.utc_now()})
        |> NoizuPromptLingua.Repo.update()

        key
    end
  end

  def list_for_user(user_id) do
    KeySchema
    |> where([k], k.user_id == ^user_id)
    |> order_by([k], desc: k.inserted_at)
    |> NoizuPromptLingua.Repo.all()
  end

  def revoke(id) do
    case NoizuPromptLingua.Repo.get(KeySchema, id) do
      nil ->
        {:error, :not_found}

      key ->
        key |> KeySchema.status_changeset(%{status: "revoked"}) |> NoizuPromptLingua.Repo.update()
    end
  end
end
