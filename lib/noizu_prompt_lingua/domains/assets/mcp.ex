defmodule NoizuPromptLingua.Domains.Assets.MCP do
  use Noizu.MCP.Server,
    name: "tobor_assets",
    version: "0.1.0",
    instructions: "Asset management domain — media prompt entries, generation, evaluation, and publishing."

  tool NoizuPromptLingua.Domains.Assets.Tools.Overview, category: "Assets"
  tool NoizuPromptLingua.Domains.Assets.Tools.AssetCreate, category: "Assets"
  tool NoizuPromptLingua.Domains.Assets.Tools.AssetGet, category: "Assets"
  tool NoizuPromptLingua.Domains.Assets.Tools.AssetUpdate, category: "Assets"
  tool NoizuPromptLingua.Domains.Assets.Tools.AssetList, category: "Assets"
  tool NoizuPromptLingua.Domains.Assets.Tools.AssetGenerate, category: "Assets"
  tool NoizuPromptLingua.Domains.Assets.Tools.AssetRegenerate, category: "Assets"
  tool NoizuPromptLingua.Domains.Assets.Tools.AssetSetActive, category: "Assets"
  tool NoizuPromptLingua.Domains.Assets.Tools.AssetPublish, category: "Assets"
  tool NoizuPromptLingua.Domains.Assets.Tools.AssetArchive, category: "Assets"
  tool NoizuPromptLingua.Domains.Assets.Tools.AssetOutputs, category: "Assets.Outputs"
  tool NoizuPromptLingua.Domains.Assets.Tools.AssetOutputAccept, category: "Assets.Outputs"
  tool NoizuPromptLingua.Domains.Assets.Tools.AssetOutputReject, category: "Assets.Outputs"
  tool NoizuPromptLingua.Domains.Assets.Tools.AssetRequestReview, category: "Assets.Review"
  tool NoizuPromptLingua.Domains.Assets.Tools.AssetHistory, category: "Assets"
  tool NoizuPromptLingua.Domains.Assets.Tools.AssetContentFormats, category: "Assets.Generation"
  tool NoizuPromptLingua.Domains.Assets.Tools.AssetContentReference, category: "Assets.Generation"

  tool NoizuPromptLingua.Tools.ToolSummary, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolSearch, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolCall, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolHelp, category: "Discovery"
end
