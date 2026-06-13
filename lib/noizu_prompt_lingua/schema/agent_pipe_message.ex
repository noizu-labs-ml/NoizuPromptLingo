defmodule NoizuPromptLingua.Schema.AgentPipeMessage do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "agent_pipe_messages" do
    field :target, :string
    field :sender, :string
    field :content, :string
    field :priority, :string, default: "normal"
    field :consumed, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  def changeset(msg, attrs) do
    msg
    |> cast(attrs, [:target, :sender, :content, :priority, :consumed])
    |> validate_required([:target, :sender, :content])
    |> validate_inclusion(:priority, ~w(normal high))
  end
end
