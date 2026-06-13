defmodule NoizuPromptLingua.Schema.Ticket do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @priorities ~w(low medium high critical)

  schema "tickets" do
    field :title, :string
    field :description, :string
    field :ticket_type, :string
    field :status, :string, default: "open"
    field :priority, :string
    field :assignee, :string
    field :reporter, :string
    field :custom_fields, :map, default: %{}

    belongs_to :queue, NoizuPromptLingua.Schema.TicketQueue
    belongs_to :parent, NoizuPromptLingua.Schema.Ticket

    timestamps(type: :utc_datetime)
  end

  def changeset(ticket, attrs) do
    ticket
    |> cast(attrs, [:title, :description, :ticket_type, :status, :priority,
                     :assignee, :reporter, :queue_id, :parent_id, :custom_fields])
    |> validate_required([:title, :ticket_type])
    |> validate_inclusion(:priority, @priorities ++ [nil])
    |> foreign_key_constraint(:queue_id)
    |> foreign_key_constraint(:parent_id)
  end

  def update_changeset(ticket, attrs) do
    ticket
    |> cast(attrs, [:title, :description, :status, :priority,
                     :assignee, :queue_id, :parent_id, :custom_fields])
    |> validate_inclusion(:priority, @priorities ++ [nil])
  end
end
