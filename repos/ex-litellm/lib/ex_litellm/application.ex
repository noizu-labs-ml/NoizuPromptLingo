defmodule ExLiteLLM.Application do
  @moduledoc """
  ex-litellm OTP application.

  Supervision tree:

    * `ExLiteLLM.Schema.Repo` — Ecto repo (SQLite default)
    * `ExLiteLLM.Router.CooldownCache` + `ExLiteLLM.Router` — deployment registry
    * `ExLiteLLM.FrontProxy.Rules` — runtime-alterable routing rules
    * Bandit listener for the unified `ExLiteLLM.Gateway`

  Config is loaded (from `--config` / `CONFIG_FILE_PATH`) before the Router
  seeds from it. The HTTP listener is skipped when `:start_servers` is false
  (unit tests) so the app can boot without binding a port.
  """

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    settings = ensure_settings()
    load_config(settings)

    children =
      [
        repo_child(settings),
        # Apply pending Ecto migrations before anything queries. Skipped in
        # tests (in-memory SQLite is per-connection; the sandbox can't share a
        # schema_migrations table across pool members).
        {Ecto.Migrator,
         repos: [ExLiteLLM.Schema.Repo],
         skip: Application.get_env(:ex_litellm, :auto_migrate, true) == false},
        # Shared outbound HTTP pool (stale keep-alive culling — see ExLiteLLM.HTTP).
        ExLiteLLM.HTTP.finch_spec(),
        # Async request logger (timing/size/errors → request_logs table).
        ExLiteLLM.RequestLog,
        # Cooldown ETS must exist before the Router seeds/selects.
        ExLiteLLM.Router.CooldownCache,
        ExLiteLLM.Router,
        # Front-proxy rule table (seeded from config front_proxy.mode).
        ExLiteLLM.FrontProxy.Rules
      ] ++ server_children(settings)

    opts = [strategy: :one_for_one, name: ExLiteLLM.Supervisor]

    with {:ok, pid} <- Supervisor.start_link(List.flatten(children), opts) do
      log_boot(settings)
      {:ok, pid}
    end
  end

  # --- startup ---

  # Use CLI-resolved settings if present (persistent_term), else build from
  # env + app-env. Either way the result is stored so the whole node reads one
  # snapshot.
  defp ensure_settings do
    settings = ExLiteLLM.Runtime.get()
    ExLiteLLM.Runtime.put(settings)
    settings
  end

  # Load the config file (if any) BEFORE the Router seeds from it. Honors both a
  # CLI-passed --config and the CONFIG_FILE_PATH env var (litellm convention).
  defp load_config(%{config_path: nil}), do: :ok

  defp load_config(%{config_path: path}) do
    case ExLiteLLM.Config.Loader.load_file(path) do
      {:ok, config} ->
        ExLiteLLM.Config.put(config)

      {:error, reason} ->
        Logger.error("[ex-litellm] failed to load config #{path}: #{inspect(reason)}")
    end

    :ok
  end

  # --- children ---

  defp repo_child(settings) do
    # Point the repo at the resolved DB path/URL before it starts.
    ExLiteLLM.Schema.Repo.Config.apply(settings)
    ExLiteLLM.Schema.Repo
  end

  defp server_children(settings) do
    if start_servers?() do
      [gateway_listener(settings)]
    else
      []
    end
  end

  # One unified listener: the gateway serves the LiteLLM surface AND the folded-in
  # front-proxy routing on a single port.
  defp gateway_listener(settings) do
    {Bandit,
     plug: ExLiteLLM.Gateway,
     scheme: :http,
     ip: parse_ip(settings.host),
     port: settings.port,
     # Never compress responses. Bandit's default HTTP compression honors the
     # client's Accept-Encoding (zstd/br/gzip) — but Claude Code advertises
     # zstd and then fails to decode it, rendering raw bytes as garbled
     # "API Error: 400 <binary>". The Python proxy never compressed; match it.
     http_options: [compress: false]}
    |> Supervisor.child_spec(id: :gateway_listener)
  end

  # --- helpers ---

  defp start_servers?, do: Application.get_env(:ex_litellm, :start_servers, true)

  defp parse_ip(host) do
    case host |> to_charlist() |> :inet.parse_address() do
      {:ok, ip} -> ip
      {:error, _} -> {127, 0, 0, 1}
    end
  end

  defp log_boot(settings) do
    if start_servers?() do
      Logger.info("[ex-litellm] gateway listening on #{settings.host}:#{settings.port}")
    end
  end
end
