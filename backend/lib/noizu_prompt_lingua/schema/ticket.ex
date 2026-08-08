defmodule NoizuPromptLingua.Schema.Ticket do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @priorities ~w(low medium high critical)

  schema "tickets" do
    field :organization_id, :binary_id
    field :title, :string
    field :description, :string
    field :ticket_type, :string
    field :status, :string, default: "open"
    field :priority, :string
    field :assignee, :string
    field :reporter, :string
    field :custom_fields, :map, default: %{}

    # Human key (f8bc7fab): immutable, assigned on insert by the domain (NOT cast).
    field :number, :integer
    field :key, :string

    belongs_to :project, NoizuPromptLingua.Schema.Projects.Project
    belongs_to :queue, NoizuPromptLingua.Schema.TicketQueue
    belongs_to :parent, NoizuPromptLingua.Schema.Ticket
    belongs_to :stage, NoizuPromptLingua.Schema.BoardStage
    belongs_to :iteration, NoizuPromptLingua.Schema.BoardIteration

    timestamps(type: :utc_datetime)
  end

  def changeset(ticket, attrs) do
    ticket
    |> cast(attrs, [
      :organization_id,
      :title,
      :description,
      :ticket_type,
      :status,
      :priority,
      :assignee,
      :reporter,
      :project_id,
      :queue_id,
      :parent_id,
      :custom_fields,
      :stage_id,
      :iteration_id
    ])
    |> validate_required([:organization_id, :title, :ticket_type])
    |> validate_inclusion(:priority, @priorities ++ [nil])
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:queue_id)
    |> foreign_key_constraint(:parent_id)
    |> foreign_key_constraint(:stage_id)
    |> foreign_key_constraint(:iteration_id)
    # Human-key uniqueness (f8bc7fab): the domain put_changes :number/:key; a 23505
    # from any of the three partial indexes maps back to a changeset error so the
    # key-gen txn rolls back cleanly instead of raising.
    |> unique_constraint(:number, name: :idx_tickets_proj_number)
    |> unique_constraint(:number, name: :idx_tickets_org_number)
    |> unique_constraint(:key, name: :idx_tickets_org_key)
  end

  def update_changeset(ticket, attrs) do
    ticket
    |> cast(attrs, [
      :title,
      :description,
      :status,
      :priority,
      :assignee,
      :project_id,
      :queue_id,
      :parent_id,
      :custom_fields,
      :stage_id,
      :iteration_id
    ])
    |> validate_inclusion(:priority, @priorities ++ [nil])
    |> foreign_key_constraint(:stage_id)
    |> foreign_key_constraint(:iteration_id)
  end
end
