defmodule NoizuPromptLingua.MCPAuth do
  @moduledoc """
  MCP auth helpers: legacy HS256 secret + API-key liveness check.

  Phase 0: new MCP tokens prefer asymmetric JWKS signing
  (`NoizuPromptLingua.OAuth.Jwks`). This module still supplies the shared
  HMAC secret so **legacy** HS256 tokens remain verifiable until Phase 4.
  Session JWTs continue to use Guardian's own secret configuration.
  """

  import Ecto.Query

  def api_key_active?(api_key_id) do
    NoizuPromptLingua.Repo.exists?(
      from(k in NoizuPromptLingua.Schema.McpApiKey,
        where: k.id == ^api_key_id and k.status == "active"
      )
    )
  end

  @doc "Legacy HS256 secret (Guardian / AUTH_SECRET). Used only for dual-verify of old tokens."
  def secret do
    fetch_secret() || "dev-secret-change-me"
  end

  defp fetch_secret do
    case Application.get_env(:noizu_prompt_lingua, NoizuPromptLingua.Guardian) do
      %{secret_key: key} when is_binary(key) and key != "" -> key
      kw when is_list(kw) -> Keyword.get(kw, :secret_key)
      _ -> System.get_env("GUARDIAN_SECRET_KEY") || System.get_env("AUTH_SECRET")
    end
  end
end
