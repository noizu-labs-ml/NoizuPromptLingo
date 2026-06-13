defmodule CodefreshCli.Args do
  @moduledoc """
  Minimal argument parser wrapping `OptionParser.parse/2`. Returns a
  `{positional, flags}` tuple. All recognised switches are declared per
  command module so unknowns become errors rather than positionals.
  """

  @doc """
  Parse `argv` against a switches keyword list (same shape as
  `OptionParser.parse/2`'s `:switches`). Returns
  `{:ok, positional, flags}` or `{:error, :user, msg}`.

      switches = [agent: :string, persona: :string, out: :string,
                  threshold: :float, fail_on_warn: :boolean, format: :string,
                  org: :string, status: :string, token: :string]
  """
  @spec parse(list(String.t()), keyword()) ::
          {:ok, list(String.t()), keyword()} | {:error, :user, String.t()}
  def parse(argv, switches) do
    case OptionParser.parse(argv, strict: switches, aliases: aliases(switches)) do
      {parsed, positional, []} ->
        {:ok, positional, parsed}

      {_parsed, _positional, invalid} ->
        msg =
          invalid
          |> Enum.map(fn
            {flag, nil} -> flag
            {flag, val} -> "#{flag}=#{val}"
          end)
          |> Enum.join(", ")

        {:error, :user, "invalid flag(s): #{msg}"}
    end
  end

  defp aliases(switches) do
    Enum.flat_map(switches, fn
      {:out, _} -> [o: :out]
      {:org, _} -> [g: :org]
      {:agent, _} -> [a: :agent]
      {:persona, _} -> [p: :persona]
      {:token, _} -> [t: :token]
      _ -> []
    end)
  end
end
