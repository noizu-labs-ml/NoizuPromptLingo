defmodule NoizuPromptLingua.Domains.Campaigns.MCP do
  use NoizuPromptLingua.MCP.Server,
    name: "tobor_campaigns",
    version: "0.1.0",
    instructions:
      "Campaigns domain — marketing/SEO/PPC campaigns, ad groups, ad copy (LLM-generated), landing pages (LLM-generated), and domain names."

  tool(NoizuPromptLingua.Domains.Campaigns.Tools.Overview, category: "Campaigns")

  tool(NoizuPromptLingua.Domains.Campaigns.Tools.CampaignCreate, category: "Campaigns")
  tool(NoizuPromptLingua.Domains.Campaigns.Tools.CampaignGet, category: "Campaigns")
  tool(NoizuPromptLingua.Domains.Campaigns.Tools.CampaignUpdate, category: "Campaigns")
  tool(NoizuPromptLingua.Domains.Campaigns.Tools.CampaignList, category: "Campaigns")

  tool(NoizuPromptLingua.Domains.Campaigns.Tools.AdGroupCreate, category: "Campaigns.AdGroups")
  tool(NoizuPromptLingua.Domains.Campaigns.Tools.AdGroupGet, category: "Campaigns.AdGroups")
  tool(NoizuPromptLingua.Domains.Campaigns.Tools.AdGroupUpdate, category: "Campaigns.AdGroups")
  tool(NoizuPromptLingua.Domains.Campaigns.Tools.AdGroupList, category: "Campaigns.AdGroups")

  tool(NoizuPromptLingua.Domains.Campaigns.Tools.AdCopyCreate, category: "Campaigns.AdCopy")
  tool(NoizuPromptLingua.Domains.Campaigns.Tools.AdCopyGet, category: "Campaigns.AdCopy")
  tool(NoizuPromptLingua.Domains.Campaigns.Tools.AdCopyList, category: "Campaigns.AdCopy")
  tool(NoizuPromptLingua.Domains.Campaigns.Tools.AdCopyGenerate, category: "Campaigns.AdCopy")
  tool(NoizuPromptLingua.Domains.Campaigns.Tools.AdCopyApprove, category: "Campaigns.AdCopy")
  tool(NoizuPromptLingua.Domains.Campaigns.Tools.AdCopyReject, category: "Campaigns.AdCopy")

  tool(NoizuPromptLingua.Domains.Campaigns.Tools.LandingPageCreate,
    category: "Campaigns.LandingPages"
  )

  tool(NoizuPromptLingua.Domains.Campaigns.Tools.LandingPageGet,
    category: "Campaigns.LandingPages"
  )

  tool(NoizuPromptLingua.Domains.Campaigns.Tools.LandingPageUpdate,
    category: "Campaigns.LandingPages"
  )

  tool(NoizuPromptLingua.Domains.Campaigns.Tools.LandingPageList,
    category: "Campaigns.LandingPages"
  )

  tool(NoizuPromptLingua.Domains.Campaigns.Tools.LandingPageGenerate,
    category: "Campaigns.LandingPages"
  )

  tool(NoizuPromptLingua.Domains.Campaigns.Tools.DomainNameCreate, category: "Campaigns.Domains")
  tool(NoizuPromptLingua.Domains.Campaigns.Tools.DomainNameGet, category: "Campaigns.Domains")
  tool(NoizuPromptLingua.Domains.Campaigns.Tools.DomainNameUpdate, category: "Campaigns.Domains")
  tool(NoizuPromptLingua.Domains.Campaigns.Tools.DomainNameList, category: "Campaigns.Domains")

  tool(NoizuPromptLingua.Tools.ToolSummary, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolSearch, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolCall, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolHelp, category: "Discovery")
end
