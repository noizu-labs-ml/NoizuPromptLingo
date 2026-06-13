defmodule Codefresh.Repo do
  use Ecto.Repo,
    otp_app: :codefresh,
    adapter: Ecto.Adapters.Postgres
end
