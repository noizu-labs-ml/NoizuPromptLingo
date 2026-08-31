defmodule NoizuPromptLingua.Schema.Acl.Group do
  @moduledoc """
  An ACL permission group (Liquibase 081). A group MAY be bound to any
  arbitrary entity via its `ref` (an ERP `{:ref, Type, id}` record, JSONB) —
  org groups bound to an Organization ref, project groups, ad-hoc global
  groups (`ref: nil`). Members of any shape attach via
  `NoizuPromptLingua.Schema.Acl.GroupMember`; rules target groups by their ref
  via `NoizuPromptLingua.Schema.Acl.Rule`.

  Resolution lives in `NoizuPromptLingua.Acl` / `NoizuPromptLingua.Acl.Resolver`.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias NoizuPromptLingua.Acl.ERPRef

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "acl_groups" do
    field :name, :string
    field :description, :string
    field :ref, ERPRef
    field :status, :string, default: "active"
    field :metadata, :map, default: %{}
    timestamps(type: :utc_datetime_usec)
  end

  @statuses ~w(active archived)

  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :description, :ref, :status, :metadata])
    |> validate_required([:name])
    |> validate_inclusion(:status, @statuses)
    |> unique_constraint(:name, name: :idx_acl_groups_name)
  end
end
