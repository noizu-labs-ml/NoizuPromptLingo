defmodule Codefresh.Otel.SamplingPolicy do
  @moduledoc """
  Per-organization OTel sampling policy (US-132). Controls head sampling
  at the receiver edge plus optional tail-sampling rules encoded as JSON.

  `tail_rules` shape (minimal, extensible):

      %{
        "keep_error_traces" => true,
        "keep_run_linked"   => true,
        "drop_services"     => ["noisy-service"]
      }

  `head_sampling_rate` is a decimal 0.0..1.0. `nil` means "no head
  sampling — keep everything".
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "otel_sampling_policies" do
    field :name, :string
    field :head_sampling_rate, :decimal
    field :tail_rules, :map, default: %{}
    field :effective_from, :utc_datetime
    field :metadata, :map, default: %{}
    field :enabled, :boolean, default: true

    belongs_to :organization, Codefresh.Organizations.Organization

    timestamps(type: :utc_datetime)
  end

  def changeset(policy, attrs) do
    policy
    |> cast(attrs, [
      :organization_id,
      :name,
      :head_sampling_rate,
      :tail_rules,
      :effective_from,
      :metadata,
      :enabled
    ])
    |> validate_required([:organization_id, :name])
    |> validate_length(:name, min: 1, max: 120)
    |> validate_rate()
    |> foreign_key_constraint(:organization_id)
  end

  defp validate_rate(cs) do
    case get_change(cs, :head_sampling_rate) do
      nil ->
        cs

      %Decimal{} = d ->
        cond do
          Decimal.compare(d, Decimal.new("0")) == :lt ->
            add_error(cs, :head_sampling_rate, "must be >= 0")

          Decimal.compare(d, Decimal.new("1")) == :gt ->
            add_error(cs, :head_sampling_rate, "must be <= 1")

          true ->
            cs
        end

      _ ->
        add_error(cs, :head_sampling_rate, "must be a decimal between 0 and 1")
    end
  end
end
