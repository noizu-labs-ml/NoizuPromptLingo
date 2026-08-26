defmodule NoizuPromptLingua.Schema.MarketingSignup do
  @moduledoc """
  A public marketing signup (landing / waitlist email capture). Emails are
  stored lowercased; `promo_awarded` marks founding-promo winners ("2 months
  free"), `waitlisted` marks rows accepted after the beta cap filled (or while
  signups were closed). No auth — this table is written by the anonymous
  public marketing endpoints only.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "marketing_signups" do
    field :email, :string
    field :source, :string, default: "landing"
    field :promo_awarded, :boolean, default: false
    field :waitlisted, :boolean, default: false
    field :metadata, :map, default: %{}

    timestamps(type: :utc_datetime)
  end

  def changeset(signup, attrs) do
    signup
    |> cast(attrs, [:email, :source, :promo_awarded, :waitlisted, :metadata])
    |> validate_required([:email])
    |> unique_constraint(:email, name: :uq_marketing_signups_email)
  end
end
