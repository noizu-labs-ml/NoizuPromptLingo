defmodule NoizuPromptLingua.OAuth.AuthorizationServerTest do
  @moduledoc """
  `OAuth.AuthorizationServer` — issuer URL resolution order (config →
  `MCP_ISSUER_URL` → `frontend_url` → default), the issuer list, and the
  RFC 8414 metadata document.
  """

  use ExUnit.Case, async: false

  alias NoizuPromptLingua.OAuth.AuthorizationServer

  setup do
    prev_cfg = Application.get_env(:noizu_prompt_lingua, :mcp_oauth)
    prev_fe = Application.get_env(:noizu_prompt_lingua, :frontend_url)
    prev_env = System.get_env("MCP_ISSUER_URL")

    on_exit(fn ->
      if prev_cfg,
        do: Application.put_env(:noizu_prompt_lingua, :mcp_oauth, prev_cfg),
        else: Application.delete_env(:noizu_prompt_lingua, :mcp_oauth)

      if prev_fe,
        do: Application.put_env(:noizu_prompt_lingua, :frontend_url, prev_fe),
        else: Application.delete_env(:noizu_prompt_lingua, :frontend_url)

      if prev_env,
        do: System.put_env("MCP_ISSUER_URL", prev_env),
        else: System.delete_env("MCP_ISSUER_URL")
    end)

    Application.delete_env(:noizu_prompt_lingua, :mcp_oauth)
    Application.delete_env(:noizu_prompt_lingua, :frontend_url)
    System.delete_env("MCP_ISSUER_URL")
    :ok
  end

  test "issuer_url resolution: config → env → frontend_url → default" do
    Application.put_env(:noizu_prompt_lingua, :mcp_oauth, issuer_url: "https://cfg.example")
    assert AuthorizationServer.issuer_url() == "https://cfg.example"

    Application.delete_env(:noizu_prompt_lingua, :mcp_oauth)
    System.put_env("MCP_ISSUER_URL", "https://env.example")
    assert AuthorizationServer.issuer_url() == "https://env.example"

    System.delete_env("MCP_ISSUER_URL")
    Application.put_env(:noizu_prompt_lingua, :frontend_url, "https://fe.example/")
    assert AuthorizationServer.issuer_url() == "https://fe.example"

    Application.delete_env(:noizu_prompt_lingua, :frontend_url)
    assert AuthorizationServer.issuer_url() == "https://tobor.locker"
  end

  test "jwt_issuers pairs the short issuer with the issuer URL, deduplicated" do
    Application.put_env(:noizu_prompt_lingua, :mcp_oauth, issuer: "short")
    assert AuthorizationServer.jwt_issuers() == ["short", "https://tobor.locker"]

    Application.put_env(:noizu_prompt_lingua, :mcp_oauth, issuer: "same", issuer_url: "same")
    assert AuthorizationServer.jwt_issuers() == ["same"]
  end

  test "metadata derives endpoints from the (trailing-slash-trimmed) issuer" do
    Application.put_env(:noizu_prompt_lingua, :mcp_oauth, issuer_url: "https://auth.example/")

    md = AuthorizationServer.metadata()
    assert md["issuer"] == "https://auth.example"
    assert md["authorization_endpoint"] == "https://auth.example/oauth/authorize"
    assert md["token_endpoint"] == "https://auth.example/oauth/token"
    assert md["jwks_uri"] == "https://auth.example/.well-known/jwks.json"
    assert "urn:ietf:params:oauth:grant-type:token-exchange" in md["grant_types_supported"]
    assert "S256" in md["code_challenge_methods_supported"]
  end
end
