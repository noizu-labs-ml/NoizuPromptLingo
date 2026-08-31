defmodule NoizuPromptLingua.MCPApiKeys do
  @moduledoc """
  Context for MCP API keys — long-lived credentials a user presents to mint
  short-lived MCP JWTs via `POST /api/mcp/token`.

  The raw key is generated as 32 random bytes, base64url-encoded, and shown to
  the caller exactly once. We persist only an 8-char prefix (for lookup) and a
  bcrypt hash of the full key. Ported from the legacy project's `Auth` module.

  Keys may also carry a per-key MCP toolset (`toolset_config` — per tool and
  per group `disabled`/`hidden` flags that override the custom-scope cascade).
  `clone/2` duplicates a key's toolset onto a new key; `copy_toolset_from/2`
  adopts a custom scope's config onto a key. Raw key values are never returned
  by any function here except `generate_api_key/3`.
  """

  alias NoizuPromptLingua.Schema.McpApiKey, as: KeySchema
  alias NoizuPromptLingua.MCPCustomScopes

  # Scoped import: a bare `import Ecto.Query` would pull in `Ecto.Query.update/3`,
  # whose macro expansion shadows this module's `update/3` (see MCPCustomScopes).
  import Ecto.Query, only: [where: 3, order_by: 3, preload: 3]

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
      |> maybe_put_toolset(Keyword.get(opts, :toolset_config))

    case %KeySchema{} |> KeySchema.create_changeset(attrs) |> NoizuPromptLingua.Repo.insert() do
      {:ok, key} -> {:ok, key, raw_key}
      {:error, _} = err -> err
    end
  end

  defp maybe_put_expires_at(attrs, nil), do: attrs
  defp maybe_put_expires_at(attrs, %DateTime{} = dt), do: Map.put(attrs, :expires_at, dt)

  defp maybe_put_toolset(attrs, nil), do: attrs
  defp maybe_put_toolset(attrs, config), do: Map.put(attrs, :toolset_config, normalize_toolset(config))

  @doc """
  Normalize a toolset config to the canonical shape (string keys, known groups
  only, boolean flags only). Reuses the custom-scope normalizer with
  `kind: "custom"` semantics — no required-core enforcement on keys.
  """
  def normalize_toolset(config) when is_map(config),
    do: MCPCustomScopes.normalize_config(config, "custom")

  def normalize_toolset(_), do: %{"groups" => %{}}

  @doc "Fetch a key by id (any status)."
  def get(id) when is_binary(id), do: NoizuPromptLingua.Repo.get(KeySchema, id)
  def get(_), do: nil

  @doc """
  Update a key's label / status / toolset_config. `toolset_config` is
  normalized on write; `nil` leaves it untouched. Only keys owned by
  `user_id` are writable when `owner_id` is given (MCP/user-scoped callers);
  admin callers pass `owner_id: nil`.
  """
  def update(key_or_id, attrs, opts \\ [])

  def update(%KeySchema{} = key, attrs, opts) do
    with :ok <- check_owner(key, Keyword.get(opts, :owner_id)) do
      key
      |> KeySchema.toolset_changeset(normalize_update_attrs(attrs))
      |> NoizuPromptLingua.Repo.update()
      |> bump_cache_on_ok()
    end
  end

  def update(id, attrs, opts) when is_binary(id) do
    case get(id) do
      nil -> {:error, :not_found}
      key -> update(key, attrs, opts)
    end
  end

  defp check_owner(_key, nil), do: :ok
  defp check_owner(%{user_id: user_id}, owner_id) when user_id == owner_id, do: :ok
  defp check_owner(_, _), do: {:error, :forbidden}

  defp normalize_update_attrs(attrs) when is_map(attrs) do
    %{}
    |> maybe_put(:label, Map.get(attrs, "label") || Map.get(attrs, :label))
    |> maybe_put(:status, Map.get(attrs, "status") || Map.get(attrs, :status))
    |> maybe_put(:toolset_config, toolset_from_attrs(attrs))
  end

  defp normalize_update_attrs(_), do: %{}

  defp toolset_from_attrs(attrs) do
    case Map.get(attrs, "toolset_config") || Map.get(attrs, :toolset_config) do
      nil -> nil
      config -> normalize_toolset(config)
    end
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  @doc """
  Duplicate `source` into a new key for the same (or `attrs[:user_id]`-given)
  owner, carrying its toolset config. Returns `{:ok, key, raw_key}` — the raw
  key of the NEW key, shown exactly once, like `generate_api_key/3`.
  """
  def clone(source, attrs \\ [])

  def clone(%KeySchema{} = source, attrs) do
    user_id = Keyword.get(attrs, :user_id) || source.user_id

    case generate_api_key(user_id, clone_label(source, attrs),
           expires_at: source.expires_at,
           toolset_config: source.toolset_config || %{}
         ) do
      {:ok, key, raw} -> {:ok, key, raw}
      {:error, _} = err -> err
    end
  end

  def clone(id, attrs) when is_binary(id) do
    case get(id) do
      nil -> {:error, :not_found}
      key -> clone(key, attrs)
    end
  end

  defp clone_label(source, attrs) do
    Keyword.get(attrs, :label) || source.label
  end

  @doc """
  Adopt a custom scope's toolset config onto `key` (replaces the key's config
  with the scope's normalized config). `ref` is a scope slug or UUID.
  """
  def copy_toolset_from(%KeySchema{} = key, ref) when is_binary(ref) do
    with {:ok, scope} <- resolve_scope(ref) do
      key
      |> KeySchema.toolset_changeset(%{
        toolset_config: MCPCustomScopes.normalize_config(scope.config || %{}, scope.kind)
      })
      |> NoizuPromptLingua.Repo.update()
      |> bump_cache_on_ok()
    end
  end

  def copy_toolset_from(key_id, ref) when is_binary(key_id) and is_binary(ref) do
    case get(key_id) do
      nil -> {:error, :not_found}
      key -> copy_toolset_from(key, ref)
    end
  end

  # Slugs and UUIDs share the string type — only pass UUID-shaped refs to the
  # by-id lookup (Repo.get with a non-UUID string raises CastError).
  defp resolve_scope(ref) do
    scope =
      MCPCustomScopes.get_by_slug(ref) ||
        (match?({:ok, _}, Ecto.UUID.cast(ref)) && MCPCustomScopes.get(ref)) ||
        nil

    case scope do
      nil -> {:error, :not_found}
      scope -> {:ok, scope}
    end
  end

  @doc "Masked projection for API/tool responses — never includes key_hash or any raw value."
  def mask(%KeySchema{} = key) do
    %{
      id: key.id,
      label: key.label,
      key_prefix: key.key_prefix,
      status: key.status,
      last_used_at: key.last_used_at,
      expires_at: key.expires_at,
      toolset_config: key.toolset_config,
      inserted_at: key.inserted_at
    }
  end

  def mask(_), do: nil

  @doc "List every key (admin surface). Mask via mask/1 before returning."
  def list_all do
    KeySchema |> order_by([k], desc: k.inserted_at) |> NoizuPromptLingua.Repo.all()
  end


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
        key
        |> KeySchema.status_changeset(%{status: "revoked"})
        |> NoizuPromptLingua.Repo.update()
        |> bump_cache_on_ok()
    end
  end

  # Cached keys (ToolsetCache) feed the EffectiveToolset cascade — drop the
  # cache whenever a key's status/toolset write lands.
  defp bump_cache_on_ok({:ok, _} = ok) do
    NoizuPromptLingua.MCP.ToolsetCache.bump()
    ok
  end

  defp bump_cache_on_ok(other), do: other
end
