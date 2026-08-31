defmodule NoizuPromptLingua.Schema.MCP.McpPrompt do
  @moduledoc """
  A versioned MCP prompt template (MCP `prompts` capability). The row holds the
  prompt identity + metadata and points at the active version; immutable bodies
  live in `NoizuPromptLingua.Schema.MCP.McpPromptVersion` (new edits create a
  new version, never mutate in place).

  Global prompts have nil `organization_id`/`project_id`; org- and
  project-scoped prompts shadow the global one for their scope.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "mcp_prompts" do
    field :slug, :string
    field :name, :string
    field :description, :string
    # [%{"name" => ..., "description" => ..., "required" => bool}]
    field :arguments, {:array, :map}, default: []
    field :active_version, :integer, default: 1
    field :organization_id, :binary_id
    field :project_id, :binary_id

    timestamps(type: :utc_datetime)

    has_many :versions, NoizuPromptLingua.Schema.MCP.McpPromptVersion,
      foreign_key: :prompt_id,
      on_delete: :delete_all
  end

  def changeset(prompt, attrs) do
    prompt
    |> cast(attrs, [
      :slug,
      :name,
      :description,
      :arguments,
      :active_version,
      :organization_id,
      :project_id
    ])
    |> update_change(:slug, &normalize_slug/1)
    |> validate_required([:slug, :name])
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9_-]{0,62}$/)
    |> validate_change(:arguments, &validate_arguments/2)
    |> unique_constraint(:slug, name: :uq_mcp_prompts_slug)
  end

  defp normalize_slug(nil), do: nil

  defp normalize_slug(slug) when is_binary(slug) do
    slug |> String.trim() |> String.downcase()
  end

  defp validate_arguments(:arguments, value) when is_list(value) do
    bad =
      Enum.reject(value, fn
        %{"name" => name} when is_binary(name) -> true
        %{name: name} when is_binary(name) -> true
        _ -> false
      end)

    if bad == [], do: [], else: [arguments: "each argument must have a string name"]
  end

  defp validate_arguments(:arguments, _), do: [arguments: "must be a list"]
end
