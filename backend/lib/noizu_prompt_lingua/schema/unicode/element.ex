defmodule NoizuPromptLingua.Schema.Unicode.Element do
  @moduledoc """
  Layered Unicode/control-code codex entry.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @scopes ~w(global organization project)
  @visibilities ~w(glyph emoji control invisible space combining directional)

  schema "unicode_elements" do
    field :scope, :string, default: "global"
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :slug, :string
    field :codepoint, :string
    field :codepoint_int, :integer
    field :char, :string
    field :name, :string
    field :title, :string
    field :description, :string
    field :meaning, :string
    field :printable, :boolean, default: true
    field :visibility, :string, default: "glyph"
    field :unicode_meta, :map, default: %{}
    field :flags, {:array, :string}, default: []
    field :topics, {:array, :string}, default: []
    field :sentiments, {:array, :string}, default: []
    field :aliases, {:array, :string}, default: []
    field :search_terms, {:array, :string}, default: []

    many_to_many :special_usages, NoizuPromptLingua.Schema.Unicode.SpecialUsage,
      join_through: NoizuPromptLingua.Schema.Unicode.ElementUsage,
      join_keys: [element_id: :id, special_usage_id: :id]

    has_many :outgoing_relations, NoizuPromptLingua.Schema.Unicode.ElementRelation,
      foreign_key: :source_element_id

    has_many :incoming_relations, NoizuPromptLingua.Schema.Unicode.ElementRelation,
      foreign_key: :target_element_id

    timestamps(type: :utc_datetime)
  end

  @castable ~w(scope organization_id project_id slug codepoint codepoint_int char
               name title description meaning printable visibility unicode_meta
               flags topics sentiments aliases search_terms)a

  def changeset(element, attrs) do
    element
    |> cast(attrs, @castable)
    |> normalize_slug()
    |> maybe_put_codepoint_int()
    |> validate_required([:scope, :slug, :name, :title])
    |> validate_inclusion(:scope, @scopes)
    |> validate_inclusion(:visibility, @visibilities)
    |> validate_scope()
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
    |> unique_constraint(:slug, name: :idx_unicode_elements_global_slug)
    |> unique_constraint([:organization_id, :slug], name: :idx_unicode_elements_org_slug)
    |> unique_constraint([:organization_id, :project_id, :slug],
      name: :idx_unicode_elements_project_slug
    )
  end

  def scopes, do: @scopes
  def visibilities, do: @visibilities

  def parse_codepoint_int(nil), do: nil
  def parse_codepoint_int(""), do: nil

  def parse_codepoint_int(codepoint) when is_binary(codepoint) do
    codepoint
    |> String.split(~r/\s+/, trim: true)
    |> List.first()
    |> case do
      "U+" <> hex -> parse_hex(hex)
      "\\u" <> hex -> parse_hex(hex)
      "\\x" <> hex -> parse_hex(hex)
      other -> parse_hex(other)
    end
  end

  def parse_codepoint_int(_), do: nil

  defp parse_hex(hex) do
    case Integer.parse(hex, 16) do
      {value, ""} when value >= 0 and value <= 0x10FFFF -> value
      _ -> nil
    end
  end

  defp normalize_slug(changeset) do
    update_change(changeset, :slug, fn
      nil -> nil
      slug -> slug |> String.trim() |> String.downcase()
    end)
  end

  defp maybe_put_codepoint_int(changeset) do
    case get_field(changeset, :codepoint_int) do
      nil ->
        case parse_codepoint_int(get_field(changeset, :codepoint)) do
          nil -> changeset
          value -> put_change(changeset, :codepoint_int, value)
        end

      _ ->
        changeset
    end
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

      {"project", nil, nil} ->
        # Both layers missing — report both (a single-clause match would only
        # surface the first, hiding the second from callers).
        changeset
        |> add_error(:organization_id, "is required for project scope")
        |> add_error(:project_id, "is required for project scope")

      {"project", nil, _} ->
        add_error(changeset, :organization_id, "is required for project scope")

      {"project", _, nil} ->
        add_error(changeset, :project_id, "is required for project scope")

      _ ->
        changeset
    end
  end
end
