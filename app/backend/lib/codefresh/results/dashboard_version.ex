defmodule Codefresh.Results.DashboardVersion do
  @moduledoc """
  Immutable snapshot of a dashboard layout. `layout` is a JSON map describing
  widgets + filters (US-130). Checksum is sha256 over the canonicalized layout
  so identical re-saves are no-ops. Mirrors migration
  `20260421000031_create_dashboards_and_versions.exs`.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "dashboard_versions" do
    field :version_number, :integer
    field :checksum, :binary
    field :layout, :map, default: %{}

    belongs_to :dashboard, Codefresh.Results.Dashboard
    belongs_to :organization, Codefresh.Organizations.Organization

    belongs_to :published_by, Codefresh.Accounts.User,
      foreign_key: :published_by_user_id

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def create_changeset(dv, attrs) do
    dv
    |> cast(attrs, [
      :dashboard_id,
      :organization_id,
      :version_number,
      :checksum,
      :layout,
      :published_by_user_id
    ])
    |> validate_required([:dashboard_id, :organization_id, :version_number, :checksum, :layout])
    |> validate_number(:version_number, greater_than: 0)
    |> unique_constraint([:dashboard_id, :version_number])
    |> foreign_key_constraint(:dashboard_id)
    |> foreign_key_constraint(:organization_id)
  end

  @doc """
  Canonicalize the layout JSON and return its sha256.
  """
  def compute_checksum(%{} = layout) do
    canonical = :erlang.term_to_binary(canonicalize(layout))
    :crypto.hash(:sha256, canonical)
  end

  defp canonicalize(m) when is_map(m) do
    m
    |> Enum.map(fn {k, v} -> {to_string(k), canonicalize(v)} end)
    |> Enum.sort_by(fn {k, _} -> k end)
  end

  defp canonicalize(l) when is_list(l), do: Enum.map(l, &canonicalize/1)
  defp canonicalize(v), do: v
end
