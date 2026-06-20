defmodule NoizuPromptLinguaWeb.Router do
  use NoizuPromptLinguaWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug NoizuPromptLinguaWeb.AuthPipeline
  end

  pipeline :sso_session do
    plug Plug.Session,
      store: :cookie,
      key: "_starter_sso",
      signing_salt: "sso_session_salt",
      same_site: "Lax",
      max_age: 300
    plug :fetch_session
  end

  pipeline :rate_limited_auth do
    plug NoizuPromptLinguaWeb.Plugs.RateLimit, action: :auth
  end

  pipeline :rate_limited_sensitive do
    plug NoizuPromptLinguaWeb.Plugs.RateLimit, action: :auth_sensitive
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
  end

  # Mint a short-lived MCP JWT from an active MCP API key. This is the bootstrap
  # endpoint clients call to obtain the Bearer token the MCP servers require.
  scope "/api/mcp", NoizuPromptLinguaWeb do
    pipe_through [:api, :rate_limited_auth]
    post "/token", TokenController, :create
  end

  # MCP servers (Streamable HTTP), routed by subdomain — each domain is served
  # at `<domain>.<host>/mcp` (e.g. sessions.tobor.locker/mcp). The `host:`
  # prefix match (trailing dot) matches any host beginning with that label.
  # The root aggregator (all domains + Discovery) is served at the bare host
  # under `/mcp`. Requests must present a Bearer MCP JWT (see MCPConfig).
  scope "/", host: "organizations." do
    forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug,
      NoizuPromptLinguaWeb.MCPConfig.plug_opts(NoizuPromptLingua.MCP.Organizations)
  end

  scope "/", host: "projects." do
    forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug,
      NoizuPromptLinguaWeb.MCPConfig.plug_opts(NoizuPromptLingua.MCP.Projects)
  end

  scope "/", host: "sessions." do
    forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug,
      NoizuPromptLinguaWeb.MCPConfig.plug_opts(NoizuPromptLingua.MCP.Sessions)
  end

  scope "/", host: "artifacts." do
    forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug,
      NoizuPromptLinguaWeb.MCPConfig.plug_opts(NoizuPromptLingua.Domains.Artifacts.MCP)
  end

  scope "/", host: "chat." do
    forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug,
      NoizuPromptLinguaWeb.MCPConfig.plug_opts(NoizuPromptLingua.Domains.Chat.MCP)
  end

  scope "/", host: "review." do
    forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug,
      NoizuPromptLinguaWeb.MCPConfig.plug_opts(NoizuPromptLingua.Domains.Review.MCP)
  end

  scope "/", host: "tickets." do
    forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug,
      NoizuPromptLinguaWeb.MCPConfig.plug_opts(NoizuPromptLingua.Domains.Tickets.MCP)
  end

  scope "/", host: "wiki." do
    forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug,
      NoizuPromptLinguaWeb.MCPConfig.plug_opts(NoizuPromptLingua.Domains.Wiki.MCP)
  end

  scope "/mcp" do
    forward "/", Noizu.MCP.Transport.StreamableHTTP.Plug,
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
  end

  scope "/api/v1", NoizuPromptLinguaWeb do
    pipe_through [:api, :authenticated]
    get "/auth/me", AuthController, :me
    get "/users/me", UserController, :show
    patch "/users/me", UserController, :update
    resources "/organizations", OrganizationController, only: [:index, :create, :show, :update, :delete]
    post "/media/presign", MediaController, :presign
    post "/media/download", MediaController, :download
    post "/media/register", MediaController, :register

    # User-scoped MCP API keys
    get "/auth/mcp-keys", AuthController, :list_mcp_keys
    post "/auth/mcp-keys", AuthController, :create_mcp_key
    delete "/auth/mcp-keys/:id", AuthController, :revoke_mcp_key

    # MCP connection config (host + server list) for building setup commands.
    get "/auth/mcp/config", AuthController, :mcp_config
    # Mint an MCP JWT from a pasted raw key (ownership-checked to caller).
    post "/auth/mcp/token", AuthController, :mint_mcp_token
  end

  scope "/api/v1/organizations/:org_id", NoizuPromptLinguaWeb do
    pipe_through [:api, :authenticated, :org_admin]
    resources "/members", MembershipController, only: [:index, :create, :update, :delete]
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
    get "/memberships/projects/:project_id", AuthzMembershipController, :project_members

    get "/policies/me", PolicyController, :my_policies
    post "/policies/check", PolicyController, :check
    post "/policies/explain", PolicyController, :explain
  end

  # PBAC v2: Projects (authenticated, permission-checked per action)
  scope "/api/v1/organizations/:org_id", NoizuPromptLinguaWeb do
    pipe_through [:api, :authenticated]

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

  # Chat, Artifacts, Reviews: bound to an organization (required); associating
  # with a project is optional. Mirrors the sessions org-scoped pattern.
  scope "/api/v1/organizations/:org_id", NoizuPromptLinguaWeb do
    pipe_through [:api, :authenticated]

    resources "/chat/rooms", ChatController, only: [:index, :create, :show]
    resources "/artifacts", ArtifactController, only: [:index, :create, :show]
    resources "/reviews", ReviewController, only: [:index, :create, :show]
    resources "/tickets", TicketController, only: [:index, :create, :show, :update]

    post "/reviews/:review_id/complete", ReviewController, :complete

    # Ticket field & type definitions (tri-scoped config; managed by id).
    get "/ticket-field-definitions", FieldDefinitionController, :index
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
