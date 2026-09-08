defmodule NoizuPromptLingua.Schema.ShowcaseEntry do
  @moduledoc """
  One OP-vs-NPL showcase eval: the original user description treated as a raw
  prompt vs the NPL rewrite (authored with the vendored prompt-engineer skill),
  both executed against a canonical test input and scored by a fixed LLM rubric.
  `error != nil` marks a failed pipeline run (recorded, never retried
  automatically — prompts are processed once).
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "showcase_entries" do
    field :log_id, :binary_id
    field :original_prompt, :string
    field :original_output, :string
    field :npl_prompt, :string
    field :npl_output, :string
    field :score_original, :integer
    field :score_npl, :integer
    field :winner, :string
    field :ctx_original_chars, :integer
    field :ctx_original_tokens, :integer
    field :ctx_npl_chars, :integer
    field :ctx_npl_tokens, :integer
    field :rubric, :map
    field :difference_analysis, :string
    field :error, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [
      :log_id,
      :original_prompt,
      :original_output,
      :npl_prompt,
      :npl_output,
      :score_original,
      :score_npl,
      :winner,
      :ctx_original_chars,
      :ctx_original_tokens,
      :ctx_npl_chars,
      :ctx_npl_tokens,
      :rubric,
      :difference_analysis,
      :error
    ])
    |> validate_required([:log_id, :original_prompt])
    |> validate_inclusion(:winner, ["original", "npl", "tie"])
    |> unique_constraint(:log_id, name: :uq_showcase_entries_log)
  end
end
