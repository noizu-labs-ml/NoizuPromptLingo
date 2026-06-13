defmodule Derobot.Repo do
  use Ecto.Repo,
    otp_app: :derobot,
    adapter: Ecto.Adapters.Postgres
end
