defmodule NoizuPromptLinguaWeb.Router do
  use NoizuPromptLinguaWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    # ApiKeyAuth runs first: if a valid fixed API key is present it sets the
    # service-user session and :auth_method, and AuthPipeline skips Guardian.
    plug NoizuPromptLinguaWeb.Plugs.ApiKeyAuth
    plug NoizuPromptLinguaWeb.AuthPipeline
  end

  # W7 component plane: per-consumer MCP API key auth over plain HTTP.
  # :mcp_key_required — keyed-only endpoints (component registry).
  # :mcp_key_optional — pass-through; upgrades a request when a key is
  #   present, otherwise the normal Guardian pipeline authenticates.
  pipeline :mcp_key_required do
    plug NoizuPromptLinguaWeb.Plugs.McpKeyAuth, require: true
  end

  pipeline :mcp_key_optional do
    plug NoizuPromptLinguaWeb.Plugs.McpKeyAuth, require: false
  end

  pipeline :sso_session do
    plug Plug.Session,
      store: :cookie,
      key: "_starter_sso",
      signing_salt: "sso_session_salt",
      same_site: "Lax",
      # HTTPS site (tobor.locker). Without Secure, some browsers / Cloudflare
      # drop the cookie on the Authentik return and the callback is state_mismatch.
      secure: true,
      # 15 minutes, raised from 5. This cookie now carries the OIDC flow's
      # `state` and `nonce`, so it must outlive the user's round trip through
      # the identity provider - five minutes does not cover a password plus a
      # 2FA prompt, and expiring mid-flow would surface as `state_mismatch` on a
      # login that previously succeeded. It holds flow state, never credentials.
      max_age: 900

    plug :fetch_session
  end

  pipeline :rate_limited_auth do
    plug NoizuPromptLinguaWeb.Plugs.RateLimit, action: :auth
  end

  pipeline :rate_limited_sensitive do
    plug NoizuPromptLinguaWeb.Plugs.RateLimit, action: :auth_sensitive
  end

  pipeline :rate_limited_marketing do
    plug NoizuPromptLinguaWeb.Plugs.RateLimit, action: :marketing_signup
  end

  pipeline :org_viewer do
    plug NoizuPromptLinguaWeb.Plugs.RequireRole, role: "viewer"
  end

  pipeline :org_editor do
    plug NoizuPromptLinguaWeb.Plugs.RequireRole, role: "editor"
  end

  pipeline :org_admin do
    plug NoizuPromptLinguaWeb.Plugs.RequireRole, role: "admin"
  end

  pipeline :org_owner do
    plug NoizuPromptLinguaWeb.Plugs.RequireRole, role: "owner"
  end

  pipeline :admin do
    plug NoizuPromptLinguaWeb.Plugs.RequireAdmin
  end

  scope "/", NoizuPromptLinguaWeb do
    pipe_through :api
    get "/health", HealthController, :index
    # `curl -fsSL https://<host>/browser-sessions | bash` — self-installing
    # launcher for the local browser controller (host baked into the script).
    get "/browser-sessions", BrowserSessionController, :install
  end

  # MCP OAuth discovery (JWKS, AS metadata, protected-resource metadata).
  scope "/.well-known", NoizuPromptLinguaWeb do
    pipe_through :api
    get "/jwks.json", WellKnownController, :jwks
    get "/oauth-authorization-server", WellKnownController, :oauth_authorization_server
    get "/oauth-protected-resource", WellKnownController, :oauth_protected_resource
    # Path-scoped variant (RFC 9728) for MCP endpoints not mounted at /mcp,
    # e.g. /.well-known/oauth-protected-resource/custom/<slug>/mcp.
    get "/oauth-protected-resource/*resource_path",
        WellKnownController,
        :oauth_protected_resource
  end

  # OAuth 2.1 Authorization Server (MCP connectors: Claude.ai, ChatGPT, CLI).
  scope "/oauth", NoizuPromptLinguaWeb do
    pipe_through [:sso_session, :rate_limited_auth]
    get "/authorize", OAuthController, :authorize
    post "/consent", OAuthController, :consent
    get "/elevate", OAuthController, :elevate_show
    post "/elevate", OAuthController, :elevate_submit
  end

  scope "/oauth", NoizuPromptLinguaWeb do
    pipe_through [:api, :rate_limited_auth]
    post "/token", OAuthController, :token
    post "/register", OAuthController, :register
    post "/revoke", OAuthController, :revoke
  end

  # Mint a short-lived MCP JWT from an active MCP API key. This is the bootstrap
  # endpoint clients call to obtain the Bearer token the MCP servers require.
  scope "/api/mcp", NoizuPromptLinguaWeb do
    pipe_through [:api, :rate_limited_auth]
    post "/token", TokenController, :create
    # Browser controller boot exchange: raw API key → {token, org_id, url}.
    post "/browser-bootstrap", BrowserSessionController, :bootstrap
  end

  # W7: keyed Lit component registry (read-only). Per-key toolset_config
  # governs visibility — see NoizuPromptLinguaWeb.ComponentController.
  scope "/api/v1/components", NoizuPromptLinguaWeb do
    pipe_through [:api, :mcp_key_required]
    get "/", ComponentController, :index
    get "/:name/bundle", ComponentController, :bundle
  end

  # MCP servers (Streamable HTTP), routed by subdomain — each domain is served
  # at `<domain>.<host>/mcp` (e.g. sessions.tobor.locker/mcp). The `host:`
  # prefix match (trailing dot) matches any host beginning with that label.
  # The root aggregator (all domains + Discovery) is served at the bare host
  # under `/mcp`. Requests must present a Bearer MCP JWT (see MCPConfig).
  scope "/", host: "organizations." do
    forward "/mcp",
            Noizu.MCP.Transport.StreamableHTTP.Plug,
            NoizuPromptLinguaWeb.MCPConfig.plug_opts_for_subdomain(
              NoizuPromptLingua.MCP.Organizations,
              "organizations"
            )
  end

  scope "/", host: "projects." do
    forward "/mcp",
            Noizu.MCP.Transport.StreamableHTTP.Plug,
            NoizuPromptLinguaWeb.MCPConfig.plug_opts_for_subdomain(
              NoizuPromptLingua.MCP.Projects,
              "projects"
            )
  end

  scope "/", host: "clients." do
    forward "/mcp",
            Noizu.MCP.Transport.StreamableHTTP.Plug,
            NoizuPromptLinguaWeb.MCPConfig.plug_opts_for_subdomain(
              NoizuPromptLingua.MCP.Clients,
              "clients"
            )
  end

  scope "/", host: "sessions." do
    forward "/mcp",
            Noizu.MCP.Transport.StreamableHTTP.Plug,
            NoizuPromptLinguaWeb.MCPConfig.plug_opts_for_subdomain(
              NoizuPromptLingua.MCP.Sessions,
              "sessions"
            )
  end

  scope "/", host: "artifacts." do
    forward "/mcp",
            Noizu.MCP.Transport.StreamableHTTP.Plug,
            NoizuPromptLinguaWeb.MCPConfig.plug_opts_for_subdomain(
              NoizuPromptLingua.Domains.Artifacts.MCP,
              "artifacts"
            )
  end

  scope "/", host: "chat." do
    forward "/mcp",
            Noizu.MCP.Transport.StreamableHTTP.Plug,
            NoizuPromptLinguaWeb.MCPConfig.plug_opts_for_subdomain(
              NoizuPromptLingua.Domains.Chat.MCP,
              "chat"
            )
  end

  scope "/", host: "review." do
    forward "/mcp",
            Noizu.MCP.Transport.StreamableHTTP.Plug,
            NoizuPromptLinguaWeb.MCPConfig.plug_opts_for_subdomain(
              NoizuPromptLingua.Domains.Review.MCP,
              "review"
            )
  end

  scope "/", host: "tickets." do
    forward "/mcp",
            Noizu.MCP.Transport.StreamableHTTP.Plug,
            NoizuPromptLinguaWeb.MCPConfig.plug_opts_for_subdomain(
              NoizuPromptLingua.Domains.Tickets.MCP,
              "tickets"
            )
  end

  scope "/", host: "assets." do
    forward "/mcp",
            Noizu.MCP.Transport.StreamableHTTP.Plug,
            NoizuPromptLinguaWeb.MCPConfig.plug_opts_for_subdomain(
              NoizuPromptLingua.Domains.Assets.MCP,
              "assets"
            )
  end

  scope "/", host: "wiki." do
    forward "/mcp",
            Noizu.MCP.Transport.StreamableHTTP.Plug,
            NoizuPromptLinguaWeb.MCPConfig.plug_opts_for_subdomain(
              NoizuPromptLingua.Domains.Wiki.MCP,
              "wiki"
            )
  end

  scope "/", host: "github." do
    forward "/mcp",
            Noizu.MCP.Transport.StreamableHTTP.Plug,
            NoizuPromptLinguaWeb.MCPConfig.plug_opts_for_subdomain(
              NoizuPromptLingua.Domains.Github.MCP,
              "github"
            )
  end

  scope "/", host: "personas." do
    forward "/mcp",
            Noizu.MCP.Transport.StreamableHTTP.Plug,
            NoizuPromptLinguaWeb.MCPConfig.plug_opts_for_subdomain(
              NoizuPromptLingua.Domains.Personas.MCP,
              "personas"
            )
  end

  scope "/", host: "instructions." do
    forward "/mcp",
            Noizu.MCP.Transport.StreamableHTTP.Plug,
            NoizuPromptLinguaWeb.MCPConfig.plug_opts_for_subdomain(
              NoizuPromptLingua.Domains.Instructions.MCP,
              "instructions"
            )
  end

  scope "/", host: "memory." do
    forward "/mcp",
            Noizu.MCP.Transport.StreamableHTTP.Plug,
            NoizuPromptLinguaWeb.MCPConfig.plug_opts_for_subdomain(
              NoizuPromptLingua.Domains.Memory.MCP,
              "memory"
            )
  end

  scope "/", host: "markdown." do
    forward "/mcp",
            Noizu.MCP.Transport.StreamableHTTP.Plug,
            NoizuPromptLinguaWeb.MCPConfig.plug_opts_for_subdomain(
              NoizuPromptLingua.Domains.Markdown.MCP,
              "markdown"
            )
  end

  scope "/", host: "notifications." do
    forward "/mcp",
            Noizu.MCP.Transport.StreamableHTTP.Plug,
            NoizuPromptLinguaWeb.MCPConfig.plug_opts_for_subdomain(
              NoizuPromptLingua.Domains.Notifications.MCP,
              "notifications"
            )
  end

  scope "/", host: "pubsub." do
    forward "/mcp",
            Noizu.MCP.Transport.StreamableHTTP.Plug,
            NoizuPromptLinguaWeb.MCPConfig.plug_opts_for_subdomain(
              NoizuPromptLingua.Domains.PubSub.MCP,
              "pubsub"
            )
  end

  scope "/", host: "browser." do
    forward "/mcp",
            Noizu.MCP.Transport.StreamableHTTP.Plug,
            NoizuPromptLinguaWeb.MCPConfig.plug_opts_for_subdomain(
              NoizuPromptLingua.Domains.Browser.MCP,
              "browser"
            )
  end

  scope "/", host: "customers." do
    forward "/mcp",
            Noizu.MCP.Transport.StreamableHTTP.Plug,
            NoizuPromptLinguaWeb.MCPConfig.plug_opts_for_subdomain(
              NoizuPromptLingua.Domains.Customers.MCP,
              "customers"
            )
  end

  scope "/", host: "market." do
    forward "/mcp",
            Noizu.MCP.Transport.StreamableHTTP.Plug,
            NoizuPromptLinguaWeb.MCPConfig.plug_opts_for_subdomain(
              NoizuPromptLingua.Domains.Market.MCP,
              "market"
            )
  end

  scope "/", host: "campaigns." do
    forward "/mcp",
            Noizu.MCP.Transport.StreamableHTTP.Plug,
            NoizuPromptLinguaWeb.MCPConfig.plug_opts_for_subdomain(
              NoizuPromptLingua.Domains.Campaigns.MCP,
              "campaigns"
            )
  end

  scope "/", host: "unicode." do
    forward "/mcp",
            Noizu.MCP.Transport.StreamableHTTP.Plug,
            NoizuPromptLinguaWeb.MCPConfig.plug_opts_for_subdomain(
              NoizuPromptLingua.Domains.UnicodeCodex.MCP,
              "unicode"
            )
  end

  # Dynamic mock-MCP gateway. Each mock MCP (defined + activated via the
  # org-scoped management API) is served live at mockmcp.<host>/mcp/<slug>/mcp.
  # This is a per-slug JSON-RPC proxy to an LLM — distinct from the static
  # Noizu.MCP.Server domains above, so it is NOT listed in MCPServers.
  #
  # MUST be declared before the host-less root `/mcp` aggregator below: that
  # scope uses `forward "/"`, which matches every path under `/mcp` on ANY host
  # (no host constraint). Declared first, it would shadow this gateway and 404
  # every `mockmcp.<host>/mcp/<slug>/mcp` request.
  scope "/", NoizuPromptLinguaWeb, host: "mockmcp." do
    match :*, "/mcp/:slug/mcp", MockMCPGatewayController, :handle
  end

  # Dynamic include-scope MCP gateway. Each admin-managed preset combines
  # selected existing domain MCP tools into one endpoint at
  # <host>/custom/<slug>/mcp.
  scope "/", NoizuPromptLinguaWeb do
    match :*, "/custom/:slug/mcp", CustomMCPGatewayController, :handle
  end

  # Org-addressed custom MCP gateway — the canonical URL shape:
  # <host>/org/<org_slug>/custom/<slug>/mcp. The org segment scopes the slug
  # lookup (the scope must belong to that org). The legacy <host>/custom/<slug>/mcp
  # path above remains a permanent alias: it 301s browser GETs of org-bound
  # scopes to this canonical form and serves everything else in place.
  scope "/", NoizuPromptLinguaWeb do
    match :*, "/org/:org_slug/custom/:slug/mcp", CustomMCPGatewayController, :handle_org
  end

  # Account-level custom-scope gateway (W2 sharing). Scopes with visibility
  # "account"/"shared" are additionally served at <host>/user/<slug>/mcp; the
  # controller's resolve_scope/3 is the shared resolution point the org route
  # (/org/:org_slug/custom/:slug/mcp, W1) lands on too.
  scope "/", NoizuPromptLinguaWeb do
    match :*, "/user/:slug/mcp", CustomMCPGatewayController, :handle_user
  end

  # Tool-set gateway (PRD-N3): org/project/group-shaped mcp_tool_sets served
  # through the lib protocol path (ToolSetEndpoint). Additive — placed AFTER
  # the org-custom + user routes and BEFORE the bare /mcp catch-all (FR-3-1);
  # both handlers 404 unless :noizu_prompt_lingua, :tool_sets_enabled.
  scope "/", NoizuPromptLinguaWeb do
    match :*, "/org/:org_slug/set/:set_slug/mcp", MCPSetGatewayController, :handle_org
  end

  scope "/", NoizuPromptLinguaWeb do
    match :*,
          "/org/:org_slug/project/:project_slug/set/:set_slug/mcp",
          MCPSetGatewayController,
          :handle_org_project
  end

  # Root MCP mount: the lib transport behind the NPL-owned JsonRpcGuard
  # (B4 — malformed jsonrpc versions answer -32600 instead of hanging).
  scope "/mcp" do
    forward "/",
            NoizuPromptLinguaWeb.MCP.TransportPlug,
            NoizuPromptLinguaWeb.MCPConfig.plug_opts(NoizuPromptLingua.MCP)
  end

  # Authentik (OIDC) is the ONLY supported auth method — no alternatives.
  # Email/password, magic-link, OTP, password-reset, email-verification, and
  # social-provider routes are intentionally disabled (the Authentik IdP owns
  # registration, password, and email verification). The Authentik login flow
  # lives under /auth/oidc; the SPA exchanges its session via /auth/sso/exchange.
  scope "/api/v1", NoizuPromptLinguaWeb do
    pipe_through [:api, :rate_limited_auth]
    post "/auth/refresh", AuthController, :refresh
    get "/auth/sso/providers", SSOController, :providers
    post "/auth/sso/exchange", SSOController, :exchange
    get "/auth/sso/registration", SSOController, :registration
    post "/auth/sso/register", SSOController, :register
    get "/config/features", ConfigController, :features
    # Download the standalone local-filesystem MCP server (dev tooling) as a tarball.
    get "/config/local-mcp/download", ConfigController, :local_mcp_download
    # Download the local browser controller (Node + Playwright) as a tarball.
    get "/config/browser-controller/download", ConfigController, :browser_controller_download
    # Download the remote-access tunnel client (frpc wrapper) as a tarball.
    get "/config/remote-access-client/download", ConfigController, :remote_access_client_download
  end

  # Remote-access reverse tunnels. CRUD is authenticated with an MCP JWT verified
  # inside the controller (not the Guardian session pipeline); `frp-auth` is the
  # frps server-plugin callback, secured by the per-claim tunnel token.
  scope "/api/v1/remote-access", NoizuPromptLinguaWeb do
    pipe_through [:api, :rate_limited_auth]
    post "/tunnels", RemoteAccessController, :create
    get "/tunnels", RemoteAccessController, :index
    delete "/tunnels/:name", RemoteAccessController, :delete
    post "/frp-auth", RemoteAccessController, :frp_auth
  end

  scope "/api/v1", NoizuPromptLinguaWeb do
    pipe_through [:api, :authenticated]
    get "/auth/me", AuthController, :me
    get "/users/me", UserController, :show
    patch "/users/me", UserController, :update

    resources "/organizations", OrganizationController,
      only: [:index, :create, :show, :update, :delete]

    post "/media/presign", MediaController, :presign
    post "/media/download", MediaController, :download
    post "/media/register", MediaController, :register

    # User-scoped MCP API keys (legacy; gated by MCP_API_KEY_MINT_ENABLED)
    get "/auth/mcp-keys", AuthController, :list_mcp_keys
    post "/auth/mcp-keys", AuthController, :create_mcp_key
    post "/auth/mcp-keys/setup", AuthController, :create_mcp_setup_key
    # Per-key toolset management (caller's own keys; symmetric with Key.* MCP tools)
    get "/auth/mcp-keys/:id", AuthController, :show_mcp_key
    patch "/auth/mcp-keys/:id", AuthController, :update_mcp_key
    post "/auth/mcp-keys/:id/clone", AuthController, :clone_mcp_key
    delete "/auth/mcp-keys/:id", AuthController, :revoke_mcp_key

    # OAuth MCP connections (pairing grants) — Phase 4 primary surface
    get "/auth/mcp/connections", OAuthConnectionsController, :index
    delete "/auth/mcp/connections/:grant_id", OAuthConnectionsController, :revoke

    # MCP connection config (host + server list) for building setup commands.
    get "/auth/mcp/config", AuthController, :mcp_config
    get "/auth/mcp/catalog", AuthController, :mcp_custom_scope_catalog
    get "/auth/mcp/default-endpoint", AuthController, :show_default_mcp
    patch "/auth/mcp/default-endpoint", AuthController, :update_default_mcp
    get "/auth/mcp/endpoints", McpEndpointsController, :index
    post "/auth/mcp/endpoints", McpEndpointsController, :create
    get "/auth/mcp/endpoints/:id", McpEndpointsController, :show
    patch "/auth/mcp/endpoints/:id", McpEndpointsController, :update
    delete "/auth/mcp/endpoints/:id", McpEndpointsController, :delete
    post "/auth/mcp/endpoints/:id/copy", McpEndpointsController, :duplicate
    post "/auth/mcp/endpoints/:id/use", McpEndpointsController, :use_default
    # Mint an MCP JWT from a pasted raw key (ownership-checked to caller).
    post "/auth/mcp/token", AuthController, :mint_mcp_token
  end

  # REST tool endpoints for trusted backend callers (API-key or JWT auth).
  scope "/api/v1", NoizuPromptLinguaWeb do
    pipe_through [:api, :authenticated]
    post "/tools/web-search", ToolsController, :web_search
    post "/tools/site-to-md", ToolsController, :site_to_md
  end

  scope "/api/v1/organizations/:org_id", NoizuPromptLinguaWeb do
    pipe_through [:api, :authenticated, :org_admin]
    resources "/members", MembershipController, only: [:index, :show, :create, :update, :delete]
  end

  # N4a: MCP tool-set admin (PRD-N4 §4.1) — built-in profiles (read-only, R1)
  # next to the org's own sets; create/update/deactivate/clone through
  # MCP.ToolSets. Org-admin gated; serving gateway lands at N3.
  # N4b: validate dry-run (Validator.compile/3, never persists), the live
  # catalog arg-enum seeds and the real-groups group-options feed.
  scope "/api/v1/organizations/:org_id", NoizuPromptLinguaWeb do
    pipe_through [:api, :authenticated, :org_admin]
    post "/tool-sets/clone", ToolSetProfilesController, :clone
    post "/tool-sets/validate", ToolSetProfilesController, :validate
    get "/tool-sets/group-options", ToolSetProfilesController, :group_options
    get "/tool-sets/arg-enum", ToolSetProfilesController, :arg_enum
    get "/tool-sets", ToolSetProfilesController, :index
    post "/tool-sets", ToolSetProfilesController, :create
    get "/tool-sets/:slug", ToolSetProfilesController, :show
    patch "/tool-sets/:slug", ToolSetProfilesController, :update
    post "/tool-sets/:slug/deactivate", ToolSetProfilesController, :deactivate
  end

  # Browser feature: controller-connected status + captured screenshots/videos.
  scope "/api/v1/organizations/:org_id", NoizuPromptLinguaWeb do
    pipe_through [:api, :authenticated, :org_viewer]
    get "/browser/status", BrowserController, :status
    get "/browser/captures", BrowserController, :captures
  end

  # Agent-memory browser (read-only). Org-scoped by slug/uuid in the path (org_viewer role);
  # memory is addressed per agent slug (call sign or persona slug; "weego" = the org weego).
  scope "/api/organization/:org_id", NoizuPromptLinguaWeb do
    pipe_through [:api, :authenticated, :org_viewer]
    get "/agents", MemoryController, :agents
    get "/agent/:agent_slug/memory", MemoryController, :list
    post "/agent/:agent_slug/memory/recall", MemoryController, :recall
    post "/agent/:agent_slug/memory/recall_by_emotion", MemoryController, :recall_by_emotion
    get "/agent/:agent_slug/memory/:id/associations", MemoryController, :associations
  end

  # Public (unauthenticated) marketing endpoints for the landing page.
  # Status is cheap and uncapped; signup is per-IP rate limited.
  scope "/api/v1/public/marketing", NoizuPromptLinguaWeb do
    pipe_through [:api]
    get "/status", MarketingController, :status
  end

  scope "/api/v1/public/marketing", NoizuPromptLinguaWeb do
    pipe_through [:api, :rate_limited_marketing]
    post "/signup", MarketingController, :signup
  end

  scope "/api/v1/admin", NoizuPromptLinguaWeb do
    pipe_through [:api, :authenticated, :admin]
    get "/users", AdminController, :list_users
    get "/users/:id", AdminController, :show_user
    patch "/users/:id", AdminController, :update_user
    get "/organizations", AdminController, :list_organizations
    get "/organizations/:id", AdminController, :show_organization

    # MCP API keys (user-scoped) — admin mints/revokes long-lived keys used to
    # bootstrap short-lived MCP JWTs via POST /api/mcp/token.
    get "/users/:user_id/mcp-keys", AdminController, :list_mcp_keys
    post "/users/:user_id/mcp-keys", AdminController, :create_mcp_key
    delete "/users/:user_id/mcp-keys/:id", AdminController, :revoke_mcp_key
    get "/users/:user_id/mcp-default-endpoint", AdminController, :show_user_default_mcp

    # Per-key toolset management (cross-user; symmetric with Key.* MCP tools).
    get "/mcp-keys", AdminController, :list_all_mcp_keys
    get "/mcp-keys/:id", AdminController, :show_mcp_key
    patch "/mcp-keys/:id", AdminController, :update_mcp_key
    post "/mcp-keys/:id/clone", AdminController, :clone_mcp_key

    # OAuth clients (DCR + first-party) — admin visibility + revoke (cascades
    # to active pairing grants + refresh tokens for that client).
    get "/oauth-clients", AdminController, :list_oauth_clients
    delete "/oauth-clients/:client_id", AdminController, :revoke_oauth_client

    # Custom MCP include scopes (global admin-managed presets).
    get "/mcp-custom-scopes/catalog", AdminController, :mcp_custom_scope_catalog
    get "/mcp-custom-scopes", AdminController, :list_mcp_custom_scopes
    post "/mcp-custom-scopes", AdminController, :create_mcp_custom_scope
    get "/mcp-custom-scopes/:slug", AdminController, :show_mcp_custom_scope
    patch "/mcp-custom-scopes/:slug", AdminController, :update_mcp_custom_scope
    delete "/mcp-custom-scopes/:slug", AdminController, :delete_mcp_custom_scope
    post "/mcp-custom-scopes/:slug/clone", AdminController, :clone_mcp_custom_scope
    # Legacy alias — the action was originally named copy; kept resolving so any
    # external callers with copy in their scripts keep working.
    post "/mcp-custom-scopes/:slug/copy", AdminController, :clone_mcp_custom_scope

    # D3: per-scope client permissions — client universe + per-client
    # toolset_config jsonb (F2 EffectiveToolset cascade layer 3).
    get "/mcp-custom-scopes/:slug/clients", AdminController, :list_scope_clients

    get "/mcp-custom-scopes/:slug/clients/:kind/:id/toolset_config",
        AdminController,
        :show_client_toolset_config

    put "/mcp-custom-scopes/:slug/clients/:kind/:id/toolset_config",
        AdminController,
        :update_client_toolset_config

    # D3: ACL group admin (F1 NoizuPromptLingua.Acl context) — group CRUD +
    # membership. DELETE groups is a soft archive; member refs are ERP refs
    # ({"type","id"} maps or "type:id" strings).
    get "/acl/groups", AdminController, :list_acl_groups
    post "/acl/groups", AdminController, :create_acl_group
    patch "/acl/groups/:id", AdminController, :update_acl_group
    delete "/acl/groups/:id", AdminController, :delete_acl_group
    post "/acl/groups/:id/members", AdminController, :add_acl_group_member
    delete "/acl/groups/:id/members", AdminController, :remove_acl_group_member

    # W4 MCP entities — versioned prompts + resources/resource templates.
    get "/mcp-prompts", AdminController, :list_mcp_prompts
    post "/mcp-prompts", AdminController, :create_mcp_prompt
    patch "/mcp-prompts/:slug", AdminController, :update_mcp_prompt
    delete "/mcp-prompts/:slug", AdminController, :delete_mcp_prompt
    post "/mcp-prompts/:slug/versions", AdminController, :publish_mcp_prompt_version

    get "/mcp-resources", AdminController, :list_mcp_resources
    post "/mcp-resources", AdminController, :create_mcp_resource
    patch "/mcp-resources/:id", AdminController, :update_mcp_resource
    delete "/mcp-resources/:id", AdminController, :delete_mcp_resource

    get "/mcp-resource-templates", AdminController, :list_mcp_resource_templates
    post "/mcp-resource-templates", AdminController, :create_mcp_resource_template
    patch "/mcp-resource-templates/:id", AdminController, :update_mcp_resource_template
    delete "/mcp-resource-templates/:id", AdminController, :delete_mcp_resource_template

    # mcp_overview review flow — list generated overviews, approve/reject/edit
    # (editing the Markdown implies approval). UI is a follow-up.
    get "/mcp-overviews", McpOverviewController, :index
    patch "/mcp-overviews/:id/approve", McpOverviewController, :approve
    patch "/mcp-overviews/:id/reject", McpOverviewController, :reject
    patch "/mcp-overviews/:id", McpOverviewController, :update

    # LLM model catalog (global) — editable provider/model pairs for the Mock MCP
    # picker / MCP ListModels (drives mock MCPs + asset LLM selection).
    get "/llm-models", AdminController, :list_llm_models
    post "/llm-models", AdminController, :create_llm_model
    patch "/llm-models/:id", AdminController, :update_llm_model
    delete "/llm-models/:id", AdminController, :delete_llm_model

    # LLM provider introspection — fetch available models from provider APIs
    get "/llm-providers/:provider/models", AdminController, :fetch_provider_models
    post "/llm-providers/:provider/test", AdminController, :test_llm_configuration

    # Marketing signups + caps (public landing capture; admin-editable knobs).
    get "/marketing/settings", AdminController, :marketing_settings
    put "/marketing/settings", AdminController, :update_marketing_settings
    get "/marketing/signups", AdminController, :list_marketing_signups

    # pm_core membership reconciliation (post-cutover backfill): GET = dry-run
    # census of planned inserts; POST dry_run=false executes. Admin-gated above.

    # Media provider config (org-scoped) — per-org api_key/model/settings overrides
    # for the registered genai media providers used by asset generation.
    scope "/organizations/:org_id/media-providers" do
      get "/", AdminController, :list_media_providers
      post "/", AdminController, :create_media_provider
      patch "/:id", AdminController, :update_media_provider
      delete "/:id", AdminController, :delete_media_provider
    end

    # GitHub integration (tokens + repos) — org-scoped
    scope "/organizations/:org_id/github" do
      get "/tokens", AdminController, :list_github_tokens
      post "/tokens", AdminController, :create_github_token
      delete "/tokens/:id", AdminController, :delete_github_token
      get "/repos", AdminController, :list_github_repos
      post "/repos", AdminController, :create_github_repo
      patch "/repos/:id", AdminController, :update_github_repo
      delete "/repos/:id", AdminController, :delete_github_repo

      get "/repos/:repo_id/grants", AdminController, :list_github_repo_grants
      post "/repos/:repo_id/grants", AdminController, :grant_github_repo_access
      delete "/repos/:repo_id/grants/:id", AdminController, :revoke_github_repo_access
    end
  end

  # Media serving (public/conditional auth — checked inline in controller)
  scope "/media", NoizuPromptLinguaWeb do
    pipe_through [:api]
    get "/:short_id", MediaServeController, :show
    get "/:short_id/*filename", MediaServeController, :show
  end

  # SAML 2.0 (Samly handles assertion consumer service, metadata, etc.)
  if Application.compile_env(:noizu_prompt_lingua, :saml_enabled) do
    scope "/sso/saml" do
      pipe_through [:sso_session]
      forward "/", Samly.Router
    end
  end

  # OIDC redirect flow
  scope "/auth/oidc", NoizuPromptLinguaWeb do
    pipe_through [:sso_session]
    get "/", SSOController, :oidc_init
    get "/callback", SSOController, :oidc_callback
  end

  # Social OAuth disabled — Authentik is the only identity provider.
  # (Authentik is reached via the OIDC redirect flow above.)

  # PBAC v2: Groups & Memberships (authenticated, read-only)
  scope "/api/v1", NoizuPromptLinguaWeb do
    pipe_through [:api, :authenticated]

    get "/groups", GroupController, :index
    get "/groups/:id", GroupController, :show
    get "/groups/:id/policies", GroupController, :policies

    get "/memberships/me", AuthzMembershipController, :my_memberships
    get "/memberships/organizations/:org_id", AuthzMembershipController, :org_members
    get "/memberships/organizations/:org_id/members/:id", AuthzMembershipController, :org_member
    get "/memberships/projects/:project_id", AuthzMembershipController, :project_members

    get "/policies/me", PolicyController, :my_policies
    post "/policies/check", PolicyController, :check
    post "/policies/explain", PolicyController, :explain
  end

  # PBAC v2: Projects (authenticated, permission-checked per action)
  scope "/api/v1/organizations/:org_id", NoizuPromptLinguaWeb do
    pipe_through [:api, :authenticated]

    post "/assistant/approval-script", VoiceAssistantController, :approval_script

    resources "/projects", ProjectController, only: [:index, :create, :show, :update, :delete]

    scope "/projects/:project_id" do
      post "/archive", ProjectController, :archive
      post "/unarchive", ProjectController, :unarchive
      post "/leave", ProjectController, :leave
      get "/members", ProjectController, :members
      post "/members", ProjectController, :add_member
      patch "/members/:member_user_id", ProjectController, :update_member
      delete "/members/:member_user_id", ProjectController, :remove_member
    end
  end

  # Sessions: work sessions grouping rooms, artifacts, and tickets.
  # Org is required; associating a session with a project is optional.
  scope "/api/v1/organizations/:org_id", NoizuPromptLinguaWeb do
    pipe_through [:api, :authenticated]

    resources "/sessions", SessionController, only: [:index, :create, :show, :update, :delete]

    scope "/sessions/:session_id" do
      post "/archive", SessionController, :archive
      post "/unarchive", SessionController, :unarchive
    end
  end

  # W7: embedded-component data plane. The same boards/tickets listings the
  # npl-queue-board Lit component consumes, with per-consumer MCP API key
  # acceptance in front of the normal session/JWT pipeline (the plug is
  # pass-through when no key is present; org-scope role checks still apply
  # to the key owner). Declared before the general org scopes so these two
  # GETs take the key-aware route.
  scope "/api/v1/organizations/:org_id", NoizuPromptLinguaWeb do
    pipe_through [:api, :mcp_key_optional, :authenticated]
    get "/boards", BoardController, :index
    get "/tickets", TicketController, :index
  end

  # Chat, Artifacts, Reviews: bound to an organization (required); associating
  # with a project is optional. Mirrors the sessions org-scoped pattern.
  scope "/api/v1/organizations/:org_id", NoizuPromptLinguaWeb do
    pipe_through [:api, :authenticated]

    # Org usage dashboard (counts + series; no list-limit truncation)
    get "/dashboard/stats", DashboardController, :stats

    resources "/chat/rooms", ChatController, only: [:index, :create, :show, :update, :delete]
    get "/chat/rooms/:room_id/messages", ChatController, :index_messages
    post "/chat/rooms/:room_id/messages", ChatController, :create_message
    get "/chat/rooms/:room_id/messages/:message_id/replies", ChatController, :index_replies

    get "/chat/rooms/:room_id/messages/:message_id/reactions",
        ChatController,
        :index_message_reactions

    post "/chat/rooms/:room_id/messages/:message_id/reactions",
         ChatController,
         :add_message_reaction

    delete "/chat/rooms/:room_id/messages/:message_id/reactions",
           ChatController,
           :remove_message_reaction

    resources "/artifacts", ArtifactController, only: [:index, :create, :show]
    get "/artifacts/:artifact_id/revisions", ArtifactController, :index_revisions
    post "/artifacts/:artifact_id/revisions", ArtifactController, :create_revision
    resources "/reviews", ReviewController, only: [:index, :create, :show, :update]
    resources "/tickets", TicketController, only: [:index, :create, :show, :update]

    post "/reviews/:review_id/complete", ReviewController, :complete

    # Mock MCP: LLM-inference-driven pseudo MCP servers (org-scoped management).
    # Slug is the natural key; the live JSON-RPC endpoint lives at the
    # mockmcp.<host> subdomain (see gateway scope below).
    get "/mock-mcp-models", MockMCPController, :models

    # Org-scoped reusable LLM connection pool (provider/model/endpoint/key).
    get "/mock-mcp-llms", MockMCPController, :list_llms
    post "/mock-mcp-llms", MockMCPController, :create_llm
    put "/mock-mcp-llms/:id", MockMCPController, :update_llm
    delete "/mock-mcp-llms/:id", MockMCPController, :delete_llm

    resources "/mock-mcp", MockMCPController,
      only: [:index, :create, :show, :update, :delete],
      param: "slug"

    post "/mock-mcp/:slug/activate", MockMCPController, :activate
    post "/mock-mcp/:slug/generate-tools", MockMCPController, :generate_tools
    post "/mock-mcp/:slug/generate-modules", MockMCPController, :generate_modules
    # Review / edit / approve generated module source before it serves live.
    get "/mock-mcp/:slug/modules", MockMCPController, :list_modules
    put "/mock-mcp/:slug/modules/:tool", MockMCPController, :update_module
    post "/mock-mcp/:slug/modules/:tool/approve", MockMCPController, :approve_module
    post "/mock-mcp/:slug/modules/:tool/test", MockMCPController, :test_module
    delete "/mock-mcp/:slug/modules/:tool", MockMCPController, :delete_module
    post "/mock-mcp/:slug/provision-db", MockMCPController, :provision_db
    get "/mock-mcp/:slug/calls", MockMCPController, :calls

    # Portal: state browser over the agent's private datastore + playground.
    get "/mock-mcp/:slug/state/db/tables", MockMCPController, :state_db_tables
    post "/mock-mcp/:slug/state/db/query", MockMCPController, :state_db_query
    get "/mock-mcp/:slug/state/redis", MockMCPController, :state_redis
    post "/mock-mcp/:slug/invoke", MockMCPController, :invoke

    # Ticket field & type definitions (tri-scoped config; managed by id).
    get "/ticket-field-definitions", FieldDefinitionController, :index
    get "/ticket-field-definitions/:id", FieldDefinitionController, :show
    post "/ticket-field-definitions", FieldDefinitionController, :create
    put "/ticket-field-definitions/:id", FieldDefinitionController, :update
    delete "/ticket-field-definitions/:id", FieldDefinitionController, :delete

    get "/ticket-type-definitions", TypeDefinitionController, :index
    post "/ticket-type-definitions", TypeDefinitionController, :create
    get "/ticket-type-definitions/:id", TypeDefinitionController, :show
    put "/ticket-type-definitions/:id", TypeDefinitionController, :update
    delete "/ticket-type-definitions/:id", TypeDefinitionController, :delete

    # Boards (revamped queues): methodology-aware, tri-scoped. Nested stages
    # (columns/phases) and iterations (sprints/cycles).
    resources "/boards", BoardController, only: [:index, :create, :show, :update, :delete]

    scope "/boards/:board_id" do
      post "/stages", BoardController, :add_stage
      put "/stages/:stage_id", BoardController, :update_stage
      delete "/stages/:stage_id", BoardController, :delete_stage
      post "/iterations", BoardController, :add_iteration
      put "/iterations/:iteration_id", BoardController, :update_iteration
      delete "/iterations/:iteration_id", BoardController, :delete_iteration
    end

    # Assets: media-prompt entries + generated outputs (org-scoped, optional project).
    resources "/assets", AssetController, only: [:index, :create, :show, :update, :delete]

    scope "/assets/:asset_id" do
      get "/outputs", AssetController, :outputs
      post "/generate", AssetController, :generate
      get "/history", AssetController, :history
      post "/active", AssetController, :set_active
      post "/outputs/:output_id/accept", AssetController, :accept_output
      post "/outputs/:output_id/reject", AssetController, :reject_output
    end

    # Personas: named identities with bio, work log/journal, and personal
    # knowledge base (org-scoped, optional project).
    resources "/personas", PersonaController, only: [:index, :create, :show, :update, :delete]

    scope "/personas/:persona_id" do
      get "/journal", PersonaController, :journal
      post "/journal", PersonaController, :add_journal
      delete "/journal/:entry_id", PersonaController, :delete_journal
      get "/knowledge", PersonaController, :knowledge
      post "/knowledge", PersonaController, :add_knowledge
      put "/knowledge/:entry_id", PersonaController, :update_knowledge
      delete "/knowledge/:entry_id", PersonaController, :delete_knowledge
    end

    # Instructions: reusable, versioned prompts referenced by slug handle and
    # rendered with per-task params to spawn sub-agents (org-scoped, optional project).
    resources "/instructions", InstructionController,
      only: [:index, :create, :show, :update, :delete]

    scope "/instructions/:instruction_id" do
      get "/versions", InstructionController, :versions
      post "/active-version", InstructionController, :set_active_version
      post "/render", InstructionController, :render_instruction
    end

    # Unicode Codex: layered global/org/project reference data for Unicode
    # glyphs, control codes, invisible characters, and NPL special usages.
    get "/unicode/elements", UnicodeCodexController, :index_elements
    get "/unicode/elements/:slug", UnicodeCodexController, :show_element
    get "/unicode/elements/:slug/relations", UnicodeCodexController, :relations
    get "/unicode/special-usages", UnicodeCodexController, :index_special_usages
    get "/unicode/special-usages/:slug", UnicodeCodexController, :show_special_usage
  end

  # Wiki: spaces (org-scoped, optional project), pages, comments, attachments,
  # and reactions (on pages and comments). Mirrors the org-scoped domain pattern.
  scope "/api/v1/organizations/:org_id/wiki", NoizuPromptLinguaWeb do
    pipe_through [:api, :authenticated]

    get "/spaces", WikiController, :index_spaces
    post "/spaces", WikiController, :create_space
    get "/spaces/:id", WikiController, :show_space
    put "/spaces/:id", WikiController, :update_space
    delete "/spaces/:id", WikiController, :delete_space

    get "/spaces/:space_id/pages", WikiController, :index_pages
    post "/spaces/:space_id/pages", WikiController, :create_page

    get "/pages/:id", WikiController, :show_page
    put "/pages/:id", WikiController, :update_page
    delete "/pages/:id", WikiController, :delete_page

    get "/pages/:page_id/comments", WikiController, :index_comments
    post "/pages/:page_id/comments", WikiController, :create_comment
    delete "/comments/:id", WikiController, :delete_comment

    get "/pages/:page_id/attachments", WikiController, :index_attachments
    post "/pages/:page_id/attachments", WikiController, :create_attachment
    delete "/attachments/:id", WikiController, :delete_attachment

    get "/pages/:page_id/reactions", WikiController, :index_page_reactions
    post "/pages/:page_id/reactions", WikiController, :add_page_reaction
    delete "/pages/:page_id/reactions", WikiController, :remove_page_reaction

    get "/comments/:comment_id/reactions", WikiController, :index_comment_reactions
    post "/comments/:comment_id/reactions", WikiController, :add_comment_reaction
    delete "/comments/:comment_id/reactions", WikiController, :remove_comment_reaction
  end

  # GitHub: org-scoped read/write operations (authenticated, org-member).
  # Repo access is verified per-request against the repo ACL (can_access?/3)
  # using the mapped GitHub token.
  scope "/api/v1/organizations/:org_id/github", NoizuPromptLinguaWeb do
    pipe_through [:api, :authenticated]

    # Repos (read from our DB, ACL-filtered)
    get "/", GithubController, :index

    scope "/repos/:repo_id" do
      # Pull Requests
      get "/pulls", GithubController, :list_pulls
      get "/pulls/:pull_number", GithubController, :get_pull
      post "/pulls", GithubController, :create_pull
      put "/pulls/:pull_number/merge", GithubController, :merge_pull
      get "/pulls/:pull_number/comments", GithubController, :list_pull_comments
      post "/pulls/:pull_number/comments", GithubController, :create_pull_comment

      # Issues
      get "/issues", GithubController, :list_issues
      get "/issues/:issue_number", GithubController, :get_issue
      post "/issues", GithubController, :create_issue
      post "/issues/:issue_number/comments", GithubController, :create_issue_comment

      # Branches
      get "/branches", GithubController, :list_branches
      post "/branches", GithubController, :create_branch
    end
  end

  # PBAC v2: Custom Roles (authenticated, permission-checked per action)
  scope "/api/v1/organizations/:org_id", NoizuPromptLinguaWeb do
    pipe_through [:api, :authenticated]

    resources "/roles", CustomRoleController, only: [:index, :create, :show, :update, :delete]

    scope "/roles/:role_id" do
      get "/permissions", CustomRoleController, :show
      post "/permissions", CustomRoleController, :add_permission
      delete "/permissions/:permission_id", CustomRoleController, :remove_permission
    end
  end

  # PBAC v2: Policy admin (admin only)
  scope "/api/v1", NoizuPromptLinguaWeb do
    pipe_through [:api, :authenticated, :admin]

    resources "/policies", PolicyController, only: [:index, :create, :show, :update, :delete]
    post "/users/:user_id/policies", PolicyController, :attach_to_user
    delete "/users/:user_id/policies/:policy_id", PolicyController, :detach_from_user
  end

  # NPL conventions reference data (read-only, any authenticated viewer)
  scope "/api/v1/npl", NoizuPromptLinguaWeb do
    pipe_through [:api, :authenticated]

    get "/sections", NPLController, :index_sections
    get "/conventions", NPLController, :index_conventions
    get "/conventions/:section/:slug", NPLController, :show_convention
    get "/labels", NPLController, :index_labels
    post "/spec", NPLController, :generate_spec
  end

  if Application.compile_env(:noizu_prompt_lingua, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: NoizuPromptLinguaWeb.Telemetry
    end
  end
end
