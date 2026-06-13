defmodule NoizuPromptLingua.Schema.TicketQueue do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "ticket_queues" do
    field :name, :string
    field :slug, :string
    field :description, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(queue, attrs) do
    queue
    |> cast(attrs, [:name, :slug, :description])
    |> validate_required([:name, :slug])
    |> unique_constraint(:slug)
  end
end
