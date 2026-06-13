defmodule CodefreshCli.Commands.Import do
  @moduledoc """
  `codefresh import <file.yaml> [--org <slug>]`

  Reads a local YAML file and POSTs it to
  `POST /api/v1/organizations/:org/scripts/import`.
  """

  alias CodefreshCli.{Args, Client, Config}

  @spec run(list(String.t())) :: :ok | {:error, atom, String.t()}
  def run(args) do
    switches = [org: :string, token: :string]

    with {:ok, positional, flags} <- Args.parse(args, switches),
         {:ok, file} <- first(positional, "missing YAML file path"),
         {:ok, cfg} <- Config.load(),
         cfg <- maybe_override_token(cfg, flags),
         {:ok, _} <- Config.require_token(cfg),
         {:ok, org} <- Config.require_org(cfg, Keyword.take(flags, [:org])),
         {:ok, yaml} <- read_file(file),
         {:ok, _parsed} <- validate_yaml(yaml),
         {:ok, body} <-
           Client.post_raw(
             cfg,
             "/api/v1/organizations/#{org}/scripts/import",
             yaml,
             "application/x-yaml"
           ) do
      slug = get_in_body(body, ["data", "slug"]) || get_in_body(body, ["slug"]) || "<unknown>"
      version = get_in_body(body, ["data", "version"]) || get_in_body(body, ["version"])

      label =
        if version, do: "#{slug}@#{version}", else: slug

      IO.puts(CodefreshCli.color(:green, "imported: ") <> label)
      :ok
    end
  end

  defp first([], msg), do: {:error, :user, msg}
  defp first([h | _], _), do: {:ok, h}

  defp maybe_override_token(cfg, flags) do
    case flags[:token] do
      nil -> cfg
      "" -> cfg
      t -> Map.put(cfg, :token, t)
    end
  end

  defp read_file(path) do
    case File.read(path) do
      {:ok, contents} -> {:ok, contents}
      {:error, :enoent} -> {:error, :user, "file not found: #{path}"}
      {:error, reason} -> {:error, :user, "cannot read #{path}: #{inspect(reason)}"}
    end
  end

  defp validate_yaml(body) do
    case YamlElixir.read_from_string(body) do
      {:ok, parsed} -> {:ok, parsed}
      {:error, %{message: msg}} -> {:error, :user, "invalid YAML: #{msg}"}
      {:error, reason} -> {:error, :user, "invalid YAML: #{inspect(reason)}"}
    end
  end

  defp get_in_body(body, path) when is_map(body), do: get_in_path(body, path)
  defp get_in_body(_, _), do: nil

  defp get_in_path(map, []), do: map

  defp get_in_path(map, [h | t]) when is_map(map) do
    case Map.get(map, h) do
      nil -> nil
      v -> get_in_path(v, t)
    end
  end

  defp get_in_path(_, _), do: nil
end
