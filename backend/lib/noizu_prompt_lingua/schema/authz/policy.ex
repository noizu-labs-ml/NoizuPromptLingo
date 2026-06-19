defmodule NoizuPromptLingua.Schema.Authz.Policy do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "policies" do
    field :name, :string
    field :description, :string
    field :policy_document, :map
    field :is_system, :boolean, default: false
    field :is_active, :boolean, default: true
    belongs_to :created_by_user, NoizuPromptLingua.Schema.Users.User, type: Ecto.UUID, foreign_key: :created_by

    has_many :group_policies, NoizuPromptLingua.Schema.Authz.GroupPolicy

    timestamps(type: :utc_datetime_usec, inserted_at: :created_at, updated_at: :updated_at)
  end

  def changeset(policy, attrs) do
    policy
    |> cast(attrs, [:name, :description, :policy_document, :is_system, :is_active, :created_by])
    |> validate_required([:name, :policy_document])
    |> unique_constraint(:name)
    |> validate_policy_document()
  end

  defp validate_policy_document(changeset) do
    case get_change(changeset, :policy_document) do
      nil -> changeset
      doc ->
        case doc do
          %{"statements" => statements} when is_list(statements) -> changeset
          _ -> add_error(changeset, :policy_document, "must contain a 'statements' array")
        end
    end
  end
end
