defmodule NoizuPromptLingua.Domains.Wiki.Tools.ReactionAdd do
  use Noizu.MCP.Server.Tool,
    name: "Wiki.ReactionAdd",
    description: "Add a reaction (emoji) to a wiki page or comment. Idempotent per actor.",
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
    with {:ok, target_type} <- target_type(Args.get(args, :target_type)),
         {:exists, true} <- {:exists, target_exists?(target_type, Args.get(args, :target))} do
      attrs = %{
        target_type: target_type,
        target_id: Args.get(args, :target),
        emoji: Args.get(args, :emoji),
        actor: Args.get(args, :actor) || "mcp"
      }

      case Wiki.add_reaction(attrs) do
        {:ok, reaction} -> {:ok, %{id: reaction.id, emoji: reaction.emoji, actor: reaction.actor}}
        {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
      end
    else
      {:error, msg} -> {:error, msg}
      {:exists, false} -> {:error, "Target not found"}
    end
  end

  defp target_type(t) when t in ["page", "comment"], do: {:ok, t}
  defp target_type(_), do: {:error, "target_type must be \"page\" or \"comment\""}

  defp target_exists?("page", id), do: not is_nil(Wiki.get_page(id))
  defp target_exists?("comment", id), do: not is_nil(Wiki.get_comment(id))
end
