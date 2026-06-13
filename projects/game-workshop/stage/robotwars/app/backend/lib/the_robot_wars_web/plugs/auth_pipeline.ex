defmodule TheRobotWarsWeb.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :the_robot_wars,
    module: TheRobotWars.Guardian,
    error_handler: TheRobotWarsWeb.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
