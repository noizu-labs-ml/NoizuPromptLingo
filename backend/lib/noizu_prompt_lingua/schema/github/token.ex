defmodule NoizuPromptLingua.Schema.GithubToken do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "github_tokens" do
    belongs_to :organization, NoizuPromptLingua.Schema.Organizations.Organization, type: Ecto.UUID
    field :label, :string
    field :token, :string
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(token, attrs) do
    token
    |> cast(attrs, [:organization_id, :label, :token])
    |> validate_required([:organization_id, :label, :token])
    |> unique_constraint([:organization_id, :label], name: :uq_github_tokens_org_label)
  end
end
