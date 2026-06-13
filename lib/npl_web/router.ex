defmodule NPLWeb.Router do
  use NPLWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  # ── Routed subdomains ─────────────────────────────────────────
  scope "/", host: "sessions." do
    forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug,
      NPLWeb.MCPConfig.plug_opts(NoizuPromptLingua.Domains.Sessions.MCP)
  end

  scope "/", host: "tickets." do
    forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug,
      NPLWeb.MCPConfig.plug_opts(NoizuPromptLingua.Domains.Tickets.MCP)
  end

  scope "/", host: "review." do
    forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug,
      NPLWeb.MCPConfig.plug_opts(NoizuPromptLingua.Domains.Review.MCP)
  end

  scope "/", host: "chat." do
    forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug,
      NPLWeb.MCPConfig.plug_opts(NoizuPromptLingua.Domains.Chat.MCP)
  end

  scope "/", host: "assets." do
    forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug,
      NPLWeb.MCPConfig.plug_opts(NoizuPromptLingua.Domains.Assets.MCP)
  end

  scope "/", host: "artifacts." do
    forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug,
      NPLWeb.MCPConfig.plug_opts(NoizuPromptLingua.Domains.Artifacts.MCP)
  end

  scope "/", host: "projects." do
    forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug,
      NPLWeb.MCPConfig.plug_opts(NoizuPromptLingua.Domains.Projects.MCP)
  end

  scope "/", host: "wiki." do
    forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug,
      NPLWeb.MCPConfig.plug_opts(NoizuPromptLingua.Domains.Wiki.MCP)
  end

  # ── Root (default — no subdomain match) ───────────────────────
  scope "/" do
    pipe_through :api

    get "/health", NPLWeb.HealthController, :show
    post "/api/auth/sync", NPLWeb.AuthController, :sync
    post "/api/keys", NPLWeb.KeyController, :create
    get "/api/keys/:user_id", NPLWeb.KeyController, :index
    delete "/api/keys/:key_id", NPLWeb.KeyController, :delete
    post "/api/mcp/token", NPLWeb.TokenController, :create
  end

  forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug,
    NPLWeb.MCPConfig.plug_opts(NoizuPromptLingua.MCP)
end
