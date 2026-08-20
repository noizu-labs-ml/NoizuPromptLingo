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

    test "unconfigured key is ephemeral and reported as such" do
      assert Jwks.ephemeral?()
      assert Jwks.signing_entry().source == :ephemeral
    end
  end

  describe "Jwks key material encodings" do
    setup do
      on_exit(fn ->
        Application.delete_env(:noizu_prompt_lingua, :mcp_oauth_test_backup)
        restore_oauth_cfg()
        Jwks.reset!()
      end)

      :ok
    end

    test "accepts a raw PEM" do
      pem = generate_pem()
      put_oauth_cfg(private_key_pem: pem)

      entry = Jwks.signing_entry()
      assert entry.source == :configured
      refute Jwks.ephemeral?()
    end

    test "accepts a base64-encoded PEM" do
      pem = generate_pem()
      put_oauth_cfg(private_key_pem: Base.encode64(pem))

      assert Jwks.signing_entry().source == :configured
    end

    test "accepts a PEM with literal \\n escapes" do
      pem = generate_pem()
      put_oauth_cfg(private_key_pem: String.replace(pem, "\n", "\\n"))

      assert Jwks.signing_entry().source == :configured
    end

    test "kid defaults to the key thumbprint, so a different key means a different kid" do
      put_oauth_cfg(private_key_pem: generate_pem(), kid: nil)
      first = Jwks.signing_entry().kid

      Jwks.reset!()
      put_oauth_cfg(private_key_pem: generate_pem(), kid: nil)
      second = Jwks.signing_entry().kid

      assert is_binary(first) and is_binary(second)
      refute first == second
    end

    test "explicit kid still wins" do
      put_oauth_cfg(private_key_pem: generate_pem(), kid: "pinned-1")
      assert Jwks.signing_entry().kid == "pinned-1"
    end

    test "a garbage key value does not silently degrade to ephemeral in prod" do
      put_oauth_cfg(private_key_pem: "not-a-key", allow_ephemeral_key: false)
      prev = Application.get_env(:noizu_prompt_lingua, :env)
      Application.put_env(:noizu_prompt_lingua, :env, :prod)

      assert_raise RuntimeError, ~r/not usable/, fn -> Jwks.signing_entry() end

      Application.put_env(:noizu_prompt_lingua, :env, prev)
    end
  end

  describe "Jwks rotation" do
    setup do
      on_exit(fn ->
        restore_oauth_cfg()
        Jwks.reset!()
      end)

      :ok
    end

    test "retired keys stay verifiable and are published in the JWKS" do
      retired_pem = generate_pem()
      Jwks.reset!()
      put_oauth_cfg(private_key_pem: retired_pem, kid: nil)
      retired_kid = Jwks.signing_entry().kid

      # rotate: new active key, old one retired
      Jwks.reset!()
      put_oauth_cfg(private_key_pem: generate_pem(), kid: nil, previous_key_pems: retired_pem)
      active_kid = Jwks.signing_entry().kid

      refute active_kid == retired_kid
      assert {:ok, _jwk, "RS256"} = Jwks.verify_jwk(retired_kid)

      kids = Jwks.document()["keys"] |> Enum.map(& &1["kid"])
      assert active_kid in kids
      assert retired_kid in kids
    end

    test "an unknown kid is reported as :unknown_kid, not a bad signature" do
      put_oauth_cfg(private_key_pem: generate_pem(), kid: nil)
      assert {:error, :unknown_kid} = Jwks.verify_jwk("kid-from-a-dead-key")
    end

    test "retired keys may pin the kid they were published under" do
      retired_pem = generate_pem()

      put_oauth_cfg(
        private_key_pem: generate_pem(),
        kid: nil,
        previous_key_pems: "mcp-1=" <> Base.encode64(retired_pem)
      )

      assert {:ok, _jwk, "RS256"} = Jwks.verify_jwk("mcp-1")
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
      # Keyword.merge, not ++: Keyword.get/2 reads the FIRST match, so appending
      # overrides would leave the defaults in force (that silently disabled the
      # revoked-api-key assertion below).
      Keyword.merge(
        [
          secret: fn -> "test-hmac-secret-for-dual-verifier-phase0!!!!!!!!" end,
          issuer: Token.issuer(),
          validate_api_key: fn _ -> true end,
          require_aud: false
        ],
        extra
      )
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

  # ── helpers ────────────────────────────────────────────────────────────────

  defp generate_pem do
    {_, pem} = JOSE.JWK.generate_key({:rsa, 2048}) |> JOSE.JWK.to_pem()
    pem
  end

  defp put_oauth_cfg(overrides) do
    base = Application.get_env(:noizu_prompt_lingua, :mcp_oauth, [])
    Application.put_env(:noizu_prompt_lingua, :mcp_oauth, Keyword.merge(base, overrides))
    Jwks.reset!()
  end

  defp restore_oauth_cfg do
    base = Application.get_env(:noizu_prompt_lingua, :mcp_oauth, [])

    cleaned =
      Keyword.drop(base, [:private_key_pem, :previous_key_pems, :kid, :allow_ephemeral_key])

    Application.put_env(:noizu_prompt_lingua, :mcp_oauth, cleaned)
  end

end
