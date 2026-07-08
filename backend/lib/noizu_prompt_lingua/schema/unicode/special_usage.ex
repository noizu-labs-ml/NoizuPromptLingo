defmodule NoizuPromptLingua.Schema.Unicode.SpecialUsage do
  @moduledoc """
  Reusable NPL-specific Unicode usage definition.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @scopes ~w(global organization project)

  schema "unicode_special_usages" do
    field :scope, :string, default: "global"
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :slug, :string
    field :name, :string
    field :title, :string
    field :description, :string
    field :references, {:array, :map}, source: :reference_links, default: []
    field :flags, {:array, :string}, default: []
    field :topics, {:array, :string}, default: []

    many_to_many :elements, NoizuPromptLingua.Schema.Unicode.Element,
      join_through: NoizuPromptLingua.Schema.Unicode.ElementUsage,
      join_keys: [special_usage_id: :id, element_id: :id]

    timestamps(type: :utc_datetime)
  end

  @castable ~w(scope organization_id project_id slug name title description
               references flags topics)a

  def changeset(usage, attrs) do
    usage
    |> cast(attrs, @castable)
    |> normalize_slug()
    |> validate_required([:scope, :slug, :name, :title])
    |> validate_inclusion(:scope, @scopes)
    |> validate_scope()
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
    |> unique_constraint(:slug, name: :idx_unicode_special_usages_global_slug)
    |> unique_constraint([:organization_id, :slug], name: :idx_unicode_special_usages_org_slug)
    |> unique_constraint([:organization_id, :project_id, :slug],
      name: :idx_unicode_special_usages_project_slug
    )
  end

  def scopes, do: @scopes

  defp normalize_slug(changeset) do
    update_change(changeset, :slug, fn
      nil -> nil
      slug -> slug |> String.trim() |> String.downcase()
    end)
  end

  defp validate_scope(changeset) do
    scope = get_field(changeset, :scope)
    org_id = get_field(changeset, :organization_id)
    project_id = get_field(changeset, :project_id)

    case {scope, org_id, project_id} do
      {"global", nil, nil} ->
        changeset

      {"organization", org, nil} when is_binary(org) ->
        changeset

      {"project", org, project} when is_binary(org) and is_binary(project) ->
        changeset

      {"global", _, _} ->
        add_error(changeset, :scope, "global entries cannot have organization_id or project_id")

      {"organization", nil, _} ->
        add_error(changeset, :organization_id, "is required for organization scope")

      {"organization", _, project} when is_binary(project) ->
        add_error(changeset, :project_id, "must be empty for organization scope")

      {"project", nil, _} ->
        add_error(changeset, :organization_id, "is required for project scope")

      {"project", _, nil} ->
        add_error(changeset, :project_id, "is required for project scope")

      _ ->
        changeset
    end
  end
end
