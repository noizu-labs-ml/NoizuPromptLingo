defmodule NoizuPromptLingua.Schema.TicketLink do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @link_types ~w(blocks blocked_by relates_to duplicates parent_of child_of)

  schema "ticket_links" do
    belongs_to :source_ticket, NoizuPromptLingua.Schema.Ticket
    belongs_to :target_ticket, NoizuPromptLingua.Schema.Ticket
    field :link_type, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(link, attrs) do
    link
    |> cast(attrs, [:source_ticket_id, :target_ticket_id, :link_type])
    |> validate_required([:source_ticket_id, :target_ticket_id, :link_type])
    |> validate_inclusion(:link_type, @link_types)
    |> unique_constraint([:source_ticket_id, :target_ticket_id, :link_type])
    |> foreign_key_constraint(:source_ticket_id)
    |> foreign_key_constraint(:target_ticket_id)
  end

  def link_types, do: @link_types
end
