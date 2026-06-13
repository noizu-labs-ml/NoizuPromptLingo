defmodule Starter.Repo do
  use Ecto.Repo,
    otp_app: :starter,
    adapter: Ecto.Adapters.Postgres
end
