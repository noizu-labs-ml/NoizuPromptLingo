defmodule Codefresh.Results.Dashboard do
  @moduledoc """
  Head entity for a saved dashboard (US-077 / US-129 / US-130). Mirrors the
  head/version pattern used by Scripts/Prompts/Datasets — the draft layout
  lives in `layout`, and `current_version_id` points at the last published
  snapshot. For Wave-3 we expose a single `save_dashboard` that writes the
  head directly; versioning is opt-in by calling `Results.publish_dashboard/2`
  (not wired yet at Stage 6, schema is forward-compatible).

  Mirrors migration `20260421000031_create_dashboards_and_versions.exs`.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "dashboards" do
    field :slug, :string
    field :name, :string
    field :description, :string
    field :archived_at, :utc_datetime

    # `layout` is not persisted on the head — the migration owns it on the
    # version table. We keep a virtual field for draft editing convenience so
    # callers can round-trip a layout through save_dashboard/get_dashboard
    # without round-tripping to a published version. Persistence of draft
    # layout is deferred to Wave 3 extension; for Stage 6 the layout is
    # mirrored in `dashboard_versions` on save.
    field :layout, :map, virtual: true, default: %{}

    belongs_to :organization, Codefresh.Organizations.Organization

    belongs_to :current_version, Codefresh.Results.DashboardVersion,
      foreign_key: :current_version_id

    belongs_to :created_by, Codefresh.Accounts.User, foreign_key: :created_by_user_id

    has_many :versions, Codefresh.Results.DashboardVersion

    timestamps(type: :utc_datetime)
  end

  def create_changeset(dashboard, attrs) do
    dashboard
    |> cast(attrs, [:slug, :name, :description, :organization_id, :created_by_user_id])
    |> validate_required([:name, :organization_id])
    |> validate_length(:name, min: 1, max: 200)
    |> validate_length(:description, max: 4_000)
    |> maybe_derive_slug()
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9-]*$/,
      message: "must be lowercase alphanumeric with dashes"
    )
    |> validate_length(:slug, min: 1, max: 120)
    |> unique_constraint(:slug, name: :dashboards_organization_id_slug_index)
    |> foreign_key_constraint(:organization_id)
  end

  def update_changeset(dashboard, attrs) do
    dashboard
    |> cast(attrs, [:name, :description, :slug])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 200)
    |> validate_length(:description, max: 4_000)
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9-]*$/,
      message: "must be lowercase alphanumeric with dashes"
    )
    |> unique_constraint(:slug, name: :dashboards_organization_id_slug_index)
  end

  def advance_current_version_changeset(dashboard, version_id),
    do: change(dashboard, current_version_id: version_id)

  defp maybe_derive_slug(changeset) do
    case {get_change(changeset, :slug), get_field(changeset, :slug), get_change(changeset, :name)} do
      {nil, nil, name} when is_binary(name) -> put_change(changeset, :slug, derive_slug(name))
      _ -> changeset
    end
  end

  def derive_slug(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end
end
