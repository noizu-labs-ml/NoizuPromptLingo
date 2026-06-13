defmodule Boe.Repo do
  use Ecto.Repo,
    otp_app: :boe,
    adapter: Ecto.Adapters.Postgres
end
