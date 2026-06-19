defmodule NoizuPromptLingua.Auth.TokenStoreTest do
  use ExUnit.Case

  alias NoizuPromptLingua.Auth.TokenStore

  setup do
    jti = "test-jti-#{System.unique_integer([:positive])}"
    {:ok, jti: jti}
  end

  test "store and validate JTI", %{jti: jti} do
    assert TokenStore.valid_refresh_jti?(jti) == false

    TokenStore.store_refresh_jti(jti)
    assert TokenStore.valid_refresh_jti?(jti) == true
  end

  test "revoke JTI", %{jti: jti} do
    TokenStore.store_refresh_jti(jti)
    assert TokenStore.valid_refresh_jti?(jti) == true

    TokenStore.revoke_refresh_jti(jti)
    assert TokenStore.valid_refresh_jti?(jti) == false
  end
end
