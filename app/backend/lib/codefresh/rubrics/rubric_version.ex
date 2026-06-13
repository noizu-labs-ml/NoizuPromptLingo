defmodule Codefresh.Rubrics.RubricVersion do
  @moduledoc """
  Immutable version of a rubric. Pins the judge prompt version + judge model +
  scale + optional weighted criteria.

  `scale` canonical shape:

      %{"min" => 0, "max" => 1, "type" => "continuous"}

  `criteria` canonical shape (criteria list may be empty for single-judge rubrics):

      %{
        "items" => [
          %{"name" => "accuracy", "weight" => 0.5, "direction" => "positive"},
          %{"name" => "tone", "weight" => 0.5, "direction" => "positive"}
        ]
      }
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @scale_types ~w(continuous discrete ladder enum)

  schema "rubric_versions" do
    field :version_number, :integer
    field :judge_model, :string
    field :scale, :map, default: %{"min" => 0, "max" => 1, "type" => "continuous"}
    field :criteria, :map, default: %{}
    field :checksum, :binary
    field :n_samples, :integer, default: 1

    belongs_to :rubric, Codefresh.Rubrics.Rubric
    belongs_to :organization, Codefresh.Organizations.Organization

    belongs_to :judge_prompt_version, Codefresh.Prompts.PromptVersion,
      foreign_key: :judge_prompt_version_id

    belongs_to :published_by, Codefresh.Accounts.User, foreign_key: :published_by_user_id

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def create_changeset(rv, attrs) do
    rv
    |> cast(attrs, [
      :rubric_id,
      :organization_id,
      :version_number,
      :judge_prompt_version_id,
      :judge_model,
      :scale,
      :criteria,
      :checksum,
      :n_samples,
      :published_by_user_id
    ])
    |> validate_required([
      :rubric_id,
      :organization_id,
      :version_number,
      :judge_prompt_version_id,
      :judge_model,
      :checksum
    ])
    |> validate_number(:version_number, greater_than: 0)
    |> validate_number(:n_samples, greater_than_or_equal_to: 1, less_than_or_equal_to: 10)
    |> validate_scale()
    |> validate_criteria()
    |> unique_constraint([:rubric_id, :version_number])
    |> unique_constraint([:rubric_id, :checksum])
    |> foreign_key_constraint(:rubric_id)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:judge_prompt_version_id)
  end

  def compute_checksum(judge_prompt_version_id, judge_model, scale, criteria, n_samples \\ 1) do
    canonical =
      [
        to_string(judge_prompt_version_id),
        to_string(judge_model),
        inspect(scale, limit: :infinity),
        inspect(criteria, limit: :infinity),
        "n=#{n_samples}"
      ]
      |> Enum.join("\n---\n")

    :crypto.hash(:sha256, canonical)
  end

  defp validate_scale(changeset) do
    case get_field(changeset, :scale) do
      nil ->
        changeset

      %{} = scale ->
        case scale_type(scale) do
          nil ->
            add_error(
              changeset,
              :scale,
              "must have a 'type' field in: #{Enum.join(@scale_types, ", ")}"
            )

          type when type in ["continuous", "discrete"] ->
            validate_numeric_scale(changeset, scale)

          type when type in ["ladder", "enum"] ->
            validate_enum_scale(changeset, scale)

          _ ->
            add_error(
              changeset,
              :scale,
              "unknown scale type; use: #{Enum.join(@scale_types, ", ")}"
            )
        end

      _ ->
        add_error(changeset, :scale, "must be a map")
    end
  end

  defp scale_type(scale), do: Map.get(scale, "type") || Map.get(scale, :type)

  defp validate_numeric_scale(changeset, scale) do
    min = Map.get(scale, "min") || Map.get(scale, :min)
    max = Map.get(scale, "max") || Map.get(scale, :max)

    cond do
      not is_number(min) ->
        add_error(changeset, :scale, "continuous/discrete scale requires numeric 'min'")

      not is_number(max) ->
        add_error(changeset, :scale, "continuous/discrete scale requires numeric 'max'")

      max <= min ->
        add_error(changeset, :scale, "scale 'max' must exceed 'min'")

      true ->
        changeset
    end
  end

  # Ladder / enum: values must be a non-empty list of %{"label", "score"} pairs with
  # monotonically non-decreasing scores.
  defp validate_enum_scale(changeset, scale) do
    values = Map.get(scale, "values") || Map.get(scale, :values)

    cond do
      not is_list(values) or values == [] ->
        add_error(changeset, :scale, "ladder/enum scale requires non-empty 'values' list")

      Enum.any?(values, fn v -> not enum_value?(v) end) ->
        add_error(
          changeset,
          :scale,
          "each ladder/enum value must be %{\"label\", \"score\"} where score is numeric"
        )

      not monotonic_non_decreasing?(Enum.map(values, &value_score/1)) ->
        add_error(changeset, :scale, "ladder/enum values must be ordered by non-decreasing score")

      true ->
        changeset
    end
  end

  defp enum_value?(v) when is_map(v) do
    label = Map.get(v, "label") || Map.get(v, :label)
    score = Map.get(v, "score") || Map.get(v, :score)
    is_binary(label) and label != "" and is_number(score)
  end

  defp enum_value?(_), do: false

  defp value_score(v), do: Map.get(v, "score") || Map.get(v, :score)

  defp monotonic_non_decreasing?(scores) do
    scores
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.all?(fn [a, b] -> b >= a end)
  end

  # Criteria validation (US-056). Shape:
  #   %{"items" => [%{"name", "weight", "description"?, "judge_model"?}]}
  # Empty criteria map is valid (single-judgment rubric).
  defp validate_criteria(changeset) do
    case get_field(changeset, :criteria) do
      nil ->
        changeset

      %{} = c when map_size(c) == 0 ->
        changeset

      %{} = c ->
        items = Map.get(c, "items") || Map.get(c, :items)

        cond do
          items == nil ->
            changeset

          not is_list(items) ->
            add_error(changeset, :criteria, "'items' must be a list")

          Enum.any?(items, fn i -> not criterion?(i) end) ->
            add_error(
              changeset,
              :criteria,
              "each item must be %{\"name\", \"weight\"} where weight is 0..1"
            )

          true ->
            changeset
        end

      _ ->
        add_error(changeset, :criteria, "must be a map")
    end
  end

  defp criterion?(i) when is_map(i) do
    name = Map.get(i, "name") || Map.get(i, :name)
    weight = Map.get(i, "weight") || Map.get(i, :weight)
    is_binary(name) and name != "" and is_number(weight) and weight >= 0 and weight <= 1
  end

  defp criterion?(_), do: false
end
