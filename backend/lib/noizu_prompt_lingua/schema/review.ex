defmodule NoizuPromptLingua.Schema.Review do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @statuses ~w(open in_progress completed)
  @verdicts ~w(approved changes_requested rejected)

  schema "reviews" do
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :artifact_id, :binary_id
    field :revision_id, :binary_id
    field :reviewer_persona, :string
    field :title, :string
    field :status, :string, default: "open"
    field :summary, :string
    field :verdict, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(review, attrs) do
    review
    |> cast(attrs, [
      :organization_id,
      :project_id,
      :artifact_id,
      :revision_id,
      :reviewer_persona,
      :title,
      :status,
      :summary,
      :verdict
    ])
    |> validate_required([:organization_id, :artifact_id, :revision_id, :reviewer_persona])
    |> validate_inclusion(:status, @statuses)
    |> validate_inclusion(:verdict, @verdicts ++ [nil])
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
  end
end
