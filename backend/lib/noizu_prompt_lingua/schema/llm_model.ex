defmodule NoizuPromptLingua.Schema.LLMModel do
  @moduledoc """
  An editable catalog entry for a selectable LLM (provider + model + label).
  Surfaced in the Mock MCP model picker / MCP ListModels. Global (not org-scoped);
  `provider:model` is the natural id the frontend stores on a definition. The
  hardcoded list in `Domains.MockMCP.Models` is the compile-time fallback/seed.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "llm_models" do
    field :provider, :string
    field :model, :string
    field :label, :string
    field :endpoint, :string
    field :enabled, :boolean, default: true
    field :sort_order, :integer, default: 0
    field :notes, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:provider, :model, :label, :endpoint, :enabled, :sort_order, :notes])
    |> validate_required([:provider, :model, :label])
    |> unique_constraint([:provider, :model], name: :uq_llm_models_provider_model)
  end
end
