defmodule NoizuPromptLingua.Schema.AgentInstruction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "agent_instructions" do
    field :title, :string
    field :content, :string
    field :tags, {:array, :string}, default: []
    field :session_id, :binary_id
    field :version, :integer, default: 1

    timestamps(type: :utc_datetime)
  end

  def changeset(instr, attrs) do
    instr
    |> cast(attrs, [:title, :content, :tags, :session_id, :version])
    |> validate_required([:title, :content])
  end
end
