defmodule NoizuPromptLinguaWeb.WellKnownControllerTest do
  use NoizuPromptLinguaWeb.ConnCase, async: true

  alias NoizuPromptLingua.OAuth.Jwks

  setup do
    Jwks.reset!()
    :ok
  end

  test "GET /.well-known/jwks.json returns JWKS", %{conn: conn} do
    conn = get(conn, "/.well-known/jwks.json")
    assert json = json_response(conn, 200)
    assert %{"keys" => [key | _]} = json
    assert key["kty"] == "RSA"
    assert is_binary(key["n"])
  end

  test "root protected-resource metadata describes /mcp", %{conn: conn} do
    conn = get(conn, "/.well-known/oauth-protected-resource")
    assert %{"resource" => resource} = json_response(conn, 200)
    assert String.ends_with?(resource, "/mcp")
    refute String.contains?(resource, "/custom/")
  end

  test "path-scoped metadata describes the endpoint it is asked about", %{conn: conn} do
    conn = get(conn, "/.well-known/oauth-protected-resource/custom/abc123/mcp")
    assert %{"resource" => resource, "authorization_servers" => [_ | _]} =
             json_response(conn, 200)

    # This must match the audience the custom gateway binds tokens to, or a
    # client following discovery gets a token the gateway rejects as :bad_aud.
    assert String.ends_with?(resource, "/custom/abc123/mcp")
  end
end
