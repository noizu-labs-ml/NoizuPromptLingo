defmodule NoizuPromptLingua.Schema.AgentOrchestration do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "agent_orchestrations" do
    field :pipeline, :string
    field :status, :string, default: "pending"
    field :context, :map
    field :session_id, :binary_id
    field :result, :map

    timestamps(type: :utc_datetime)
  end

  def changeset(orch, attrs) do
    orch
    |> cast(attrs, [:pipeline, :status, :context, :session_id, :result])
    |> validate_required([:pipeline])
    |> validate_inclusion(:status, ~w(pending running completed failed))
  end
end
