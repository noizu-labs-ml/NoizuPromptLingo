defmodule NoizuPromptLingua.Domains.Assets.Tools.Overview do
  use Noizu.MCP.Server.Tool, name: "Asset.Overview",
    description: "List asset tools, counts by type and status.",
    annotations: [read_only_hint: true], category: "Assets"

  input do
    field :organization, :string, description: "Organization slug or UUID — scopes the counts"
  end

  alias NoizuPromptLingua.Domains.Assets
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    {by_type, by_status} =
      case Resolve.organization_id(Args.get(args, :organization)) do
        nil -> {%{}, %{}}
        org_id -> {Assets.count_by_type(org_id), Assets.count_by_status(org_id)}
      end

    {:ok, %{domain: "Assets", subdomain: "assets.tobor.locker",
      counts_by_type: by_type, counts_by_status: by_status,
      asset_types: NoizuPromptLingua.Schema.AssetEntry.asset_types(),
      tools: %{
        crud: ~w(Asset.Create Asset.Get Asset.Update Asset.List Asset.Publish Asset.Archive),
        generation: ~w(Asset.Generate Asset.Regenerate Asset.SetActive),
        outputs: ~w(Asset.Outputs Asset.Output.Accept Asset.Output.Reject),
        review: ~w(Asset.RequestReview),
        audit: ~w(Asset.History)
      }}}
  end
end
