defmodule NoizuPromptLingua.Schema.MCPCustomScope do
  @moduledoc """
  Admin-managed preset that exposes selected MCP domain tool groups as one
  custom MCP endpoint.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "mcp_custom_scopes" do
    field :slug, :string
    field :name, :string
    field :description, :string
    field :config, :map, default: %{}

    timestamps(type: :utc_datetime)
  end

  def changeset(scope, attrs) do
    scope
    |> cast(attrs, [:slug, :name, :description, :config])
    |> update_change(:slug, &normalize_slug/1)
    |> validate_required([:slug, :name])
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9-]{0,62}$/)
    |> validate_change(:config, &validate_config/2)
    |> unique_constraint(:slug, name: :uq_mcp_custom_scopes_slug)
  end

  defp normalize_slug(nil), do: nil

  defp normalize_slug(slug) when is_binary(slug) do
    slug
    |> String.trim()
    |> String.downcase()
  end

  defp validate_config(:config, value) when is_map(value), do: []
  defp validate_config(:config, _), do: [config: "must be an object"]
end
