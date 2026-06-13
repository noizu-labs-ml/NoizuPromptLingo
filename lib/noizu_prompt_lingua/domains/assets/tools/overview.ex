defmodule NoizuPromptLingua.Domains.Assets.Tools.Overview do
  use Noizu.MCP.Server.Tool, name: "Asset.Overview",
    description: "List asset tools, counts by type and status.",
    annotations: [read_only_hint: true], category: "Assets"

  input do
  end

  alias NoizuPromptLingua.Domains.Assets

  @impl true
  def call(_args, _ctx) do
    {:ok, %{domain: "Assets", subdomain: "assets.tobor.locker",
      counts_by_type: Assets.count_by_type(), counts_by_status: Assets.count_by_status(),
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
