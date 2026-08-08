defmodule Noizu.PM.Schema.Organizations.InviteTokenRedemption do
  @moduledoc """
  One row per invite-token use — audit trail for multi-use invites, where
  `invite_tokens.accepted_by/accepted_at` only ever reflect the most recent
  redemption. Plain Ecto schema (no `Noizu.Entity` wrapper): host apps insert
  directly via `Noizu.PM.Organizations.InviteTokens.redeem/3`.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "invite_token_redemptions" do
    belongs_to :invite_token, Noizu.PM.Schema.Organizations.InviteToken, type: Ecto.UUID
    belongs_to :user, Noizu.PM.Schema.Users.User, type: Ecto.UUID
    field :redeemed_at, :utc_datetime_usec
    field :remote_ip, :string
    field :user_agent, :string
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(redemption, attrs) do
    redemption
    |> cast(attrs, [:invite_token_id, :user_id, :redeemed_at, :remote_ip, :user_agent])
    |> validate_required([:invite_token_id, :user_id, :redeemed_at])
  end
end
