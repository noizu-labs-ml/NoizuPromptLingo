defmodule Noizu.Google.MCP.Tools.Ads.Mutate do
  @moduledoc "Google Ads mutate with dry_run default and confirm for live applies."

  use Noizu.MCP.Server.Tool,
    name: "Ads.Mutate",
    description: """
    Apply Google Ads mutateOperations. Defaults to dry_run=true (validateOnly).
    Live applies require dry_run=false AND confirm=true.
    mutate_operations_json must be a JSON array of MutateOperation objects.
    """,
    annotations: [destructive_hint: true]

  input do
    field(:customer_id, :string, required: true, description: "Ads customer id")

    field(:mutate_operations_json, :string,
      required: true,
      description: "JSON array of mutateOperations"
    )

    field(:dry_run, :boolean, description: "If true (default), validateOnly — no changes applied")
    field(:confirm, :boolean, description: "Required true when dry_run=false")
    field(:developer_token, :string, description: "Override developer token")
    field(:login_customer_id, :string, description: "MCC login customer id")
  end

  @impl true
  def call(args, _ctx) do
    dry_run = Map.get(args, :dry_run, true)
    confirm = Map.get(args, :confirm, false)

    cond do
      dry_run == false and confirm != true ->
        {:error, "live mutate requires confirm=true (and dry_run=false)"}

      true ->
        with {:ok, ops} <- decode_ops(args.mutate_operations_json),
             {:ok, client} <- Noizu.Google.MCP.Auth.client() do
          opts =
            [
              client: client,
              dry_run: dry_run != false
            ]
            |> maybe(:developer_token, args[:developer_token])
            |> maybe(:login_customer_id, args[:login_customer_id])

          Noizu.Google.Api.Ads.Customers.mutate(
            args.customer_id,
            %{mutateOperations: ops},
            opts
          )
          |> Noizu.Google.MCP.Auth.wrap()
          |> tag_dry_run(dry_run != false)
        end
    end
  end

  defp decode_ops(json) when is_binary(json) do
    case Jason.decode(json) do
      {:ok, list} when is_list(list) -> {:ok, list}
      {:ok, _} -> {:error, "mutate_operations_json must be a JSON array"}
      {:error, err} -> {:error, "invalid JSON: #{Exception.message(err)}"}
    end
  end

  defp maybe(kw, _k, nil), do: kw
  defp maybe(kw, _k, ""), do: kw
  defp maybe(kw, k, v), do: Keyword.put(kw, k, v)

  defp tag_dry_run({:ok, result}, true), do: {:ok, %{validate_only: true, result: result}}
  defp tag_dry_run({:ok, result}, false), do: {:ok, %{validate_only: false, result: result}}
  defp tag_dry_run(other, _), do: other
end
