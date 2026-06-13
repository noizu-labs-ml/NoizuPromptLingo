defmodule CodefreshCli.Commands.Export do
  @moduledoc """
  `codefresh export <script-slug>[@<version>] [--out <file>] [--org <slug>]`

  GETs `/api/v1/organizations/:org/scripts/:slug/export` and writes the
  response body to `--out <file>` or stdout.
  """

  alias CodefreshCli.{Args, Client, Config}

  @spec run(list(String.t())) :: :ok | {:error, atom, String.t()}
  def run(args) do
    switches = [org: :string, out: :string, token: :string]

    with {:ok, positional, flags} <- Args.parse(args, switches),
         {:ok, ref} <- first(positional, "missing script reference (slug or slug@version)"),
         {slug, version} <- parse_ref(ref),
         {:ok, cfg} <- Config.load(),
         cfg <- maybe_override_token(cfg, flags),
         {:ok, _} <- Config.require_token(cfg),
         {:ok, org} <- Config.require_org(cfg, Keyword.take(flags, [:org])),
         path <- build_path(org, slug, version),
         {:ok, body} <- Client.get_raw(cfg, path) do
      write_output(body, flags[:out])
    end
  end

  defp first([], msg), do: {:error, :user, msg}
  defp first([h | _], _), do: {:ok, h}

  defp parse_ref(ref) do
    case String.split(ref, "@", parts: 2) do
      [slug, ver] -> {slug, ver}
      [slug] -> {slug, nil}
    end
  end

  defp build_path(org, slug, nil),
    do: "/api/v1/organizations/#{org}/scripts/#{slug}/export"

  defp build_path(org, slug, version),
    do: "/api/v1/organizations/#{org}/scripts/#{slug}/export?version=#{version}"

  defp maybe_override_token(cfg, flags) do
    case flags[:token] do
      nil -> cfg
      "" -> cfg
      t -> Map.put(cfg, :token, t)
    end
  end

  defp write_output(body, nil) do
    IO.write(body)
    :ok
  end

  defp write_output(body, path) do
    case File.write(path, body) do
      :ok ->
        IO.puts(CodefreshCli.color(:green, "wrote ") <> path)
        :ok

      {:error, reason} ->
        {:error, :user, "failed to write #{path}: #{inspect(reason)}"}
    end
  end
end
