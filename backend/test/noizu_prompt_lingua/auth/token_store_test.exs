defmodule NoizuPromptLingua.Auth.TokenStoreTest do
  @moduledoc """
  `Auth.TokenStore` — Redis-backed refresh-jti revocation list.

  Fail-open is DOCUMENTED behavior (moduledoc): when Redis is unreachable the
  Guardian signature+expiry still stand, so a refresh JWT is accepted. The
  lifecycle assertions run when Redis is reachable; the fail-open branch is
  pinned otherwise.
  """

  use ExUnit.Case, async: false

  alias NoizuPromptLingua.Auth.TokenStore

  defp jti, do: "jti-" <> Base.url_encode64(:crypto.strong_rand_bytes(12), padding: false)

  defp redis_up?,
    do: match?({:ok, _}, NoizuPromptLingua.Redis.set("token_store:probe", "1", ex: 5))

  test "refresh jti lifecycle (store → valid → revoke → invalid)" do
    jti = jti()

    assert TokenStore.store_refresh_jti(jti) == :ok

    if redis_up?() do
      assert TokenStore.valid_refresh_jti?(jti) == true
      assert TokenStore.valid_refresh_jti?("never-stored-" <> jti) == false

      assert TokenStore.revoke_refresh_jti(jti) == :ok
      assert TokenStore.valid_refresh_jti?(jti) == false
    else
      # Redis unreachable: documented fail-open — signed refresh JWTs accepted.
      assert TokenStore.valid_refresh_jti?(jti) == true
      assert TokenStore.revoke_refresh_jti(jti) == :ok
    end
  end

  test "store and revoke tolerate every Redis outcome (:ok either way)" do
    assert TokenStore.store_refresh_jti(jti()) == :ok
    assert TokenStore.revoke_refresh_jti(jti()) == :ok
  end
end
