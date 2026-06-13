defmodule Codefresh.Prompts.PromptVersion do
  @moduledoc """
  Immutable version of a prompt. Created by `Prompts.publish_version/2`.
  `version_number` is monotonically assigned; `checksum` dedupes identical bodies.

  `template_vars` shape:

      %{
        "var_name" => %{
          "description" => "...",
          "default"     => "fallback value",
          "required"    => true
        },
        ...
      }

  Every `{{var}}` appearing in the body must have a matching key in
  `template_vars`; enforcement happens in `Prompts.publish_version/2`.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "prompt_versions" do
    field :version_number, :integer
    field :body, :string
    field :template_vars, :map, default: %{}
    field :tool_defs, :map, default: %{}
    field :metadata, :map, default: %{}
    field :checksum, :binary

    belongs_to :prompt, Codefresh.Prompts.Prompt
    belongs_to :organization, Codefresh.Organizations.Organization
    belongs_to :published_by, Codefresh.Accounts.User, foreign_key: :published_by_user_id

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def create_changeset(pv, attrs) do
    pv
    |> cast(attrs, [
      :prompt_id,
      :organization_id,
      :version_number,
      :body,
      :template_vars,
      :tool_defs,
      :metadata,
      :checksum,
      :published_by_user_id
    ])
    |> validate_required([:prompt_id, :organization_id, :version_number, :body, :checksum])
    |> validate_number(:version_number, greater_than: 0)
    |> unique_constraint([:prompt_id, :version_number])
    |> unique_constraint([:prompt_id, :checksum])
    |> foreign_key_constraint(:prompt_id)
    |> foreign_key_constraint(:organization_id)
  end

  @doc "SHA-256 checksum of the canonical representation of a version's body + metadata."
  def compute_checksum(body, template_vars, tool_defs) do
    canonical =
      [
        body,
        stable_encode(template_vars),
        stable_encode(tool_defs)
      ]
      |> Enum.join("\n---\n")

    :crypto.hash(:sha256, canonical)
  end

  defp stable_encode(map) when is_map(map) do
    map
    |> Enum.sort_by(fn {k, _} -> to_string(k) end)
    |> Enum.map_join("\n", fn {k, v} -> "#{k}=#{inspect(v, limit: :infinity)}" end)
  end

  defp stable_encode(_), do: ""
end
