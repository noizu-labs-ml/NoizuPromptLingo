defmodule NoizuPromptLingua.Schema.Pipes.AgentPipeEntry do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "npl_agent_pipe_entries" do
    field :organization_id, :binary_id
    field :sender_handle, :string
    field :message_name, :string
    field :target_agent_handle, :string, default: ""
    field :target_group, :string, default: ""
    field :body, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [
      :organization_id,
      :sender_handle,
      :message_name,
      :target_agent_handle,
      :target_group,
      :body
    ])
    |> put_default(:target_agent_handle)
    |> put_default(:target_group)
    |> validate_required([:organization_id, :sender_handle, :message_name, :body])
    |> unique_constraint(
      [:organization_id, :sender_handle, :message_name, :target_agent_handle, :target_group],
      name: :idx_agent_pipe_entries_upsert
    )
    |> foreign_key_constraint(:organization_id)
  end

  defp put_default(changeset, field) do
    case get_field(changeset, field) do
      nil -> put_change(changeset, field, "")
      _ -> changeset
    end
  end
end
