defmodule NoizuPromptLingua.OAuth.Clients do
  @moduledoc "OAuth client registry (static + DCR)."

  import Ecto.Query
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{OAuthClient, McpPairingGrant, OAuthRefreshToken}
  alias NoizuPromptLingua.OAuth.RedirectPolicy

  def get_active(client_id) when is_binary(client_id) do
    Repo.one(
      from c in OAuthClient,
        where: c.client_id == ^client_id and c.status == "active"
    )
  end

  def get_active(_), do: nil

  @doc """
  Admin listing — every registered client (DCR + first-party), newest first,
  paired with its active pairing-grant count.
  """
  def list_all do
    grant_counts =
      from(g in McpPairingGrant,
        where: g.status == "active",
        group_by: g.client_id,
        select: {g.client_id, count(g.id)}
      )
      |> Repo.all()
      |> Map.new()

    from(c in OAuthClient, order_by: [desc: c.inserted_at])
    |> Repo.all()
    |> Enum.map(fn c -> {c, Map.get(grant_counts, c.client_id, 0)} end)
  end

  @doc """
  Revokes a client: marks it revoked and cascades to its active pairing
  grants and unexpired refresh tokens, so already-issued tokens stop working.
  """
  def revoke_client(client_id) when is_binary(client_id) do
    case Repo.one(from c in OAuthClient, where: c.client_id == ^client_id) do
      nil ->
        {:error, :not_found}

      client ->
        Repo.transaction(fn ->
          updated = client |> OAuthClient.changeset(%{status: "revoked"}) |> Repo.update!()

          from(g in McpPairingGrant, where: g.client_id == ^client_id and g.status == "active")
          |> Repo.update_all(set: [status: "revoked"])

          now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

          from(t in OAuthRefreshToken, where: t.client_id == ^client_id and is_nil(t.revoked_at))
          |> Repo.update_all(set: [revoked_at: now])

          updated
        end)
        |> tap_ok_bump_cache()
    end
  end

  # Cached OAuth clients (ToolsetCache) feed the EffectiveToolset cascade —
  # drop the cache whenever a client's config/status write lands. The cache
  # bump + tools/list_changed broadcast are ONE best-effort step (N1 manifest
  # parity): connected clients re-list before serving stale narrowing flags.
  defp tap_ok_bump_cache({:ok, _} = ok) do
    NoizuPromptLingua.MCP.Server.notify_toolset_changed()
    ok
  end

  defp tap_ok_bump_cache(other), do: other

  def revoke_client(_), do: {:error, :not_found}

  @doc """
  RFC 7591 dynamic client registration (minimal).

  Public clients (`token_endpoint_auth_method=none`) return no secret.
  Confidential clients get a secret shown once.
  """
  def register(attrs) when is_map(attrs) do
    redirect_uris = normalize_uris(attrs["redirect_uris"] || attrs[:redirect_uris])

    with :ok <- validate_redirects(redirect_uris) do
      client_id = "dcr_" <> random_id(16)

      auth_method =
        attrs["token_endpoint_auth_method"] || attrs[:token_endpoint_auth_method] || "none"

      {secret, secret_hash} = maybe_secret(auth_method)

      cs =
        %OAuthClient{}
        |> OAuthClient.changeset(%{
          client_id: client_id,
          client_secret_hash: secret_hash,
          client_name: attrs["client_name"] || attrs[:client_name] || "dynamic-client",
          redirect_uris: redirect_uris,
          grant_types: [
            "authorization_code",
            "refresh_token",
            "urn:ietf:params:oauth:grant-type:token-exchange"
          ],
          token_endpoint_auth_method: auth_method,
          scope: attrs["scope"] || attrs[:scope] || "openid mcp",
          is_first_party: false,
          status: "active",
          metadata: %{
            "software_id" => attrs["software_id"],
            "software_version" => attrs["software_version"]
          }
        })

      case Repo.insert(cs) do
        {:ok, client} ->
          body = %{
            "client_id" => client.client_id,
            "client_name" => client.client_name,
            "redirect_uris" => client.redirect_uris,
            "grant_types" => client.grant_types,
            "token_endpoint_auth_method" => client.token_endpoint_auth_method,
            "scope" => client.scope,
            "client_id_issued_at" => DateTime.to_unix(client.inserted_at || DateTime.utc_now())
          }

          body =
            if secret do
              Map.put(body, "client_secret", secret)
            else
              body
            end

          {:ok, body}

        {:error, cs} ->
          {:error, cs}
      end
    end
  end

  def authenticate_client(%OAuthClient{token_endpoint_auth_method: "none"}, _secret), do: :ok

  def authenticate_client(%OAuthClient{client_secret_hash: hash}, secret)
      when is_binary(hash) and is_binary(secret) do
    if Bcrypt.verify_pass(secret, hash), do: :ok, else: {:error, :invalid_client}
  end

  def authenticate_client(_, _), do: {:error, :invalid_client}

  @doc """
  W8: persist the consent screen's toolset narrowing on the client
  (`oauth_clients.toolset_config`, KeyToolsets shape — only blocked entries
  stored). Normalized on write via the shared API-key normalizer; an empty
  narrowing stores `%{}` (= no narrowing = legacy ungated behavior).
  """
  def update_toolset_config(%OAuthClient{} = client, config) do
    normalized = NoizuPromptLingua.MCPApiKeys.normalize_toolset(config || %{})

    # A narrowing with no entries collapses to the bare empty config so the
    # row stays byte-identical to legacy clients (config_for/1 treats %{} as nil).
    normalized =
      if Map.get(normalized, "groups", %{}) == %{}, do: %{}, else: normalized

    client
    |> OAuthClient.changeset(%{toolset_config: normalized})
    |> Repo.update()
    |> tap_ok_bump_cache()
  end

  def update_toolset_config(_, _), do: {:error, :invalid_client}

  def create_first_party!(attrs) do
    client_id = attrs[:client_id] || "fp_" <> random_id(8)

    %OAuthClient{}
    |> OAuthClient.changeset(%{
      client_id: client_id,
      client_secret_hash: nil,
      client_name: attrs[:client_name] || "first-party",
      redirect_uris: attrs[:redirect_uris] || [],
      grant_types: attrs[:grant_types] || ["authorization_code", "refresh_token"],
      token_endpoint_auth_method: "none",
      scope: attrs[:scope] || "openid mcp",
      is_first_party: true,
      status: "active"
    })
    |> Repo.insert!()
  end

  defp validate_redirects([]), do: {:error, :invalid_redirect_uri}

  defp validate_redirects(uris) do
    if Enum.all?(uris, &RedirectPolicy.allowed_for_registration?/1) do
      :ok
    else
      {:error, :invalid_redirect_uri}
    end
  end

  defp normalize_uris(list) when is_list(list), do: Enum.map(list, &to_string/1) |> Enum.uniq()
  defp normalize_uris(_), do: []

  defp maybe_secret("none"), do: {nil, nil}

  defp maybe_secret(_) do
    secret = random_id(32)
    {secret, Bcrypt.hash_pwd_salt(secret)}
  end

  defp random_id(n), do: :crypto.strong_rand_bytes(n) |> Base.url_encode64(padding: false)
end
