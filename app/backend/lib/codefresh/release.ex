defmodule Codefresh.Release do
  @app :codefresh

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  @doc """
  Run the environment-appropriate seed file inside a running release.
  Invoke via: `bin/codefresh eval 'Codefresh.Release.seed()'`
  """
  def seed(env \\ "dev") do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, fn _repo ->
        seed_file(env)
      end)
    end
  end

  defp seed_file(env) do
    path = Path.join([:code.priv_dir(@app), "repo", "seeds", "#{env}-seeds.exs"])

    if File.exists?(path) do
      Code.eval_file(path)
      :ok
    else
      raise "seed file not found: #{path}"
    end
  end

  defp repos, do: Application.fetch_env!(@app, :ecto_repos)

  defp load_app do
    Application.ensure_all_started(:ssl)
    Application.load(@app)
  end
end
