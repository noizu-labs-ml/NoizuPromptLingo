defmodule CodefreshCli do
  @moduledoc """
  Entry point for the `codefresh` escript.

  Dispatches to command modules under `CodefreshCli.Commands.*`.
  """

  @version Mix.Project.config()[:version]

  alias CodefreshCli.Commands

  @commands %{
    "login" => Commands.Login,
    "logout" => Commands.Logout,
    "whoami" => Commands.Whoami,
    "import" => Commands.Import,
    "export" => Commands.Export,
    "run" => Commands.Run,
    "runs" => Commands.Runs
  }

  @exit_success 0
  @exit_user_error 1
  @exit_api_error 2
  @exit_auth_error 3

  @doc """
  escript main entry. Parses args, dispatches, calls `System.halt/1` with
  the computed exit code.
  """
  def main(argv) do
    code = run(argv)
    System.halt(code)
  end

  @doc """
  Pure dispatch that returns an integer exit code — useful for tests so
  they don't kill the VM.
  """
  @spec run(list(String.t())) :: integer()
  def run(argv) do
    case argv do
      [] ->
        print_usage()
        @exit_user_error

      [h] when h in ["--help", "-h", "help"] ->
        print_usage()
        @exit_success

      [h] when h in ["--version", "-v", "version"] ->
        IO.puts("codefresh #{@version}")
        @exit_success

      [cmd | rest] ->
        dispatch(cmd, rest)
    end
  end

  @doc false
  def dispatch(cmd, args) do
    case Map.fetch(@commands, cmd) do
      {:ok, mod} ->
        safe_run(mod, args)

      :error ->
        IO.puts(:stderr, color(:red, "unknown command: #{cmd}"))
        print_usage()
        @exit_user_error
    end
  end

  defp safe_run(mod, args) do
    try do
      case mod.run(args) do
        :ok -> @exit_success
        {:ok, _} -> @exit_success
        {:error, :user, msg} -> print_err(msg, @exit_user_error)
        {:error, :auth, msg} -> print_err(msg, @exit_auth_error)
        {:error, :api, msg} -> print_err(msg, @exit_api_error)
        {:error, msg} when is_binary(msg) -> print_err(msg, @exit_api_error)
        code when is_integer(code) -> code
      end
    rescue
      e ->
        IO.puts(:stderr, color(:red, "error: #{Exception.message(e)}"))
        @exit_api_error
    end
  end

  defp print_err(msg, code) do
    IO.puts(:stderr, color(:red, "error: ") <> msg)
    code
  end

  @doc false
  def print_usage do
    IO.puts("""
    codefresh #{@version} - command-line client for Codefresh

    Usage:
      codefresh <command> [options]

    Auth commands:
      login                Authenticate and store credentials locally
      logout               Purge stored credentials
      whoami               Show the authenticated user + org

    Script commands:
      import <file.yaml>   Import a script from a YAML file
      export <slug>@<ver>  Export a published script version to YAML
                           Use --out <path> to write to a file

    Run commands:
      run <script-slug>    Trigger a run and poll until it completes
                           --agent <agent-slug>  (required)
                           --persona <persona-slug>
                           --threshold <0-1>
                           --fail-on-warn
                           --format junit
                           --out <path>
      runs list            List recent runs (--status pass|fail|warn|running)

    Global options:
      --help, -h           Show help
      --version, -v        Show version

    Environment variables:
      CODEFRESH_API_URL    Override stored API base URL
      CODEFRESH_API_TOKEN  Override stored API token (for CI)
      CODEFRESH_ORG        Override stored default org slug
      NO_COLOR             Disable ANSI colors

    Exit codes:
      0  success / PASS verdict
      1  user error (missing file, bad args) / FAIL verdict
      2  API / network error / WARN verdict (unless --fail-on-warn)
      3  auth error (not logged in, token revoked)
    """)
  end

  @doc """
  Wraps a string with ANSI color if stdout is a tty and NO_COLOR is unset.
  """
  def color(color, str) when color in [:red, :green, :yellow, :cyan, :dim] do
    if color_enabled?() do
      code =
        case color do
          :red -> IO.ANSI.red()
          :green -> IO.ANSI.green()
          :yellow -> IO.ANSI.yellow()
          :cyan -> IO.ANSI.cyan()
          :dim -> IO.ANSI.light_black()
        end

      code <> str <> IO.ANSI.reset()
    else
      str
    end
  end

  defp color_enabled? do
    System.get_env("NO_COLOR") in [nil, ""] and IO.ANSI.enabled?()
  end
end
