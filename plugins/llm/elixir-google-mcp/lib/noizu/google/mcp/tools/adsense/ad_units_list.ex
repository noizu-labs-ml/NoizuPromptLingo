defmodule Noizu.Google.MCP.Tools.AdSense.AdUnitsList do
  @moduledoc "List AdSense ad units under an ad client."

  use Noizu.MCP.Server.Tool,
    name: "AdSense.AdUnitsList",
    description: "List AdSense ad units. parent is accounts/{account}/adclients/{adClient}.",
    annotations: [read_only_hint: true]

  input do
    field(:parent, :string,
      required: true,
      description: "Ad client resource name (accounts/…/adclients/…)"
    )
  end

  @impl true
  def call(%{parent: parent}, _ctx) do
    with {:ok, client} <- Noizu.Google.MCP.Auth.client() do
      Noizu.Google.Api.AdSense.AdUnits.list(parent, client: client)
      |> Noizu.Google.MCP.Auth.wrap()
    end
  end
end
