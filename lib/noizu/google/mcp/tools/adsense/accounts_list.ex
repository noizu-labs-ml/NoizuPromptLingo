defmodule Noizu.Google.MCP.Tools.AdSense.AccountsList do
  @moduledoc "List AdSense publisher accounts for the authenticated user."

  use Noizu.MCP.Server.Tool,
    name: "AdSense.AccountsList",
    description: "List AdSense publisher accounts for the authenticated user.",
    annotations: [read_only_hint: true]

  @impl true
  def call(_args, _ctx) do
    with {:ok, client} <- Noizu.Google.MCP.Auth.client() do
      Noizu.Google.Api.AdSense.Accounts.list(client: client)
      |> Noizu.Google.MCP.Auth.wrap()
    end
  end
end
