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
    assert %{"keys" => [key]} = json
    assert key["kty"] == "RSA"
    assert is_binary(key["n"])
  end
end
