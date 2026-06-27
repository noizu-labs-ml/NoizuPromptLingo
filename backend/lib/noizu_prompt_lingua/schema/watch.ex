defmodule NoizuPromptLingua.Schema.Watch do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "npl_watches" do
    field :entity_type, :string
    field :entity_id, :binary_id
    field :persona, :string
    field :filter, :map

    timestamps(type: :utc_datetime)
  end

  def changeset(watch, attrs) do
    watch
    |> cast(attrs, [:entity_type, :entity_id, :persona, :filter])
    |> normalize_filter()
    |> validate_required([:entity_type, :entity_id, :persona])
    |> unique_constraint([:entity_type, :entity_id, :persona])
  end

  # A bare string filter is stored as `%{"type" => "substring", "value" => str}`
  # so the jsonb column always holds an object; nil/maps pass through untouched.
  defp normalize_filter(changeset) do
    case get_change(changeset, :filter) do
      filter when is_binary(filter) ->
        put_change(changeset, :filter, %{"type" => "substring", "value" => filter})

      _ ->
        changeset
    end
  end
end
