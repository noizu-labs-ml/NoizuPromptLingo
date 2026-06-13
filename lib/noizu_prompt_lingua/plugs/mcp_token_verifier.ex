defmodule NoizuPromptLingua.MCPAuth do
  def api_key_active?(api_key_id) do
    import Ecto.Query

    NoizuPromptLingua.Repo.exists?(
      from(k in NoizuPromptLingua.Schema.McpApiKey,
        where: k.id == ^api_key_id and k.status == "active"
      )
    )
  end

  def secret do
    System.get_env("AUTH_SECRET") || "dev-secret-change-me"
  end
end
