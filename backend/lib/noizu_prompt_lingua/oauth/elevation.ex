defmodule NoizuPromptLingua.OAuth.Elevation do
  @moduledoc """
  Single-use elevation tokens for `:destructive` MCP tools (Phase 4 step-up).

  Flow:
  1. ToolGuard denies with elevation_uri when sensitivity is destructive and no
     valid elevation claim is present.
  2. User opens `/oauth/elevate?txn=...` (session required) and approves.
  3. A short-lived JWT (`token_use=elevation`, single tool + arg hash) is issued.
  4. Client retries with `Authorization: Bearer <access>` and
     `X-MCP-Elevation: <elevation_jwt>` (or elevation claim nested).

  Storage: ETS for pending transactions (process-local; multi-replica needs Redis
  later). Elevation JWTs are self-contained and verified via JWKS.
  """

  alias NoizuPromptLingua.OAuth.{AuthorizationServer, Jwks}

  @table :mcp_elevation_txns
  @active_table :mcp_elevation_active
  @ttl_seconds 120
  @jwt_ttl 60

  def ensure_table! do
    for t <- [@table, @active_table] do
      case :ets.whereis(t) do
        :undefined ->
          :ets.new(t, [:named_table, :public, :set, read_concurrency: true])

        _ ->
          :ok
      end
    end

    :ok
  end

  def create_txn!(attrs) do
    ensure_table!()
    txn = "elv_" <> random_id(16)
    now = System.system_time(:second)

    entry = %{
      txn: txn,
      user_id: attrs.user_id,
      tool: attrs.tool,
      action: attrs[:action],
      args_hash: attrs[:args_hash],
      expires_at: now + @ttl_seconds
    }

    :ets.insert(@table, {txn, entry})
    txn
  end

  def get_txn(txn) when is_binary(txn) do
    ensure_table!()
    now = System.system_time(:second)

    case :ets.lookup(@table, txn) do
      [{^txn, %{expires_at: exp} = entry}] when exp > now -> {:ok, entry}
      [{^txn, _}] ->
        :ets.delete(@table, txn)
        {:error, :expired}

      [] ->
        {:error, :not_found}
    end
  end

  def approve!(txn, user_id) when is_binary(txn) and is_binary(user_id) do
    with {:ok, entry} <- get_txn(txn),
         true <- entry.user_id == user_id || {:error, :forbidden} do
      :ets.delete(@table, txn)
      now = System.system_time(:second)
      # Allow retries without custom header within JWT TTL (same user+tool).
      :ets.insert(
        @active_table,
        {{user_id, entry.tool}, %{args_hash: entry[:args_hash], expires_at: now + @jwt_ttl}}
      )

      mint_elevation_jwt(entry)
    else
      false -> {:error, :forbidden}
      {:error, _} = e -> e
    end
  end

  def mint_elevation_jwt(entry) do
    now = System.system_time(:second)
    exp = now + @jwt_ttl

    claims = %{
      "sub" => "user:#{entry.user_id}",
      "user_id" => entry.user_id,
      "iss" => AuthorizationServer.issuer_url(),
      "iat" => now,
      "exp" => exp,
      "token_use" => "elevation",
      "amr" => ["hitl"],
      "jti" => random_id(12),
      "tool" => entry.tool,
      "action" => entry[:action],
      "args_hash" => entry[:args_hash]
    }

    jwk_entry = Jwks.signing_entry()
    header = %{"alg" => jwk_entry.alg, "kid" => jwk_entry.kid, "typ" => "JWT"}
    {_, token} = JOSE.JWT.sign(jwk_entry.jwk, header, claims) |> JOSE.JWS.compact()
    {:ok, token, exp}
  end

  @doc """
  Verify elevation for a tool.

  Accepts either an elevation JWT string, or `{:user, user_id}` to check the
  short-lived in-process grant created at approve time (browser step-up without
  custom headers).
  """
  def verify_for_tool({:user, user_id}, tool, args_hash)
      when is_binary(user_id) and is_binary(tool) do
    ensure_table!()
    now = System.system_time(:second)

    case :ets.lookup(@active_table, {user_id, tool}) do
      [{_, %{expires_at: exp, args_hash: h}}] when exp > now ->
        if is_nil(args_hash) or h in [nil, args_hash] do
          :ets.delete(@active_table, {user_id, tool})
          {:ok, %{amr: ["hitl"]}}
        else
          {:error, :args_mismatch}
        end

      _ ->
        {:error, :no_active_elevation}
    end
  end

  def verify_for_tool(token, tool, args_hash) when is_binary(token) and is_binary(tool) do
    opts = [
      secret: {NoizuPromptLingua.MCPAuth, :secret},
      issuer: AuthorizationServer.jwt_issuers(),
      validate_api_key: fn _ -> true end,
      require_aud: false
    ]

    case NoizuPromptLingua.MCP.DualTokenVerifier.verify(
           token,
           %{method: "POST", peer: nil, headers: []},
           opts
         ) do
      {:ok, %{"token_use" => "elevation", "tool" => t} = claims} when t == tool ->
        cond do
          is_nil(args_hash) -> {:ok, claims}
          claims["args_hash"] in [nil, args_hash] -> {:ok, claims}
          true -> {:error, :args_mismatch}
        end

      {:ok, _} ->
        {:error, :wrong_tool}

      _ ->
        {:error, :invalid_elevation}
    end
  end

  def verify_for_tool(_, _, _), do: {:error, :invalid_elevation}

  def args_hash(args) when is_map(args) do
    :crypto.hash(:sha256, Jason.encode!(args)) |> Base.encode16(case: :lower) |> binary_part(0, 16)
  end

  def args_hash(_), do: nil

  def elevation_uri(txn) do
    base = AuthorizationServer.issuer_url() |> String.trim_trailing("/")
    "#{base}/oauth/elevate?txn=#{URI.encode_www_form(txn)}"
  end

  defp random_id(n), do: :crypto.strong_rand_bytes(n) |> Base.url_encode64(padding: false)
end
