defmodule Starter.Auth.TokenStore do
  @refresh_ttl 7 * 24 * 60 * 60

  def store_refresh_jti(jti) when is_binary(jti) do
    Starter.Redis.set("refresh_jti:#{jti}", "1", ex: @refresh_ttl)
  end

  def valid_refresh_jti?(jti) when is_binary(jti) do
    case Starter.Redis.get("refresh_jti:#{jti}") do
      {:ok, "1"} -> true
      _ -> false
    end
  end

  def revoke_refresh_jti(jti) when is_binary(jti) do
    Starter.Redis.del("refresh_jti:#{jti}")
  end
end
