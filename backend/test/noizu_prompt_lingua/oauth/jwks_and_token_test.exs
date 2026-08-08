defmodule NoizuPromptLingua.OAuth.JwksAndTokenTest do
  use ExUnit.Case, async: false

  alias NoizuPromptLingua.OAuth.Jwks
  alias NoizuPromptLingua.Token
  alias NoizuPromptLingua.MCP.DualTokenVerifier

  setup do
    Jwks.reset!()
    :ok
  end

  describe "Jwks" do
    test "document includes a public RSA key with kid and alg" do
      doc = Jwks.document()
      assert %{"keys" => [key]} = doc
      assert key["kty"] == "RSA"
      assert is_binary(key["kid"])
      assert key["alg"] == "RS256"
      assert key["use"] == "sig"
      assert is_binary(key["n"])
      assert is_binary(key["e"])
      refute Map.has_key?(key, "d")
    end

    test "signing_entry is stable within process after cache" do
      a = Jwks.signing_entry()
      b = Jwks.signing_entry()
      assert a.kid == b.kid
      assert a.alg == b.alg
    end
  end

  describe "Token.mint" do
    test "mints RS256 JWT with kid and 7-day class TTL" do
      user = %{id: Ecto.UUID.generate(), email: "a@b.co", name: "Ada"}
      key = %{id: Ecto.UUID.generate()}

      {:ok, token, expires_at} = Token.mint(user, key)
      assert is_binary(token)
      assert DateTime.diff(expires_at, DateTime.utc_now()) > 6 * 24 * 3600
      assert DateTime.diff(expires_at, DateTime.utc_now()) <= 7 * 24 * 3600 + 5

      [header_b64 | _] = String.split(token, ".")
      {:ok, header_json} = Base.url_decode64(header_b64, padding: false)
      header = Jason.decode!(header_json)
      assert header["alg"] == "RS256"
      assert is_binary(header["kid"])

      entry = Jwks.signing_entry()
      {true, %JOSE.JWT{fields: claims}, _} =
        JOSE.JWT.verify_strict(JOSE.JWK.to_public(entry.jwk), ["RS256"], token)

      assert claims["sub"] == user.id
      assert claims["api_key_id"] == key.id
      assert claims["iss"] == Token.issuer()
      assert claims["token_version"] == 1
      refute Map.has_key?(claims, "aud")
    end

    test "includes aud when resource option is set" do
      user = %{id: Ecto.UUID.generate(), email: "a@b.co", name: "Ada"}
      key = %{id: Ecto.UUID.generate()}
      resource = "https://sessions.tobor.locker/mcp"

      {:ok, token, _} = Token.mint(user, key, resource: resource)

      entry = Jwks.signing_entry()
      {true, %JOSE.JWT{fields: claims}, _} =
        JOSE.JWT.verify_strict(JOSE.JWK.to_public(entry.jwk), ["RS256"], token)

      assert claims["aud"] == resource
    end

    test "legacy HS256 mint still works when forced" do
      user = %{id: Ecto.UUID.generate(), email: "a@b.co", name: "Ada"}
      key = %{id: Ecto.UUID.generate()}

      {:ok, token, _} = Token.mint(user, key, alg: :hs256)

      [header_b64 | _] = String.split(token, ".")
      {:ok, header_json} = Base.url_decode64(header_b64, padding: false)
      header = Jason.decode!(header_json)
      assert header["alg"] == "HS256"
    end
  end

  describe "DualTokenVerifier" do
    defp verifier_opts(extra \\ []) do
      [
        secret: fn -> "test-hmac-secret-for-dual-verifier-phase0!!!!!!!!" end,
        issuer: Token.issuer(),
        validate_api_key: fn _ -> true end,
        require_aud: false
      ] ++ extra
    end

    test "accepts RS256 token" do
      # Temporarily point HMAC secret used only for HS256 path; RS256 uses JWKS.
      user = %{id: Ecto.UUID.generate(), email: "a@b.co", name: "Ada"}
      key = %{id: Ecto.UUID.generate()}
      {:ok, token, _} = Token.mint(user, key)

      assert {:ok, claims} =
               DualTokenVerifier.verify(token, %{method: "POST", peer: nil, headers: []}, verifier_opts())

      assert claims["api_key_id"] == key.id
    end

    test "accepts legacy HS256 token" do
      previous = Application.get_env(:noizu_prompt_lingua, NoizuPromptLingua.Guardian)

      Application.put_env(:noizu_prompt_lingua, NoizuPromptLingua.Guardian,
        secret_key: "test-hmac-secret-for-dual-verifier-phase0!!!!!!!!"
      )

      on_exit(fn ->
        if previous,
          do: Application.put_env(:noizu_prompt_lingua, NoizuPromptLingua.Guardian, previous)
      end)

      user = %{id: Ecto.UUID.generate(), email: "a@b.co", name: "Ada"}
      key = %{id: Ecto.UUID.generate()}
      {:ok, token, _} = Token.mint(user, key, alg: :hs256)

      assert {:ok, claims} =
               DualTokenVerifier.verify(
                 token,
                 %{method: "POST", peer: nil, headers: []},
                 verifier_opts(secret: "test-hmac-secret-for-dual-verifier-phase0!!!!!!!!")
               )

      assert claims["api_key_id"] == key.id
    end

    test "rejects wrong audience when require_aud and aud present" do
      user = %{id: Ecto.UUID.generate(), email: "a@b.co", name: "Ada"}
      key = %{id: Ecto.UUID.generate()}
      {:ok, token, _} = Token.mint(user, key, resource: "https://sessions.tobor.locker/mcp")

      assert {:error, :invalid_token} =
               DualTokenVerifier.verify(
                 token,
                 %{
                   method: "POST",
                   peer: nil,
                   headers: [{"host", "organizations.tobor.locker"}]
                 },
                 verifier_opts(require_aud: true)
               )
    end

    test "accepts matching audience from host header" do
      user = %{id: Ecto.UUID.generate(), email: "a@b.co", name: "Ada"}
      key = %{id: Ecto.UUID.generate()}
      {:ok, token, _} = Token.mint(user, key, resource: "https://sessions.tobor.locker/mcp")

      assert {:ok, _} =
               DualTokenVerifier.verify(
                 token,
                 %{
                   method: "POST",
                   peer: nil,
                   headers: [{"host", "sessions.tobor.locker"}]
                 },
                 verifier_opts(require_aud: true, public_scheme: "https")
               )
    end

    test "rejects revoked api key" do
      user = %{id: Ecto.UUID.generate(), email: "a@b.co", name: "Ada"}
      key = %{id: Ecto.UUID.generate()}
      {:ok, token, _} = Token.mint(user, key)

      assert {:error, :invalid_token} =
               DualTokenVerifier.verify(
                 token,
                 %{method: "POST", peer: nil, headers: []},
                 verifier_opts(validate_api_key: fn _ -> false end)
               )
    end
  end
end
