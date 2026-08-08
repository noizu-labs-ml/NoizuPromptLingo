defmodule NoizuPromptLingua.Schema.MockMCPCallLog do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "mock_mcp_call_logs" do
    belongs_to :definition, NoizuPromptLingua.Schema.MockMCPDefinition
    field :session_id, :string
    field :method, :string
    field :tool_name, :string
    field :arguments, :map
    field :response, :map
    field :latency_ms, :integer
    field :error, :string

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(log, attrs) do
    log
    |> cast(attrs, [
      :definition_id,
      :session_id,
      :method,
      :tool_name,
      :arguments,
      :response,
      :latency_ms,
      :error
    ])
    |> validate_required([:definition_id, :method])
  end
end
