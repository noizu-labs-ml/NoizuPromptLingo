defmodule Noizu.Google.MCP.Tools.Ads.ListConversionActions do
  @moduledoc "List Google Ads conversion actions (read-only)."

  use Noizu.MCP.Server.Tool,
    name: "Ads.ListConversionActions",
    description: "List Google Ads conversion actions (read-only). Requires developer token.",
    annotations: [read_only_hint: true]

  input do
    field(:customer_id, :string, required: true, description: "Ads customer id")
    field(:developer_token, :string, description: "Override developer token")
    field(:login_customer_id, :string, description: "MCC login customer id")
  end

  @impl true
  def call(args, _ctx) do
    opts =
      []
      |> then(fn base ->
        base =
          if args[:developer_token],
            do: Keyword.put(base, :developer_token, args.developer_token),
            else: base

        if args[:login_customer_id],
          do: Keyword.put(base, :login_customer_id, args.login_customer_id),
          else: base
      end)

    with {:ok, client} <- Noizu.Google.MCP.Auth.client() do
      Noizu.Google.Api.Ads.Customers.list_conversion_actions(
        args.customer_id,
        Keyword.put(opts, :client, client)
      )
      |> Noizu.Google.MCP.Auth.wrap()
    end
  end
end
