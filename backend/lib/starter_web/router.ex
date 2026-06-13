defmodule StarterWeb.Router do
  use StarterWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug StarterWeb.AuthPipeline
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
    plug StarterWeb.Plugs.RateLimit, action: :auth
  end

  pipeline :rate_limited_sensitive do
    plug StarterWeb.Plugs.RateLimit, action: :auth_sensitive
  end

  pipeline :org_viewer do
    plug StarterWeb.Plugs.RequireRole, role: "viewer"
  end

  pipeline :org_editor do
    plug StarterWeb.Plugs.RequireRole, role: "editor"
  end

  pipeline :org_admin do
    plug StarterWeb.Plugs.RequireRole, role: "admin"
  end

  pipeline :org_owner do
    plug StarterWeb.Plugs.RequireRole, role: "owner"
  end

  pipeline :admin do
    plug StarterWeb.Plugs.RequireAdmin
  end

  scope "/", StarterWeb do
    pipe_through :api
    get "/health", HealthController, :index
  end

  scope "/api/v1", StarterWeb do
    pipe_through [:api, :rate_limited_auth]
    post "/auth/register", AuthController, :register
    post "/auth/login", AuthController, :login
    post "/auth/refresh", AuthController, :refresh
    get "/auth/sso/providers", SSOController, :providers
    post "/auth/sso/exchange", SSOController, :exchange
    get "/config/features", ConfigController, :features
  end

  scope "/api/v1", StarterWeb do
    pipe_through [:api, :rate_limited_sensitive]
    post "/auth/magic-link", AuthController, :request_magic_link
    post "/auth/magic-link/verify", AuthController, :verify_magic_link
    post "/auth/otp-login", AuthController, :request_otp_login
    post "/auth/otp-login/verify", AuthController, :verify_otp_login
    post "/auth/password-reset", AuthController, :request_password_reset
    post "/auth/password-reset/verify", AuthController, :verify_password_reset
    post "/auth/verify-email/confirm", AuthController, :verify_email
  end

  scope "/api/v1", StarterWeb do
    pipe_through [:api, :authenticated]
    get "/auth/me", AuthController, :me
    post "/auth/verify-email", AuthController, :send_verification
    get "/users/me", UserController, :show
    patch "/users/me", UserController, :update
    resources "/organizations", OrganizationController, only: [:index, :create, :show]
    post "/media/presign", MediaController, :presign
    post "/media/download", MediaController, :download
    post "/media/register", MediaController, :register
  end

  scope "/api/v1/organizations/:org_id", StarterWeb do
    pipe_through [:api, :authenticated, :org_admin]
    resources "/members", MembershipController, only: [:index, :create, :update, :delete]
  end

  scope "/api/v1/admin", StarterWeb do
    pipe_through [:api, :authenticated, :admin]
    get "/users", AdminController, :list_users
    get "/users/:id", AdminController, :show_user
    get "/organizations", AdminController, :list_organizations
    get "/organizations/:id", AdminController, :show_organization
  end

  # Media serving (public/conditional auth — checked inline in controller)
  scope "/media", StarterWeb do
    pipe_through [:api]
    get "/:short_id", MediaServeController, :show
    get "/:short_id/*filename", MediaServeController, :show
  end

  # SAML 2.0 (Samly handles assertion consumer service, metadata, etc.)
  if Application.compile_env(:starter, :saml_enabled) do
    scope "/sso/saml" do
      pipe_through [:sso_session]
      forward "/", Samly.Router
    end
  end

  # OIDC redirect flow
  scope "/auth/oidc", StarterWeb do
    pipe_through [:sso_session]
    get "/", SSOController, :oidc_init
    get "/callback", SSOController, :oidc_callback
  end

  # Social OAuth (ueberauth handles request + callback)
  scope "/auth", StarterWeb do
    pipe_through [:sso_session]
    get "/:provider", SSOController, :oauth_request
    get "/:provider/callback", SSOController, :oauth_callback
  end

  # PBAC v2: Groups & Memberships (authenticated, read-only)
  scope "/api/v1", StarterWeb do
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
  scope "/api/v1/organizations/:org_id", StarterWeb do
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

  # PBAC v2: Custom Roles (authenticated, permission-checked per action)
  scope "/api/v1/organizations/:org_id", StarterWeb do
    pipe_through [:api, :authenticated]

    resources "/roles", CustomRoleController, only: [:index, :create, :show, :update, :delete]

    scope "/roles/:role_id" do
      get "/permissions", CustomRoleController, :show
      post "/permissions", CustomRoleController, :add_permission
      delete "/permissions/:permission_id", CustomRoleController, :remove_permission
    end
  end

  # PBAC v2: Policy admin (admin only)
  scope "/api/v1", StarterWeb do
    pipe_through [:api, :authenticated, :admin]

    resources "/policies", PolicyController, only: [:index, :create, :show, :update, :delete]
    post "/users/:user_id/policies", PolicyController, :attach_to_user
    delete "/users/:user_id/policies/:policy_id", PolicyController, :detach_from_user
  end

  if Application.compile_env(:starter, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: StarterWeb.Telemetry
    end
  end
end
