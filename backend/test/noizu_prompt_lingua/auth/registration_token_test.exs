defmodule NoizuPromptLingua.Auth.RegistrationTokenTest do
  @moduledoc """
  `Auth.RegistrationToken` — stateless Phoenix.Token carrying the verified
  SSO identity from the OIDC callback to the register form (10-min max age).
  """

  use ExUnit.Case, async: false

  alias NoizuPromptLingua.Auth.RegistrationToken

  @identity %{provider: "authentik", sub: "s-1", email: "user@example.com"}

  test "sign/verify round-trips the verified identity" do
    token = RegistrationToken.sign(@identity)
    assert is_binary(token)
    assert {:ok, @identity} = RegistrationToken.verify(token)
  end

  test "a structurally-valid but tampered token is rejected" do
    token = RegistrationToken.sign(@identity)
    assert {:error, _} = RegistrationToken.verify(token <> "x")
    assert {:error, _} = RegistrationToken.verify(String.slice(token, 0, 20))
  end

  test "non-binary tokens are :invalid" do
    assert RegistrationToken.verify(nil) == {:error, :invalid}
    assert RegistrationToken.verify(42) == {:error, :invalid}
    assert RegistrationToken.verify(%{not: "a token"}) == {:error, :invalid}
  end

  test "sign requires a map identity" do
    assert_raise FunctionClauseError, fn -> RegistrationToken.sign("bogus") end
  end
end
