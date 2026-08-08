defmodule NoizuPromptLingua.MCP.LegacyKeys do
  @moduledoc """
  Phase 4: gate legacy MCP API-key create/mint paths.

  When disabled, clients must use OAuth 2.1 (`/oauth/authorize` + DCR).
  Configure via `MCP_API_KEY_MINT_ENABLED=false` or
  `config :noizu_prompt_lingua, :mcp_legacy_api_keys, mint_enabled: false`.
  """

  def mint_enabled? do
    Application.get_env(:noizu_prompt_lingua, :mcp_legacy_api_keys, [])
    |> Keyword.get(:mint_enabled, true)
  end

  def create_enabled?, do: mint_enabled?()

  def disabled_response do
    issuer =
      try do
        NoizuPromptLingua.OAuth.AuthorizationServer.issuer_url()
      rescue
        _ -> "https://tobor.locker"
      end

    %{
      error: "api_key_mint_disabled",
      error_description:
        "Legacy MCP API key minting is disabled. Connect via OAuth 2.1 (DCR + PKCE).",
      oauth_authorization_server: "#{String.trim_trailing(issuer, "/")}/.well-known/oauth-authorization-server",
      mcp_url: "#{String.trim_trailing(issuer, "/")}/mcp",
      documentation: "backend/docs/mcp-oauth-connector-checklist.md"
    }
  end
end
