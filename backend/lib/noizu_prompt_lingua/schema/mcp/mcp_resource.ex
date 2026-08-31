defmodule NoizuPromptLingua.Schema.MCP.McpResource do
  @moduledoc """
  An MCP resource entry (MCP `resources` capability): a URI-addressable blob of
  text served via `resources/read`. Global entries have nil
  `organization_id`/`project_id`; scoped entries shadow global ones for their
  scope.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "mcp_resources" do
    field :uri, :string
    field :name, :string
    field :description, :string
    field :mime_type, :string, default: "text/plain"
    field :content, :string
    field :organization_id, :binary_id
    field :project_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  def changeset(resource, attrs) do
    resource
    |> cast(attrs, [
      :uri,
      :name,
      :description,
      :mime_type,
      :content,
      :organization_id,
      :project_id
    ])
    |> update_change(:uri, &String.trim/1)
    |> validate_required([:uri, :name, :content])
    |> validate_length(:uri, max: 2048)
    |> validate_length(:content, max: 1_048_576)
  end
end
