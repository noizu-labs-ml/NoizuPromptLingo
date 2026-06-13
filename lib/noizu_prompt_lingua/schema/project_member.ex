defmodule NoizuPromptLingua.Schema.ProjectMember do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @roles ~w(owner admin member viewer)
  @statuses ~w(pending active removed)

  schema "project_members" do
    belongs_to :project, NoizuPromptLingua.Schema.Project
    belongs_to :user, NoizuPromptLingua.Schema.User
    field :role, :string, default: "member"
    field :invited_by, :binary_id
    field :invited_at, :utc_datetime
    field :accepted_at, :utc_datetime
    field :status, :string, default: "pending"

    timestamps(type: :utc_datetime)
  end

  def changeset(member, attrs) do
    member
    |> cast(attrs, [:project_id, :user_id, :role, :invited_by, :invited_at, :accepted_at, :status])
    |> validate_required([:project_id, :user_id, :role])
    |> validate_inclusion(:role, @roles)
    |> validate_inclusion(:status, @statuses)
    |> unique_constraint([:project_id, :user_id])
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:user_id)
  end

  def roles, do: @roles
end
