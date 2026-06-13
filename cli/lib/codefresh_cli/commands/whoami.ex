defmodule CodefreshCli.Commands.Whoami do
  @moduledoc "Prints the authenticated user's email + default org."

  alias CodefreshCli.{Client, Config}

  @spec run(list(String.t())) :: :ok | {:error, atom, String.t()}
  def run(_args) do
    with {:ok, cfg} <- Config.load(),
         {:ok, _token} <- Config.require_token(cfg),
         {:ok, body} <- Client.get(cfg, "/api/v1/auth/me") do
      email = extract(body, ["data", "email"]) || extract(body, ["email"]) || "unknown"

      IO.puts("email: #{email}")
      IO.puts("api:   #{cfg[:api_url]}")
      if cfg[:org], do: IO.puts("org:   #{cfg[:org]}")

      :ok
    end
  end

  defp extract(map, path) when is_map(map) do
    Enum.reduce_while(path, map, fn k, acc ->
      case acc do
        %{} -> {:cont, Map.get(acc, k)}
        _ -> {:halt, nil}
      end
    end)
    |> case do
      nil -> nil
      v when is_binary(v) -> v
      _ -> nil
    end
  end

  defp extract(_, _), do: nil
end
