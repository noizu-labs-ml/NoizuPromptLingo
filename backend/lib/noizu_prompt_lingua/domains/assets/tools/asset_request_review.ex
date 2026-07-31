defmodule NoizuPromptLingua.Domains.Assets.Tools.AssetRequestReview do
  use Noizu.MCP.Server.Tool,
    name: "Asset.RequestReview",
    description: "Create a Review for an output's artifact.",
    hidden: true,
    category: "Assets.Review"

  input do
    field :output_id, :string, required: true, description: "Output UUID"
    field :reviewer_persona, :string, required: true, description: "Reviewer persona slug"
    field :title, :string, description: "Review title"
    field :actor, :string, description: "Actor persona"
  end

  alias NoizuPromptLingua.Domains.{Assets, Reviews}

  @impl true
  def call(args, _ctx) do
    output_id = args[:output_id] || args["output_id"]

    case NoizuPromptLingua.Repo.get(NoizuPromptLingua.Schema.AssetOutput, output_id) do
      nil ->
        {:error, "Output not found"}

      output ->
        artifact_id = output.artifact_id
        entry = Assets.get(output.entry_id)
        {_, revision} = NoizuPromptLingua.Domains.Artifacts.get(artifact_id)
        revision_id = revision && revision.id

        case Reviews.create(%{
               organization_id: entry && entry.organization_id,
               project_id: entry && entry.project_id,
               artifact_id: artifact_id,
               revision_id: revision_id || artifact_id,
               reviewer_persona: args[:reviewer_persona] || args["reviewer_persona"],
               title: args[:title] || args["title"]
             }) do
          {:ok, review} ->
            Assets.update(output.entry_id, %{status: "review"},
              actor: args[:actor] || args["actor"]
            )

            {:ok, %{review_id: review.id, artifact_id: artifact_id, status: review.status}}

          {:error, cs} ->
            {:error, "Failed: #{inspect(cs.errors)}"}
        end
    end
  end
end
