defmodule Codefresh.Runs.RunPersona do
  @moduledoc """
  Join row pinning a persona_version to a run. Supports multi-persona fan-out
  (US-052): a run can reference N persona versions. Persona attachment is
  driven either through `Codefresh.Personas.attach_to_run/3` (US-036) or at
  `trigger_run/3` time via the `persona_version_ids` option.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "run_personas" do
    belongs_to :run, Codefresh.Runs.Run
    belongs_to :persona_version, Codefresh.Personas.PersonaVersion
    belongs_to :organization, Codefresh.Organizations.Organization

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def create_changeset(rp, attrs) do
    rp
    |> cast(attrs, [:run_id, :persona_version_id, :organization_id])
    |> validate_required([:run_id, :persona_version_id, :organization_id])
    |> unique_constraint([:run_id, :persona_version_id])
    |> foreign_key_constraint(:run_id)
    |> foreign_key_constraint(:persona_version_id)
    |> foreign_key_constraint(:organization_id)
  end
end
