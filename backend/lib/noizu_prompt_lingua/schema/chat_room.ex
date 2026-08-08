defmodule NoizuPromptLingua.Schema.ChatRoom do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "chat_rooms" do
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :name, :string
    field :slug, :string
    field :description, :string
    field :session_id, :binary_id
    field :kind, :string, default: "channel"

    timestamps(type: :utc_datetime)
  end

  @kinds ~w(channel dm)

  def changeset(room, attrs) do
    room
    |> cast(attrs, [:organization_id, :project_id, :name, :slug, :description, :session_id, :kind])
    |> validate_required([:organization_id, :name, :slug])
    |> validate_inclusion(:kind, @kinds)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
    # Two partial unique indexes per (org, project) bucket (ADR-013 A3): a 23505
    # from either bucket maps to a :slug changeset error so create_room can retry.
    |> unique_constraint(:slug, name: :idx_chat_rooms_slug_proj)
    |> unique_constraint(:slug, name: :idx_chat_rooms_slug_noproj)
  end

  # Update path (0c93ddd4): only name + description are mutable. `slug` is an immutable
  # resolution alias (ADR-013) — a rename must NOT re-slug — and org/project/session are
  # not re-keyable post-create, so none of them are cast here. That makes slug/bucket
  # immutability a property of the changeset, not of caller discipline.
  def update_changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end

  def kinds, do: @kinds
end
