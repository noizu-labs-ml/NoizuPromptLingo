defmodule NoizuPromptLingua.Schema.MockMCPLLM do
  @moduledoc """
  An org-scoped, reusable LLM connection: provider + model + optional endpoint +
  optional API key. Referenced by `mock_mcp_definitions.active_llm_id`. The
  `api_key` is stored verbatim (masked on output), matching the github_tokens
  convention.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "mock_mcp_llms" do
    field :organization_id, :binary_id
    field :label, :string
    field :provider, :string, default: "openai"
    field :model, :string
    field :endpoint, :string
    field :api_key, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(llm, attrs) do
    llm
    |> cast(attrs, [:organization_id, :label, :provider, :model, :endpoint, :api_key])
    |> validate_required([:organization_id, :label, :provider, :model])
    |> unique_constraint(:label, name: :uq_mock_mcp_llms_org_label)
    |> foreign_key_constraint(:organization_id)
  end
end
