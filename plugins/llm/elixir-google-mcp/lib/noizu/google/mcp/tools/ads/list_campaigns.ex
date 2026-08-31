defmodule Noizu.Google.MCP.Tools.Ads.ListCampaigns do
  @moduledoc "List Google Ads campaigns (read-only GAQL)."

  use Noizu.MCP.Server.Tool,
    name: "Ads.ListCampaigns",
    description:
      "List Google Ads campaigns (read-only GAQL). Requires GOOGLE_ADS_DEVELOPER_TOKEN.",
    annotations: [read_only_hint: true]

  input do
    field(:customer_id, :string,
      required: true,
      description: "Google Ads customer id (digits; dashes optional)"
    )

    field(:limit, :integer, description: "Max campaigns (default 50)")

    field(:developer_token, :string,
      description: "Override developer token (else GOOGLE_ADS_DEVELOPER_TOKEN)"
    )

    field(:login_customer_id, :string, description: "MCC login customer id if needed")
  end

  @impl true
  def call(args, _ctx) do
    opts =
      [client: nil]
      |> then(fn _ ->
        base = []

        base =
          if args[:developer_token],
            do: Keyword.put(base, :developer_token, args.developer_token),
            else: base

        base =
          if args[:login_customer_id],
            do: Keyword.put(base, :login_customer_id, args.login_customer_id),
            else: base

        base =
          if args[:limit], do: Keyword.put(base, :limit, args.limit), else: base

        base
      end)

    with {:ok, client} <- Noizu.Google.MCP.Auth.client() do
      Noizu.Google.Api.Ads.Customers.list_campaigns(
        args.customer_id,
        Keyword.put(opts, :client, client)
      )
      |> Noizu.Google.MCP.Auth.wrap()
    end
  end
end
