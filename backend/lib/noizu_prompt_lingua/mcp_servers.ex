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
    %{id: "tickets", label: "Tickets", required: false, desc: "Task & ticket tracking"},
    %{id: "assets", label: "Assets", required: false, desc: "Media asset lifecycle"},
    %{id: "artifacts", label: "Artifacts", required: false, desc: "Versioned content storage"},
    %{id: "chat", label: "Chat", required: false, desc: "Chat rooms & messages"},
    %{id: "review", label: "Review", required: false, desc: "Artifact review & overlays"},
    %{id: "wiki", label: "Wiki", required: false, desc: "Wiki spaces, pages & comments"},
    %{id: "github", label: "GitHub", required: false, desc: "GitHub integration — repos, branches, PRs, issues"},
    %{id: "personas", label: "Personas", required: false, desc: "Personas — bio, work log/journal & knowledge base"},
    %{id: "instructions", label: "Instructions", required: false, desc: "Reusable versioned prompts rendered with params for sub-agents"},
    %{id: "memory", label: "Memory", required: false, desc: "Knowledge memory and associations"},
    %{id: "markdown", label: "Markdown", required: false, desc: "URL/HTML→Markdown conversion & heading filter/collapse"},
    %{id: "notifications", label: "Notifications", required: false, desc: "Per-recipient notification inbox — Notify DMs, Monitor poll, watches, follow-ups"},
    %{id: "pubsub", label: "PubSub", required: false, desc: "Org-scoped pubsub channels — publish, follow, availability pointers"},
    %{id: "browser", label: "Browser", required: false, desc: "Drive a Playwright browser on the user's machine via a local controller"},
    %{id: "customers", label: "Customers", required: false, desc: "Customer/user personas (ICPs) & segments, linkable to tickets"},
    %{id: "market", label: "Market", required: false, desc: "Competitors, keyword research & market/competitor reports"},
    %{id: "campaigns", label: "Campaigns", required: false, desc: "Marketing/SEO/PPC campaigns, ad copy, landing pages & domain names"}
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
