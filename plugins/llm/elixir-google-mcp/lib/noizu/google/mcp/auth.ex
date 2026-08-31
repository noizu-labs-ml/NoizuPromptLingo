defmodule Noizu.Google.MCP.Auth do
  @moduledoc """
  Resolve a `Noizu.Google.Client` from process env / application config
  and map SDK results to MCP tool return values.
  """

  alias Noizu.Google.Client
  alias Noizu.Google.Error

  @doc """
  Build a client with a usable access token from env / app config.

  Resolution (via `Client.ensure_access_token/1`):

  1. `GOOGLE_ACCESS_TOKEN` / `GOOGLE_MARKETING_ACCESS_TOKEN`
  2. Service-account JSON (`GOOGLE_APPLICATION_CREDENTIALS` or aliases,
     or inline `GOOGLE_SERVICE_ACCOUNT_JSON`)
  3. OAuth refresh trio (`GOOGLE_REFRESH_TOKEN` + client id/secret)
  """
  @spec client() :: {:ok, Client.t()} | {:error, String.t()}
  def client do
    with {:ok, service_account} <- inline_service_account() do
      base =
        Client.new(
          access_token: env("GOOGLE_ACCESS_TOKEN") || env("GOOGLE_MARKETING_ACCESS_TOKEN"),
          refresh_token: env("GOOGLE_REFRESH_TOKEN") || env("GOOGLE_MARKETING_REFRESH_TOKEN"),
          client_id: env("GOOGLE_CLIENT_ID") || env("GOOGLE_MARKETING_CLIENT_ID"),
          client_secret: env("GOOGLE_CLIENT_SECRET") || env("GOOGLE_MARKETING_CLIENT_SECRET"),
          credentials_file: credentials_file(),
          service_account: service_account,
          subject: env("GOOGLE_SUBJECT") || env("GOOGLE_IMPERSONATE"),
          scopes: env("GOOGLE_SCOPES") || env("GOOGLE_SERVICE_ACCOUNT_SCOPES")
        )

      case Client.ensure_access_token(base) do
        {:ok, client} -> {:ok, client}
        {:error, %Error{} = err} -> {:error, format_error(err)}
      end
    end
  end

  defp credentials_file do
    env("GOOGLE_APPLICATION_CREDENTIALS") ||
      env("GOOGLE_CREDENTIALS_FILE") ||
      env("GOOGLE_SERVICE_ACCOUNT_FILE")
  end

  defp inline_service_account do
    case env("GOOGLE_SERVICE_ACCOUNT_JSON") do
      nil ->
        {:ok, nil}

      raw ->
        case Jason.decode(raw) do
          {:ok, map} when is_map(map) ->
            {:ok, map}

          {:ok, _} ->
            {:error, "GOOGLE_SERVICE_ACCOUNT_JSON must be a JSON object"}

          {:error, _} ->
            {:error, "GOOGLE_SERVICE_ACCOUNT_JSON is not valid JSON"}
        end
    end
  end

  @doc "Map Google SDK result to MCP tool result."
  @spec wrap(term()) :: {:ok, term()} | {:error, String.t()}
  def wrap({:ok, value}), do: {:ok, value}

  def wrap({:error, %Error{} = err}), do: {:error, format_error(err)}
  def wrap({:error, reason}), do: {:error, inspect(reason)}

  def format_error(%Error{tag: tag, message: message, body: body}) do
    base = "[#{tag}] #{message || "error"}"

    case body do
      nil -> base
      b -> base <> " " <> inspect(b)
    end
  end

  defp env(name) do
    case System.get_env(name) do
      nil -> nil
      "" -> nil
      v -> v
    end
  end
end
