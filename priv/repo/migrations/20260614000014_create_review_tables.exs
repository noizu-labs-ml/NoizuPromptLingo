defmodule NoizuPromptLingua.Repo.Migrations.CreateReviewTables do
  use Ecto.Migration

  def change do
    create table(:reviews, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :artifact_id, :binary_id, null: false
      add :revision_id, :binary_id, null: false
      add :reviewer_persona, :string, null: false
      add :title, :string
      add :status, :string, null: false, default: "open"
      add :summary, :text
      add :verdict, :string

      timestamps(type: :utc_datetime)
    end

    create index(:reviews, [:artifact_id])
    create index(:reviews, [:status])

    create table(:review_overlays, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :review_id, references(:reviews, type: :binary_id, on_delete: :delete_all), null: false
      add :x, :integer, null: false
      add :y, :integer, null: false
      add :width, :integer
      add :height, :integer
      add :comment, :text, null: false
      add :persona, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:review_overlays, [:review_id])
  end
end
