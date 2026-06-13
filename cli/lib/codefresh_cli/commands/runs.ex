defmodule CodefreshCli.Commands.Runs do
  @moduledoc """
  `codefresh runs list [--status pass|fail|warn|running] [--limit N]`

  Prints a simple table of recent runs from
  `GET /api/v1/organizations/:org/runs`.
  """

  alias CodefreshCli.{Args, Client, Config}

  @spec run(list(String.t())) :: :ok | {:error, atom, String.t()}
  def run(["list" | rest]), do: list(rest)

  def run([]) do
    {:error, :user, "usage: codefresh runs list [--status pass|fail|warn|running]"}
  end

  def run([other | _]) do
    {:error, :user, "unknown runs subcommand: #{other}"}
  end

  defp list(args) do
    switches = [status: :string, limit: :integer, org: :string, token: :string]

    with {:ok, _pos, flags} <- Args.parse(args, switches),
         {:ok, cfg} <- Config.load(),
         cfg <- maybe_override_token(cfg, flags),
         {:ok, _} <- Config.require_token(cfg),
         {:ok, org} <- Config.require_org(cfg, Keyword.take(flags, [:org])),
         path <- build_path(org, flags),
         {:ok, body} <- Client.get(cfg, path) do
      runs = body |> unwrap() |> List.wrap()
      print_table(runs)
      :ok
    end
  end

  defp maybe_override_token(cfg, flags) do
    case flags[:token] do
      nil -> cfg
      "" -> cfg
      t -> Map.put(cfg, :token, t)
    end
  end

  defp build_path(org, flags) do
    query =
      []
      |> maybe_add("status", flags[:status])
      |> maybe_add("limit", flags[:limit])
      |> Enum.map_join("&", fn {k, v} -> "#{k}=#{URI.encode_www_form(to_string(v))}" end)

    suffix = if query == "", do: "", else: "?" <> query
    "/api/v1/organizations/#{org}/runs" <> suffix
  end

  defp maybe_add(q, _k, nil), do: q
  defp maybe_add(q, _k, ""), do: q
  defp maybe_add(q, k, v), do: [{k, v} | q]

  defp unwrap(%{"data" => d}), do: d
  defp unwrap(other), do: other

  defp print_table([]) do
    IO.puts(CodefreshCli.color(:dim, "no runs"))
  end

  defp print_table(runs) do
    IO.puts(
      String.pad_trailing("ID", 38) <>
        String.pad_trailing("SCRIPT", 24) <>
        String.pad_trailing("AGENT", 20) <>
        String.pad_trailing("VERDICT", 10) <>
        "STARTED"
    )

    Enum.each(runs, fn r ->
      IO.puts(
        String.pad_trailing(to_string(r["id"] || "-"), 38) <>
          String.pad_trailing(to_string(r["script_slug"] || "-"), 24) <>
          String.pad_trailing(to_string(r["agent_slug"] || "-"), 20) <>
          String.pad_trailing(to_string(r["verdict"] || r["status"] || "-"), 10) <>
          to_string(r["started_at"] || r["inserted_at"] || "-")
      )
    end)
  end
end
