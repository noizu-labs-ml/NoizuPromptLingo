defmodule NoizuPromptLingua.Schema.MCP.McpResourceTemplate do
  @moduledoc """
  An MCP resource template (MCP `resources` capability): a URI-template
  descriptor advertised via `resources/templates/list`. Global entries have nil
  `organization_id`/`project_id`.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "mcp_resource_templates" do
    field :uri_template, :string
    field :name, :string
    field :description, :string
    field :mime_type, :string, default: "text/plain"
    field :organization_id, :binary_id
    field :project_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  def changeset(template, attrs) do
    template
    |> cast(attrs, [:uri_template, :name, :description, :mime_type, :organization_id, :project_id])
    |> update_change(:uri_template, &String.trim/1)
    |> validate_required([:uri_template, :name])
    |> validate_length(:uri_template, max: 2048)
    |> validate_format(:uri_template, ~r/\{\w+\}/,
      message: "must contain at least one {param} placeholder"
    )
  end
end
