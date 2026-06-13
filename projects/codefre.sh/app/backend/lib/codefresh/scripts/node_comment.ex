defmodule Codefresh.Scripts.NodeComment do
  @moduledoc """
  A comment thread entry on a script_node (US-045). Comments are grouped by
  `thread_id` (a client-generated UUID). `parent_comment_id` supports replies
  within a thread. `resolved_at` marks thread resolution.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "node_comments" do
    field :thread_id, Ecto.UUID
    field :body, :string
    field :resolved_at, :utc_datetime

    belongs_to :script_node, Codefresh.Scripts.ScriptNode
    belongs_to :organization, Codefresh.Organizations.Organization
    belongs_to :author, Codefresh.Accounts.User, foreign_key: :author_user_id
    belongs_to :parent_comment, Codefresh.Scripts.NodeComment, foreign_key: :parent_comment_id
    belongs_to :resolved_by, Codefresh.Accounts.User, foreign_key: :resolved_by_user_id

    timestamps(type: :utc_datetime)
  end

  def create_changeset(comment, attrs) do
    comment
    |> cast(attrs, [
      :script_node_id,
      :organization_id,
      :author_user_id,
      :thread_id,
      :parent_comment_id,
      :body
    ])
    |> validate_required([:script_node_id, :organization_id, :author_user_id, :thread_id, :body])
    |> validate_length(:body, min: 1, max: 10_000)
    |> foreign_key_constraint(:script_node_id)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:author_user_id)
    |> foreign_key_constraint(:parent_comment_id)
  end

  def resolve_changeset(comment, resolver_user_id) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    comment
    |> change(resolved_at: now, resolved_by_user_id: resolver_user_id)
  end
end
