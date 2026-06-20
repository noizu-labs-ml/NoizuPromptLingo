defmodule NoizuPromptLingua.MCPAuth do
  @moduledoc """
  MCP token signing secret + API-key liveness check.

  The signing secret reuses the Guardian secret (`GUARDIAN_SECRET_KEY`) so MCP
  JWTs and session JWTs share a single configured secret. `api_key_active?/1`
  backs the MCP gateway's claim validation — a token's `api_key_id` must point
  at an active key row.
  """

  import Ecto.Query

  def api_key_active?(api_key_id) do
    NoizuPromptLingua.Repo.exists?(
      from(k in NoizuPromptLingua.Schema.McpApiKey,
        where: k.id == ^api_key_id and k.status == "active"
      )
    )
  end

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
