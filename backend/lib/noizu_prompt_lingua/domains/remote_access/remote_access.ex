defmodule NoizuPromptLingua.Domains.RemoteAccess do
  @moduledoc """
  Named, authenticated, revocable reverse tunnels (`<name>.remote-access.noizu.com`).

  A user claims a `name` within an org and receives a one-time `tunnel_token`
  (only its SHA-256 hash is stored). The local `frpc` client presents that token
  to the `frps` server, which validates it through `authorize_login/1` and
  `authorize_proxy/2` via the `/api/v1/remote-access/frp-auth` callback.
  """

  import Ecto.Query
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.RemoteAccess.Tunnel

  @default_ttl_days 30

  @doc """
  Claim (or re-claim) `name` for `user_id` in `organization_id`. Returns
  `{:ok, tunnel, raw_token}` with the token shown once. Re-claiming a name the
  same user already holds rotates its token; a name held by another user is
  rejected with `{:error, :name_taken}`.
  """
  def claim_tunnel(user_id, organization_id, name, opts \\ []) do
    name = normalize(name)
    {raw_token, hash} = generate_token()

    expires_at =
      DateTime.utc_now()
      |> DateTime.add(ttl_days(opts) * 86_400, :second)
      |> DateTime.truncate(:second)

    attrs = %{
      organization_id: organization_id,
      user_id: user_id,
      name: name,
      tunnel_token_hash: hash,
      proxy_type: opts[:proxy_type] || "http",
      status: "active",
      expires_at: expires_at
    }

    case active_by_name(name) do
      %Tunnel{user_id: ^user_id} = existing ->
        existing
        |> Tunnel.changeset(%{
          tunnel_token_hash: hash,
          expires_at: expires_at,
          proxy_type: attrs.proxy_type
        })
        |> Repo.update()
        |> with_token(raw_token)

      %Tunnel{} ->
        {:error, :name_taken}

      nil ->
        %Tunnel{}
        |> Tunnel.changeset(attrs)
        |> Repo.insert()
        |> case do
          {:ok, t} ->
            {:ok, t, raw_token}

          {:error, %{errors: errors}} = err ->
            if Keyword.has_key?(errors, :name), do: {:error, :name_taken}, else: err
        end
    end
  end

  @doc "List a user's tunnel claims (active + revoked) within an org, newest first."
  def list_tunnels(user_id, organization_id) do
    Repo.all(
      from t in Tunnel,
        where: t.user_id == ^user_id and t.organization_id == ^organization_id,
        order_by: [desc: t.inserted_at]
    )
  end

  @doc "Revoke (tombstone) a name owned by `user_id`. Frees the active-name slot."
  def revoke_tunnel(user_id, name) do
    case active_by_name(normalize(name)) do
      %Tunnel{user_id: ^user_id} = t ->
        t |> Tunnel.changeset(%{status: "revoked"}) |> Repo.update()

      %Tunnel{} ->
        {:error, :not_owner}

      nil ->
        {:error, :not_found}
    end
  end

  @doc "True when a name has a live (connected) active claim — for status display."
  def connected?(name) do
    case active_by_name(normalize(name)) do
      %Tunnel{last_connected_at: %DateTime{}} -> true
      _ -> false
    end
  end

  # ── frps callbacks ─────────────────────────────────────────────────────────

  @doc "frps `Login`: validate the presented token, mark connected. :ok | :deny."
  def authorize_login(token) when is_binary(token) do
    case lookup_active(token) do
      %Tunnel{} = t ->
        t |> Tunnel.changeset(%{last_connected_at: now()}) |> Repo.update()
        :ok

      _ ->
        :deny
    end
  end

  def authorize_login(_), do: :deny

  @doc "frps `NewProxy`: the token's claim must own the requested subdomain. :ok | :deny."
  def authorize_proxy(token, subdomain) when is_binary(token) and is_binary(subdomain) do
    case lookup_active(token) do
      %Tunnel{name: name} -> if name == normalize(subdomain), do: :ok, else: :deny
      _ -> :deny
    end
  end

  def authorize_proxy(_, _), do: :deny

  @doc "frps `CloseProxy`: mark the claim disconnected."
  def mark_disconnected(token) when is_binary(token) do
    case lookup_active(token) do
      %Tunnel{} = t -> t |> Tunnel.changeset(%{last_connected_at: nil}) |> Repo.update()
      _ -> :ok
    end
  end

  def mark_disconnected(_), do: :ok

  # ── internals ──────────────────────────────────────────────────────────────

  defp lookup_active(token) do
    hash = hash_token(token)
    now = now()

    Repo.one(
      from t in Tunnel,
        where:
          t.tunnel_token_hash == ^hash and t.status == "active" and
            (is_nil(t.expires_at) or t.expires_at > ^now)
    )
  end

  defp active_by_name(name) do
    Repo.one(from t in Tunnel, where: t.name == ^name and t.status == "active")
  end

  defp generate_token do
    raw = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    {raw, hash_token(raw)}
  end

  defp hash_token(token), do: :crypto.hash(:sha256, token) |> Base.encode16(case: :lower)

  defp normalize(name), do: name |> to_string() |> String.downcase() |> String.trim()

  defp now, do: DateTime.utc_now() |> DateTime.truncate(:second)

  defp ttl_days(opts), do: opts[:ttl_days] || @default_ttl_days

  defp with_token({:ok, tunnel}, raw_token), do: {:ok, tunnel, raw_token}
  defp with_token({:error, _} = err, _raw_token), do: err
end
