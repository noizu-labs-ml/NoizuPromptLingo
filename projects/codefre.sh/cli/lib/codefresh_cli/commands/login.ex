defmodule CodefreshCli.Commands.Login do
  @moduledoc """
  `codefresh login` — prompts for API base URL, token, and default org,
  then writes them to `~/.codefresh/config.json` with `0600` perms.

  Non-interactive form: `codefresh login --url <u> --token <t> [--org <o>]`.
  """

  alias CodefreshCli.{Args, Client, Config}

  @spec run(list(String.t())) :: :ok | {:error, atom, String.t()}
  def run(args) do
    switches = [url: :string, token: :string, org: :string, email: :string]

    with {:ok, _pos, flags} <- Args.parse(args, switches),
         {:ok, cfg_on_disk} <- Config.load(),
         {:ok, cfg} <- gather(cfg_on_disk, flags),
         :ok <- verify(cfg),
         :ok <- Config.save(cfg) do
      IO.puts(CodefreshCli.color(:green, "saved credentials to #{Config.path()}"))
      :ok
    end
  end

  defp gather(cfg, flags) do
    url =
      flags[:url] || prompt("API URL", Map.get(cfg, :api_url, "https://api.codefre.sh"))

    token = flags[:token] || prompt_secret("API token")

    org = flags[:org] || prompt("Default org slug (blank for none)", Map.get(cfg, :org, ""))

    email = flags[:email] || Map.get(cfg, :email)

    out =
      %{api_url: url, token: token, email: email}
      |> maybe_put(:org, blank_nil(org))
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Map.new()

    {:ok, out}
  end

  defp blank_nil(""), do: nil
  defp blank_nil(nil), do: nil
  defp blank_nil(v), do: v

  defp maybe_put(map, _k, nil), do: map
  defp maybe_put(map, k, v), do: Map.put(map, k, v)

  defp verify(cfg) do
    case Client.get(cfg, "/api/v1/auth/me") do
      {:ok, %{"data" => %{"email" => email}}} when is_binary(email) ->
        IO.puts(CodefreshCli.color(:cyan, "logged in as #{email}"))
        :ok

      {:ok, %{"email" => email}} when is_binary(email) ->
        IO.puts(CodefreshCli.color(:cyan, "logged in as #{email}"))
        :ok

      {:ok, _} ->
        :ok

      {:error, :auth, msg} ->
        {:error, :auth, msg}

      {:error, :api, msg} ->
        {:error, :api, "could not verify token: #{msg}"}
    end
  end

  defp prompt(label, default) do
    suffix = if default in [nil, ""], do: "", else: " [#{default}]"

    case IO.gets("#{label}#{suffix}: ") do
      :eof ->
        default || ""

      {:error, _} ->
        default || ""

      input ->
        trimmed = input |> to_string() |> String.trim()
        if trimmed == "", do: default || "", else: trimmed
    end
  end

  defp prompt_secret(label) do
    # escripts don't have a reliable cross-platform way to disable echo;
    # document that tokens are briefly visible and nudge users toward
    # CODEFRESH_API_TOKEN or --token for CI.
    case IO.gets("#{label}: ") do
      :eof -> ""
      {:error, _} -> ""
      input -> input |> to_string() |> String.trim()
    end
  end
end
