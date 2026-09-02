defmodule NoizuPromptLingua.Schema.Organizations.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "organizations" do
    field :slug, :string
    field :name, :string
    field :settings, :map, default: %{}
    field :key_prefix, :string
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(org, attrs) do
    org
    |> cast(attrs, [:slug, :name, :settings, :key_prefix])
    |> validate_required([:slug, :name])
    # Human-key prefix for org-level tickets (f8bc7fab): uppercase alnum, 2-16; unique.
    |> validate_format(:key_prefix, ~r/^[A-Z0-9]{2,16}$/,
      message: "must be 2-16 uppercase letters/digits"
    )
    # Slug uniqueness is enforced under TWO names depending on the provisioning
    # path: the 009 base table's `UNIQUE` constraint (PG auto-name
    # `organizations_slug_key`, Liquibase/stage) and the 082 named index
    # (`idx_organizations_slug`, Ecto/prod). Declare both so a violation maps to
    # a changeset error instead of raising Ecto.ConstraintError → 500.
    |> unique_constraint(:slug, name: :organizations_slug_key)
    |> unique_constraint(:slug, name: :idx_organizations_slug)
    |> unique_constraint(:key_prefix, name: :idx_organizations_key_prefix)
  end
end
