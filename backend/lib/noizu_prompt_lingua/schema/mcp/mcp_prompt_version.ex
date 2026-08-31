defmodule NoizuPromptLingua.Schema.MCP.McpPromptVersion do
  @moduledoc """
  An immutable version of an MCP prompt's body (version = previous max + 1).
  The parent prompt's `active_version` selects which one `prompts/get` serves.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "mcp_prompt_versions" do
    field :prompt_id, :binary_id
    field :version, :integer
    field :template, :string
    field :change_note, :string

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(version, attrs) do
    version
    |> cast(attrs, [:prompt_id, :version, :template, :change_note])
    |> validate_required([:prompt_id, :version, :template])
    |> validate_number(:version, greater_than: 0)
    |> foreign_key_constraint(:prompt_id)
    |> unique_constraint([:prompt_id, :version], name: :idx_mcp_prompt_versions_unique)
  end
end
