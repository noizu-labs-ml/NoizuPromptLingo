defmodule DerobotWeb.Router do
  use DerobotWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug DerobotWeb.AuthPipeline
  end

  pipeline :sso_session do
    plug Plug.Session,
      store: :cookie,
      key: "_derobot_sso",
      signing_salt: "sso_session_salt",
      same_site: "Lax",
      max_age: 300

    plug :fetch_session
  end

  scope "/", DerobotWeb do
    pipe_through :api
    get "/health", HealthController, :index
  end

  scope "/api/v1", DerobotWeb do
    pipe_through :api
    post "/auth/register", AuthController, :register
    post "/auth/login", AuthController, :login
    post "/auth/refresh", AuthController, :refresh
    get "/auth/sso/providers", SSOController, :providers
    post "/auth/sso/exchange", SSOController, :exchange
  end

  scope "/api/v1", DerobotWeb do
    pipe_through [:api, :authenticated]
    get "/auth/me", AuthController, :me
  end

  # SAML 2.0
  if Application.compile_env(:derobot, :saml_enabled) do
    scope "/sso/saml" do
      pipe_through [:sso_session]
      forward "/", Samly.Router
    end
  end

  # OIDC redirect flow
  scope "/auth/oidc", DerobotWeb do
    pipe_through [:sso_session]
    get "/", SSOController, :oidc_init
    get "/callback", SSOController, :oidc_callback
  end

  # Social OAuth (ueberauth handles request + callback)
  scope "/auth", DerobotWeb do
    pipe_through [:sso_session]
    get "/:provider", SSOController, :oauth_request
    get "/:provider/callback", SSOController, :oauth_callback
  end

  if Application.compile_env(:derobot, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: DerobotWeb.Telemetry
    end
  end
end
