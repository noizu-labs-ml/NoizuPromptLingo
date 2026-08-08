defmodule NoizuPromptLingua.Schema.TicketEntityLink do
  @moduledoc """
  A polymorphic link between a ticket and a non-ticket entity (a customer
  persona, segment, campaign, keyword, competitor, landing page, ...). There is
  intentionally no DB FK on `entity_id` (it spans domains); the calling layer
  validates the target exists. Ticket↔ticket links live in `TicketLink`.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @entity_types ~w(customer_persona customer_segment campaign ad_group ad_copy
                   keyword competitor market_report landing_page domain_name)

  @link_types ~w(relates_to targets derived_from addresses blocks references)

  schema "ticket_entity_links" do
    field :ticket_id, :binary_id
    field :entity_type, :string
    field :entity_id, :binary_id
    field :link_type, :string, default: "relates_to"
    field :metadata, :map, default: %{}

    timestamps(type: :utc_datetime)
  end

  def changeset(link, attrs) do
    link
    |> cast(attrs, [:ticket_id, :entity_type, :entity_id, :link_type, :metadata])
    |> validate_required([:ticket_id, :entity_type, :entity_id, :link_type])
    |> validate_inclusion(:entity_type, @entity_types)
    |> validate_inclusion(:link_type, @link_types)
    |> foreign_key_constraint(:ticket_id)
    |> unique_constraint([:ticket_id, :entity_type, :entity_id, :link_type],
      name: :idx_ticket_entity_links_uniq
    )
  end

  def entity_types, do: @entity_types
  def link_types, do: @link_types
end
