defmodule NoizuPromptLingua.Schema.GithubRepo do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "github_repos" do
    belongs_to :organization, NoizuPromptLingua.Schema.Organizations.Organization, type: Ecto.UUID
    field :repo_full_name, :string
    field :default_acl, :string, default: "private"

    belongs_to :token, NoizuPromptLingua.Schema.GithubToken,
      foreign_key: :token_id,
      type: Ecto.UUID,
      on_replace: :nilify

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(repo, attrs) do
    repo
    |> cast(attrs, [:organization_id, :repo_full_name, :default_acl, :token_id])
    |> validate_required([:organization_id, :repo_full_name])
    |> validate_inclusion(:default_acl, ["private", "org_read", "org_write"])
    |> unique_constraint([:organization_id, :repo_full_name], name: :uq_github_repos_org_name)
  end
end
