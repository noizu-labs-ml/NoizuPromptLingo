defmodule NoizuPromptLingua.Schema.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "projects" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :status, :string, default: "active"

    belongs_to :owner, NoizuPromptLingua.Schema.User

    timestamps(type: :utc_datetime)
  end

  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :slug, :description, :status, :owner_id])
    |> validate_required([:name, :slug])
    |> validate_inclusion(:status, ~w(active archived))
    |> unique_constraint(:slug)
  end
end
