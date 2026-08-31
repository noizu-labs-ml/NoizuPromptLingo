defmodule NoizuPromptLingua.Schema.Acl.GroupMember do
  @moduledoc """
  Membership of an arbitrary entity (ERP `{:ref, Type, id}` record, JSONB) in
  an ACL group (Liquibase 081). Members may be users, personas, api keys — or
  the ref of another ACL group, which is how nested groups are expressed (the
  resolver expands them transitively with a cycle guard).
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias NoizuPromptLingua.Acl.ERPRef
  alias NoizuPromptLingua.Schema.Acl.Group

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "acl_group_members" do
    belongs_to :group, Group, type: Ecto.UUID
    field :member_ref, ERPRef
    field :expires_at, :utc_datetime_usec
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(member, attrs) do
    member
    |> cast(attrs, [:group_id, :member_ref, :expires_at])
    |> validate_required([:group_id, :member_ref])
    |> foreign_key_constraint(:group_id)
    |> unique_constraint(:member_ref, name: :uq_acl_group_members_group_member)
  end
end
