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
    pipe_through :api

    get "/assets/:project_slug/:asset_slug", NPLWeb.AssetRenderController, :show

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

  # ── Mock MCP subdomain ───────────────────────────────────────
  scope "/", host: "mockmcp." do
    pipe_through :api

    # CRUD API for mock MCP definitions
    get "/api/definitions", NPLWeb.API.MockMCPAPIController, :index
    get "/api/definitions/:slug", NPLWeb.API.MockMCPAPIController, :show
    post "/api/definitions", NPLWeb.API.MockMCPAPIController, :create
    put "/api/definitions/:slug", NPLWeb.API.MockMCPAPIController, :update
    delete "/api/definitions/:slug", NPLWeb.API.MockMCPAPIController, :delete
    post "/api/definitions/:slug/activate", NPLWeb.API.MockMCPAPIController, :activate
    post "/api/definitions/:slug/generate-tools", NPLWeb.API.MockMCPAPIController, :generate_tools
    post "/api/definitions/:slug/provision-db", NPLWeb.API.MockMCPAPIController, :provision_db
    get "/api/definitions/:slug/calls", NPLWeb.API.MockMCPAPIController, :calls

    # Dynamic MCP gateway — each mock gets its own endpoint
    match :*, "/mcp/:slug/mcp", NPLWeb.MockMCPGatewayController, :handle
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

    # Dashboard API
    get "/api/dashboard/stats", NPLWeb.DashboardController, :stats
    get "/api/dashboard/activity", NPLWeb.DashboardController, :activity

    # Domain APIs
    get "/api/projects", NPLWeb.API.ProjectsAPIController, :index
    get "/api/projects/:id", NPLWeb.API.ProjectsAPIController, :show

    get "/api/assets", NPLWeb.API.AssetsAPIController, :index
    get "/api/assets/:id", NPLWeb.API.AssetsAPIController, :show
    get "/api/assets/:id/history", NPLWeb.API.AssetsAPIController, :history

    get "/api/tickets", NPLWeb.API.TicketsAPIController, :index
    get "/api/tickets/:id", NPLWeb.API.TicketsAPIController, :show

    get "/api/chat/rooms", NPLWeb.API.ChatAPIController, :rooms
    get "/api/chat/rooms/:room_id/messages", NPLWeb.API.ChatAPIController, :messages

    get "/api/reviews", NPLWeb.API.ReviewsAPIController, :index
    get "/api/reviews/:id", NPLWeb.API.ReviewsAPIController, :show

    # Mock MCP CRUD (also available at mockmcp.tobor.locker)
    get "/api/mock-mcp", NPLWeb.API.MockMCPAPIController, :index
    get "/api/mock-mcp/:slug", NPLWeb.API.MockMCPAPIController, :show
    post "/api/mock-mcp", NPLWeb.API.MockMCPAPIController, :create
    put "/api/mock-mcp/:slug", NPLWeb.API.MockMCPAPIController, :update
    delete "/api/mock-mcp/:slug", NPLWeb.API.MockMCPAPIController, :delete
    post "/api/mock-mcp/:slug/activate", NPLWeb.API.MockMCPAPIController, :activate
    post "/api/mock-mcp/:slug/generate-tools", NPLWeb.API.MockMCPAPIController, :generate_tools
    post "/api/mock-mcp/:slug/provision-db", NPLWeb.API.MockMCPAPIController, :provision_db
    get "/api/mock-mcp/:slug/calls", NPLWeb.API.MockMCPAPIController, :calls
  end

  forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug,
    NPLWeb.MCPConfig.plug_opts(NoizuPromptLingua.MCP)
end
