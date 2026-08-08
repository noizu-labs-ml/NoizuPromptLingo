defmodule NoizuPromptLingua.Domains.Wiki.Tools.ReactionList do
  use Noizu.MCP.Server.Tool,
    name: "Wiki.ReactionList",
    description: "List reactions on a wiki page or comment.",
    hidden: true,
    category: "Wiki",
    annotations: [read_only_hint: true]

  input do
    field :target_type, :string,
      required: true,
      description: "Reaction target: \"page\" or \"comment\""

    field :target, :string, required: true, description: "Page or comment UUID"
  end

  alias NoizuPromptLingua.Domains.Wiki
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    with {:ok, target_type} <- target_type(Args.get(args, :target_type)) do
      target_id = Args.get(args, :target)
      reactions = Wiki.list_reactions(target_type, target_id)

      {:ok,
       %{
         target_type: target_type,
         target_id: target_id,
         reactions: Enum.map(reactions, fn r -> %{id: r.id, emoji: r.emoji, actor: r.actor} end),
         count: length(reactions)
       }}
    end
  end

  defp target_type(t) when t in ["page", "comment"], do: {:ok, t}
  defp target_type(_), do: {:error, "target_type must be \"page\" or \"comment\""}
end
