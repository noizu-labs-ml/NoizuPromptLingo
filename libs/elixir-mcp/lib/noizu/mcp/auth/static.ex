defmodule Noizu.MCP.Auth.Static do
  @moduledoc """
  Fixed bearer-token auth strategy: `{Noizu.MCP.Auth.Static, token: "..."}`.
  A 401 is terminal — there is nothing to refresh.
  """

  @behaviour Noizu.MCP.Auth.ClientStrategy

  @impl true
  def init(opts) do
    case Keyword.fetch(opts, :token) do
      {:ok, token} when is_binary(token) -> {:ok, %{token: token}}
      _ -> {:error, :missing_token}
    end
  end

  @impl true
  def headers(state), do: {[{"authorization", "Bearer #{state.token}"}], state}

  @impl true
  def handle_unauthorized(_challenge, _info, state), do: {:error, :unauthorized, state}
end
