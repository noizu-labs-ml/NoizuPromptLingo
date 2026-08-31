defmodule ExLiteLLM.CLI do
  @moduledoc """
  `ex-litellm` command-line entry — the drop-in replacement for the `litellm`
  binary that run-claude launches.

  Accepts the same core flags:

      ex-litellm --host 127.0.0.1 --port 4444 --config /path/config.yaml

  The single `--port` runs the unified gateway (LiteLLM surface + folded-in
  front-proxy routing); there is no separate front-proxy port.

  Environment honored (like litellm): `LITELLM_MASTER_KEY`,
  `LITELLM_DATABASE_URL`, `STORE_MODEL_IN_DB`, `USE_PRISMA_MIGRATE` (accepted and
  ignored — ex-litellm uses Ecto, not Prisma).

  Resolution order: CLI flags → env vars → compiled defaults
  (`ExLiteLLM.Runtime`). The resolved settings are stashed in
  `:persistent_term`, the config file (if any) is loaded, then the OTP app is
  started, which brings up the listeners.
  """

  @switches [
    host: :string,
    port: :integer,
    config: :string,
    help: :boolean
  ]

  @aliases [h: :help, p: :port, c: :config]

  @spec main([String.t()]) :: no_return()
  def main(argv) do
    {opts, _rest, invalid} = OptionParser.parse(argv, switches: @switches, aliases: @aliases)

    cond do
      opts[:help] ->
        print_usage()
        System.halt(0)

      invalid != [] ->
        IO.puts(:stderr, "ex-litellm: invalid options: #{inspect(invalid)}")
        print_usage()
        System.halt(2)

      true ->
        boot(opts)
    end
  end

  defp boot(opts) do
    settings = ExLiteLLM.Runtime.resolve(opts)
    ExLiteLLM.Runtime.put(settings)

    # Export the config path so the OTP app loads it during start/2 (before the
    # Router seeds) — the same code path a headless release takes.
    if settings.config_path, do: System.put_env("CONFIG_FILE_PATH", settings.config_path)

    case Application.ensure_all_started(:ex_litellm) do
      {:ok, _} ->
        IO.puts(:stderr, banner(settings))
        # Block forever so the servers keep running.
        Process.sleep(:infinity)

      {:error, reason} ->
        IO.puts(:stderr, "ex-litellm: startup failed: #{inspect(reason)}")
        System.halt(1)
    end
  end

  defp banner(settings) do
    """
    [ex-litellm] gateway: #{settings.host}:#{settings.port}
    [ex-litellm] config: #{settings.config_path || "(none — env/defaults)"}
    [ex-litellm] db: #{db_desc(settings)}
    """
  end

  defp db_desc(%{database_url: nil}), do: "sqlite (default path)"
  defp db_desc(%{database_url: url}), do: redact(url)

  defp redact(url) do
    Regex.replace(~r{://([^:/@]+):([^@]+)@}, url, "://\\1:****@")
  end

  defp print_usage do
    IO.puts("""
    ex-litellm — Elixir LiteLLM proxy (drop-in for the `litellm` binary)

    USAGE:
      ex-litellm [--host HOST] [--port PORT] [--config FILE]

    OPTIONS:
      -h, --help           Show this help
      --host HOST          Bind address (default 127.0.0.1)
      -p, --port PORT      Unified gateway port (default 4445 dev / 4443 prod)
      -c, --config FILE    Path to litellm-style config.yaml

    ENV:
      LITELLM_MASTER_KEY     Master key for admin/auth
      LITELLM_DATABASE_URL   postgres://… or sqlite path (default: local SQLite)
      STORE_MODEL_IN_DB      true|false (default true)
    """)
  end
end
