defmodule NoizuPromptLingua.Domains.Wiki.Tools.ReactionRemove do
  use Noizu.MCP.Server.Tool,
    name: "Wiki.ReactionRemove",
    description: "Remove a reaction (emoji) from a wiki page or comment for the given actor.",
    hidden: true,
    category: "Wiki"

  input do
    field :target_type, :string, required: true, description: "Reaction target: \"page\" or \"comment\""
    field :target, :string, required: true, description: "Page or comment UUID"
    field :emoji, :string, required: true, description: "Reaction emoji or shortcode"
    field :actor, :string, description: "Actor label (defaults to \"mcp\")"
  end

  alias NoizuPromptLingua.Domains.Wiki
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    with {:ok, target_type} <- target_type(Args.get(args, :target_type)) do
      actor = Args.get(args, :actor) || "mcp"

      case Wiki.remove_reaction(target_type, Args.get(args, :target), Args.get(args, :emoji), actor) do
        :ok -> {:ok, %{removed: true}}
        {:error, :not_found} -> {:error, "Reaction not found"}
      end
    end
  end

  defp target_type(t) when t in ["page", "comment"], do: {:ok, t}
  defp target_type(_), do: {:error, "target_type must be \"page\" or \"comment\""}
end
