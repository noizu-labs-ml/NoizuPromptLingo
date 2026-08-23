defmodule NoizuPromptLingua.Auth.TokenStore do
  @moduledoc """
  Refresh-token revocation list in Redis.

  When Redis is reachable, a refresh JWT is accepted only if its `jti` was
  stored at issue time (and not revoked). When Redis is down or unconfigured
  the Guardian signature+expiry still stand — fail-open so SSO sessions can
  refresh instead of bouncing every user to /login after one hour.
  """
  require Logger

  @refresh_ttl 7 * 24 * 60 * 60

  def store_refresh_jti(jti) when is_binary(jti) do
    case NoizuPromptLingua.Redis.set("refresh_jti:#{jti}", "1", ex: @refresh_ttl) do
      {:ok, _} -> :ok
      other ->
        Logger.warning("[TokenStore] failed to persist refresh jti: #{inspect(other)}")
        :ok
    end
  end

  def valid_refresh_jti?(jti) when is_binary(jti) do
    case NoizuPromptLingua.Redis.get("refresh_jti:#{jti}") do
      {:ok, "1"} ->
        true

      {:ok, _} ->
        false

      {:error, reason} ->
        Logger.warning(
          "[TokenStore] redis unavailable (#{inspect(reason)}); accepting signed refresh JWT"
        )

        true
    end
  end

  def revoke_refresh_jti(jti) when is_binary(jti) do
    _ = NoizuPromptLingua.Redis.del("refresh_jti:#{jti}")
    :ok
  end
end
