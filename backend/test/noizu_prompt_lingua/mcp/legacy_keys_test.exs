defmodule NoizuPromptLingua.MCP.LegacyKeysTest do
  use ExUnit.Case, async: false

  alias NoizuPromptLingua.MCP.LegacyKeys

  test "disabled_response includes oauth discovery URL" do
    body = LegacyKeys.disabled_response()
    assert body.error == "api_key_mint_disabled"
    assert body.oauth_authorization_server =~ "oauth-authorization-server"
    assert body.mcp_url =~ "/mcp"
  end

  test "mint_enabled? respects config" do
    previous = Application.get_env(:noizu_prompt_lingua, :mcp_legacy_api_keys)

    Application.put_env(:noizu_prompt_lingua, :mcp_legacy_api_keys, mint_enabled: false)
    on_exit(fn ->
      if previous,
        do: Application.put_env(:noizu_prompt_lingua, :mcp_legacy_api_keys, previous),
        else: Application.delete_env(:noizu_prompt_lingua, :mcp_legacy_api_keys)
    end)

    refute LegacyKeys.mint_enabled?()
  end
end
