defmodule NoizuPromptLinguaWeb.MCPConfigTest do
  @moduledoc """
  MCPConfig — auth/plug option assembly for StreamableHTTP MCP mounts:
  verifier wiring, RFC 9728 resource metadata, tool-set route wrapper, and
  subdomain audience pinning (including the tobor.locker default host).
  """
  use ExUnit.Case, async: false

  alias NoizuPromptLingua.MCP.RouteClaimsVerifier
  alias NoizuPromptLinguaWeb.MCPConfig

  setup do
    original_oauth = Application.get_env(:noizu_prompt_lingua, :mcp_oauth)
    original_frontend = Application.get_env(:noizu_prompt_lingua, :frontend_url)
    original_issuer_env = System.get_env("MCP_ISSUER_URL")
    System.delete_env("MCP_ISSUER_URL")

    on_exit(fn ->
      if original_oauth,
        do: Application.put_env(:noizu_prompt_lingua, :mcp_oauth, original_oauth),
        else: Application.delete_env(:noizu_prompt_lingua, :mcp_oauth)

      if original_frontend,
        do: Application.put_env(:noizu_prompt_lingua, :frontend_url, original_frontend),
        else: Application.delete_env(:noizu_prompt_lingua, :frontend_url)

      if original_issuer_env,
        do: System.put_env("MCP_ISSUER_URL", original_issuer_env)
    end)

    :ok
  end

  defp with_oauth(overrides) do
    Application.put_env(:noizu_prompt_lingua, :mcp_oauth, overrides)
  end

  # ── auth_opts ─────────────────────────────────────────────────────────────

  test "auth_opts wires the dual-token verifier with house MFAs" do
    auth = MCPConfig.auth_opts()
    {verifier, opts} = assert auth[:verifier]

    assert verifier == NoizuPromptLingua.MCP.DualTokenVerifier
    assert opts[:secret] == {NoizuPromptLingua.MCPAuth, :secret}
    assert is_function(opts[:validate_api_key], 1)
    assert opts[:require_aud] == false
    assert opts[:public_scheme] == "https"
  end

  test "auth_opts merges extra verifier opts and honors a configured resource metadata" do
    with_oauth(resource_metadata_url: "https://x.test/.well-known/oauth-protected-resource")

    auth = MCPConfig.auth_opts(require_aud: true)

    {_v, opts} = auth[:verifier]
    assert opts[:require_aud] == true
    assert auth[:resource_metadata] == "https://x.test/.well-known/oauth-protected-resource"
  end

  test "auth_opts derives resource metadata from the configured issuer URL" do
    with_oauth(issuer_url: "https://issuer.test")

    auth = MCPConfig.auth_opts()

    assert auth[:resource_metadata] ==
             "https://issuer.test/.well-known/oauth-protected-resource"
  end

  # ── plug_opts ─────────────────────────────────────────────────────────────

  test "plug_opts shape and auth overrides" do
    opts = MCPConfig.plug_opts(:my_server, [require_aud: true], resource_metadata: "override")

    assert opts[:server] == :my_server
    assert opts[:origins] == :any
    assert opts[:auth][:resource_metadata] == "override"

    {_v, vopts} = opts[:auth][:verifier]
    assert vopts[:require_aud] == true
  end

  test "plug_opts_for_tool_set wraps the verifier with route claims" do
    auth =
      MCPConfig.plug_opts_for_tool_set(:srv, "https://gw.test/mcp", "/mcp/tools", %{
        "sets" => ["a", "b"]
      })[:auth]

    {verifier, vopts} = auth[:verifier]
    assert verifier == RouteClaimsVerifier
    assert vopts[:route_metadata] == %{"sets" => ["a", "b"]}

    assert auth[:resource_metadata] ==
             "https://gw.test/.well-known/oauth-protected-resource/mcp/tools"
  end

  test "plug_opts_for_tool_set falls back to an empty host when resource has none" do
    auth = MCPConfig.plug_opts_for_tool_set(:srv, "not-a-url", "/mcp", %{})[:auth]

    assert auth[:resource_metadata] ==
             "https:///.well-known/oauth-protected-resource/mcp"
  end

  # ── subdomains ────────────────────────────────────────────────────────────

  test "subdomain audience pinning with a configured base host" do
    with_oauth(public_base_host: "example.test")

    opts = MCPConfig.plug_opts_for_subdomain(:srv, "sessions")
    {_v, vopts} = opts[:auth][:verifier]

    assert vopts[:expected_audience] == "https://sessions.example.test/mcp"
  end

  test "subdomain without any host config falls back to tobor.locker" do
    Application.delete_env(:noizu_prompt_lingua, :mcp_oauth)
    Application.delete_env(:noizu_prompt_lingua, :frontend_url)

    assert MCPConfig.resource_url_for_subdomain("sessions") ==
             "https://sessions.tobor.locker/mcp"
  end

  test "public_scheme override flows into resource URLs" do
    with_oauth(public_base_host: "example.test", public_scheme: "http")

    assert MCPConfig.resource_url_for_subdomain("sessions") == "http://sessions.example.test/mcp"

    assert MCPConfig.resource_metadata_url_for_path("gw.test", "/mcp/tools") ==
             "http://gw.test/.well-known/oauth-protected-resource/mcp/tools"
  end

  test "non-binary subdomain labels yield nil" do
    assert MCPConfig.resource_url_for_subdomain(nil) == nil
    assert MCPConfig.resource_url_for_subdomain(42) == nil
  end
end
