defmodule CodefreshCli.Commands.Logout do
  @moduledoc "Purges the on-disk config."

  alias CodefreshCli.Config

  @spec run(list(String.t())) :: :ok
  def run(_args) do
    Config.delete()
    IO.puts(CodefreshCli.color(:green, "logged out — removed #{Config.path()}"))
    :ok
  end
end
