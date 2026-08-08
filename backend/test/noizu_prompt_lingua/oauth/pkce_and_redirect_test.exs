defmodule NoizuPromptLingua.OAuth.PkceAndRedirectTest do
  use ExUnit.Case, async: true

  alias NoizuPromptLingua.OAuth.{Pkce, RedirectPolicy, AuthorizationServer}

  describe "Pkce" do
    test "S256 round-trip" do
      verifier = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)

      challenge =
        :crypto.hash(:sha256, verifier) |> Base.url_encode64(padding: false)

      assert :ok = Pkce.verify_s256(verifier, challenge)
      assert {:error, :invalid_grant} = Pkce.verify_s256(verifier <> "x", challenge)
      assert Pkce.valid_challenge?("S256", challenge)
      refute Pkce.valid_challenge?("plain", challenge)
    end
  end

  describe "RedirectPolicy" do
    test "allows Claude, ChatGPT, and loopback" do
      assert RedirectPolicy.allowed_for_registration?(
               "https://claude.ai/api/mcp/auth_callback"
             )

      assert RedirectPolicy.allowed_for_registration?("https://chatgpt.com/connector/oauth")
      assert RedirectPolicy.allowed_for_registration?("http://127.0.0.1:8910/callback")
      assert RedirectPolicy.allowed_for_registration?("http://localhost:3000/cb")
      refute RedirectPolicy.allowed_for_registration?("https://evil.example/cb")
    end

    test "registered? requires exact match" do
      uris = ["https://claude.ai/api/mcp/auth_callback"]
      assert RedirectPolicy.registered?(uris, "https://claude.ai/api/mcp/auth_callback")
      refute RedirectPolicy.registered?(uris, "https://claude.ai/other")
    end
  end

  describe "AuthorizationServer" do
    test "metadata has required OAuth fields" do
      m = AuthorizationServer.metadata()
      assert m["authorization_endpoint"] =~ "/oauth/authorize"
      assert m["token_endpoint"] =~ "/oauth/token"
      assert m["registration_endpoint"] =~ "/oauth/register"
      assert m["jwks_uri"] =~ "/jwks.json"
      assert "S256" in m["code_challenge_methods_supported"]
      assert "code" in m["response_types_supported"]
    end
  end
end
