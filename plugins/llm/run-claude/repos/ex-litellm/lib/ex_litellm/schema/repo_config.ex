defmodule ExLiteLLM.Schema.Repo.Config do
  @moduledoc """
  Resolves the Ecto repo configuration at boot from the launch settings.

  SQLite is the default. A `database_url` (from `general_settings.database_url`
  or `LITELLM_DATABASE_URL`) selects the backend:

    * `postgres://` / `postgresql://` → Postgres adapter (Phase 5; the URL is
      applied so the schema/migrations run against Postgres).
    * `sqlite://path` or a bare filesystem path → SQLite file.
    * unset → the compiled default SQLite path under `~/.local/state/ex-litellm/`.

  The chosen adapter + connection settings are written into application env
  under `{:ex_litellm, ExLiteLLM.Schema.Repo}` before the repo child starts.
  """

  alias ExLiteLLM.Runtime

  @doc "Apply resolved DB settings to the repo's app-env before it boots."
  @spec apply(Runtime.t()) :: :ok
  def apply(%Runtime{database_url: url}) do
    base = Application.get_env(:ex_litellm, ExLiteLLM.Schema.Repo, [])
    Application.put_env(:ex_litellm, ExLiteLLM.Schema.Repo, resolve(url, base))
    :ok
  end

  @doc false
  @spec resolve(String.t() | nil, keyword()) :: keyword()
  def resolve(nil, base), do: ensure_sqlite_dir(base)

  def resolve(url, base) when is_binary(url) do
    cond do
      String.starts_with?(url, "postgres://") or String.starts_with?(url, "postgresql://") ->
        base
        |> Keyword.put(:adapter, Ecto.Adapters.Postgres)
        |> Keyword.delete(:journal_mode)
        |> Keyword.delete(:busy_timeout)
        |> Keyword.put(:url, url)

      String.starts_with?(url, "sqlite://") ->
        path = String.replace_prefix(url, "sqlite://", "")
        ensure_sqlite_dir(Keyword.put(base, :database, path))

      true ->
        # Bare path — treat as a SQLite file.
        ensure_sqlite_dir(Keyword.put(base, :database, url))
    end
  end

  # For a file-backed SQLite DB, make sure the parent dir exists.
  defp ensure_sqlite_dir(opts) do
    case Keyword.get(opts, :database) do
      path when is_binary(path) and path != ":memory:" ->
        path |> Path.dirname() |> File.mkdir_p()
        opts

      _ ->
        opts
    end
  end
end
