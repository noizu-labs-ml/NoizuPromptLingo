defmodule Noizu.Google.MCP.Tools.Ads.CreateConversionAction do
  @moduledoc "Create a Google Ads conversion action (dry_run default)."

  use Noizu.MCP.Server.Tool,
    name: "Ads.CreateConversionAction",
    description: """
    Create a Google Ads conversion action. Defaults to dry_run=true.
    Live create requires dry_run=false and confirm=true.
    """,
    annotations: [destructive_hint: true]

  input do
    field(:customer_id, :string, required: true)
    field(:name, :string, required: true, description: "Conversion action name")
    field(:type, :string, description: "Default WEBPAGE")
    field(:category, :string, description: "Default DEFAULT")
    field(:status, :string, description: "Default ENABLED")
    field(:dry_run, :boolean, description: "Default true (validateOnly)")
    field(:confirm, :boolean, description: "Required for live create")
    field(:developer_token, :string)
    field(:login_customer_id, :string)
  end

  @impl true
  def call(args, _ctx) do
    dry_run = Map.get(args, :dry_run, true)
    confirm = Map.get(args, :confirm, false)

    if dry_run == false and confirm != true do
      {:error, "live create requires confirm=true (and dry_run=false)"}
    else
      with {:ok, client} <- Noizu.Google.MCP.Auth.client() do
        opts =
          [
            client: client,
            name: args.name,
            dry_run: dry_run != false
          ]
          |> maybe(:type, args[:type])
          |> maybe(:category, args[:category])
          |> maybe(:status, args[:status])
          |> maybe(:developer_token, args[:developer_token])
          |> maybe(:login_customer_id, args[:login_customer_id])

        Noizu.Google.Api.Ads.Customers.create_conversion_action(args.customer_id, opts)
        |> Noizu.Google.MCP.Auth.wrap()
        |> then(fn
          {:ok, result} -> {:ok, %{validate_only: dry_run != false, result: result}}
          other -> other
        end)
      end
    end
  end

  defp maybe(kw, _k, nil), do: kw
  defp maybe(kw, _k, ""), do: kw
  defp maybe(kw, k, v), do: Keyword.put(kw, k, v)
end
