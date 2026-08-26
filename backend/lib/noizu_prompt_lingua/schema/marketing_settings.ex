defmodule NoizuPromptLingua.Schema.MarketingSettings do
  @moduledoc """
  Admin-editable marketing knobs — a singleton row (id = 1, seeded by
  Liquibase 077). Two INDEPENDENT caps:

    * `beta_signup_cap` — max accepted (non-waitlisted) signups; NULL = unlimited
    * `promo_cap` — max founding-promo awards; NULL = unlimited

  `signups_open` is the master acceptance switch (closed => waitlist mode),
  `promo_active` toggles promo awarding without touching the cap counter.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :integer, autogenerate: false}
  @singleton_id 1

  schema "marketing_settings" do
    field :beta_signup_cap, :integer
    field :promo_cap, :integer
    field :signups_open, :boolean, default: true
    field :promo_active, :boolean, default: true

    timestamps(type: :utc_datetime, updated_at: :updated_at, inserted_at: false)
  end

  def singleton_id, do: @singleton_id

  def changeset(settings, attrs) do
    settings
    |> cast(attrs, [:beta_signup_cap, :promo_cap, :signups_open, :promo_active])
    |> validate_number(:beta_signup_cap, greater_than_or_equal_to: 0)
    |> validate_number(:promo_cap, greater_than_or_equal_to: 0)
  end
end
