defmodule NoizuPromptLingua.MCPServers do
  @moduledoc """
  Catalog of MCP servers exposed on subdomains. Single source of truth shared
  by the config endpoint (`/api/v1/auth/mcp/config`) and any client that needs
  to render `claude mcp add` setup commands.

  The `:root` server maps to the bare host (`<host>/mcp`); every other entry is
  served at `<id>.<host>/mcp`. Keep this list in sync with the `host:` scopes
  wired in `NoizuPromptLinguaWeb.Router`.
  """

  # %{id: label/required/desc}. `id` doubles as the subdomain label (except root).
  @servers [
    %{id: "root", label: "Root MCP", required: true, desc: "Core tools, NPL, discovery"},
    %{id: "sessions", label: "Sessions", required: true, desc: "Session management"},
    %{id: "organizations", label: "Organizations", required: true, desc: "Organization management"},
    %{id: "projects", label: "Projects", required: false, desc: "Project management"},
    %{id: "artifacts", label: "Artifacts", required: false, desc: "Versioned content storage"},
    %{id: "chat", label: "Chat", required: false, desc: "Chat rooms & messages"},
    %{id: "review", label: "Review", required: false, desc: "Artifact review & overlays"},
    %{id: "wiki", label: "Wiki", required: false, desc: "Wiki spaces, pages & comments"},
    %{id: "github", label: "GitHub", required: false, desc: "GitHub integration — repos, branches, PRs, issues"}
  ]

  @doc "All configured MCP servers."
  def all, do: @servers

  @doc """
  Returns the MCP servers with full connection URLs, derived from the configured
  `PHX_HOST`. Suitable for JSON serialization to clients building setup commands.
  """
  def for_host(nil), do: for_host(default_host())

  def for_host(host) when is_binary(host) do
    Enum.map(@servers, fn %{id: id} = s ->
      subdomain = if id == "root", do: host, else: "#{id}.#{host}"
      Map.put(s, :url, "https://#{subdomain}/mcp")
    end)
  end

  defp default_host do
    Application.get_env(:noizu_prompt_lingua, NoizuPromptLinguaWeb.Endpoint)
    |> case do
      %{url: %{host: host}} when is_binary(host) and host != "" -> host
      kw when is_list(kw) -> kw |> Keyword.get(:url, []) |> Keyword.get(:host, "localhost")
      _ -> System.get_env("PHX_HOST") || "localhost"
    end
  end
end
