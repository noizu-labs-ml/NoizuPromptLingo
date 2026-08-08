defmodule NoizuPromptLingua.Domains.Assets.Tools.AssetHistory do
  use Noizu.MCP.Server.Tool,
    name: "Asset.History",
    description: "View lifecycle audit log.",
    hidden: true,
    category: "Assets",
    annotations: [read_only_hint: true]

  input do
    field :entry_id, :string, required: true, description: "Asset entry UUID"
    field :limit, :integer, description: "Max events (default 50)"
  end

  alias NoizuPromptLingua.Domains.Assets

  @impl true
  def call(args, _ctx) do
    entry_id = args[:entry_id] || args["entry_id"]
    limit = args[:limit] || args["limit"]
    opts = if limit, do: [limit: limit], else: []
    history = Assets.list_history(entry_id, opts)

    {:ok,
     %{
       entry_id: entry_id,
       events:
         Enum.map(
           history,
           &%{
             id: &1.id,
             action: &1.action,
             actor: &1.actor,
             details: &1.details,
             at: &1.inserted_at
           }
         ),
       count: length(history)
     }}
  end
end
