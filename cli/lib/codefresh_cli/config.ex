defmodule CodefreshCli.Config do
  @moduledoc """
  Read/write the local CLI configuration.

  Config file: `~/.codefresh/config.json`
  Schema:

      {
        "api_url": "https://api.codefre.sh",
        "token":   "cf_...",
        "org":     "my-org",
        "email":   "user@example.com"
      }

  Environment variable overrides:
    * `CODEFRESH_API_URL`   overrides `api_url`
    * `CODEFRESH_API_TOKEN` overrides `token`
    * `CODEFRESH_ORG`       overrides `org`
  """

  @dir_name ".codefresh"
  @file_name "config.json"
  @default_url "https://api.codefre.sh"

  @type t :: %{
          optional(:api_url) => String.t(),
          optional(:token) => String.t(),
          optional(:org) => String.t(),
          optional(:email) => String.t()
        }

  @doc "Returns the absolute path to the config file."
  @spec path() :: String.t()
  def path do
    Path.join([home_dir(), @dir_name, @file_name])
  end

  @doc "Returns the config dir (honours `CODEFRESH_HOME` for tests)."
  @spec dir() :: String.t()
  def dir do
    Path.join(home_dir(), @dir_name)
  end

  defp home_dir do
    System.get_env("CODEFRESH_HOME") || System.user_home() || "."
  end

  @doc """
  Load config from disk and merge environment overrides on top.
  Returns `{:ok, map}` even when the file does not exist (empty map plus env).
  """
  @spec load() :: {:ok, map()}
  def load do
    disk = load_disk()

    cfg =
      disk
      |> maybe_put(:api_url, System.get_env("CODEFRESH_API_URL"))
      |> maybe_put(:token, System.get_env("CODEFRESH_API_TOKEN"))
      |> maybe_put(:org, System.get_env("CODEFRESH_ORG"))
      |> Map.put_new(:api_url, @default_url)

    {:ok, cfg}
  end

  defp load_disk do
    case File.read(path()) do
      {:ok, body} ->
        case Jason.decode(body) do
          {:ok, map} -> atomize(map)
          {:error, _} -> %{}
        end

      {:error, _} ->
        %{}
    end
  end

  defp atomize(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {String.to_atom(to_string(k)), v} end)
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, _key, ""), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  @doc """
  Save config to disk with `0600` perms. Overwrites atomically.
  """
  @spec save(map()) :: :ok | {:error, String.t()}
  def save(cfg) when is_map(cfg) do
    with :ok <- File.mkdir_p(dir()),
         serialisable <- Map.new(cfg, fn {k, v} -> {to_string(k), v} end),
         {:ok, body} <- Jason.encode(serialisable, pretty: true),
         :ok <- File.write(path(), body) do
      _ = File.chmod(path(), 0o600)
      _ = File.chmod(dir(), 0o700)
      :ok
    else
      {:error, reason} -> {:error, "failed to save config: #{inspect(reason)}"}
    end
  end

  @doc "Delete the on-disk config file."
  @spec delete() :: :ok
  def delete do
    _ = File.rm(path())
    :ok
  end

  @doc """
  Require a token or return `{:error, :auth, msg}`. Checks env var first,
  then disk-backed config.
  """
  @spec require_token(map()) :: {:ok, String.t()} | {:error, :auth, String.t()}
  def require_token(cfg) do
    case Map.get(cfg, :token) do
      nil ->
        {:error, :auth, "not logged in — run `codefresh login` or set CODEFRESH_API_TOKEN"}

      "" ->
        {:error, :auth, "empty token — re-run `codefresh login`"}

      token ->
        {:ok, token}
    end
  end

  @doc "Require an org slug or return a user-error tuple."
  @spec require_org(map(), keyword()) :: {:ok, String.t()} | {:error, :user, String.t()}
  def require_org(cfg, opts \\ []) do
    from_opts = Keyword.get(opts, :org)

    case from_opts || Map.get(cfg, :org) do
      nil ->
        {:error, :user, "missing org — pass `--org <slug>` or run `codefresh login --org <slug>`"}

      "" ->
        {:error, :user, "empty org — pass `--org <slug>`"}

      org ->
        {:ok, org}
    end
  end
end
