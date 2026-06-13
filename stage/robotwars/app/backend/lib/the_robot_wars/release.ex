defmodule TheRobotWars.Release do
  @moduledoc """
  Schema migrations are handled by Liquibase (see backend/db/).
  This module provides seed running for releases.
  """
  @app :the_robot_wars

  def seed do
    load_app()

    for repo <- repos() do
      {:ok, _, _} =
        Ecto.Migrator.with_repo(repo, fn _repo ->
          Code.eval_file(Path.join([:code.priv_dir(@app), "repo", "seeds.exs"]))
        end)
    end
  end

  defp repos, do: Application.fetch_env!(@app, :ecto_repos)

  defp load_app do
    Application.ensure_all_started(:ssl)
    Application.load(@app)
  end
end
