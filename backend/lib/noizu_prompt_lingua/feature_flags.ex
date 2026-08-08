defmodule NoizuPromptLingua.FeatureFlags do
  def enabled?(flag) when is_atom(flag) do
    flags = Application.get_env(:noizu_prompt_lingua, :feature_flags, %{})
    Map.get(flags, flag, false)
  end

  def all do
    flags =
      Application.get_env(:noizu_prompt_lingua, :feature_flags, %{})
      |> Enum.filter(fn {_k, v} -> v end)
      |> Enum.map(fn {k, _v} -> Atom.to_string(k) end)

    # Always expose MCP OAuth migration flags so the SPA can hide legacy mint UI.
    flags ++
      [
        if(NoizuPromptLingua.MCP.LegacyKeys.mint_enabled?(),
          do: "mcp_api_key_mint",
          else: "mcp_api_key_mint_disabled"
        ),
        "mcp_oauth"
      ]
  end
end
