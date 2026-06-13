defmodule BoeWeb.Router do
  use BoeWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug BoeWeb.AuthPipeline
  end

  # Unversioned health check for load balancers / monitoring
  scope "/", BoeWeb do
    pipe_through :api

    get "/health", HealthController, :index
  end

  scope "/api/v1", BoeWeb do
    pipe_through :api

    post "/auth/register", AuthController, :register
    post "/auth/login", AuthController, :login
    post "/auth/refresh", AuthController, :refresh
  end

  scope "/api/v1", BoeWeb do
    pipe_through [:api, :authenticated]

    get "/auth/me", AuthController, :me
    get "/character", CharacterController, :show
    post "/character", CharacterController, :create
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:boe, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: BoeWeb.Telemetry
    end
  end
end
