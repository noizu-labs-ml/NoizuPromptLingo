defmodule NoizuPromptLingua.Repo do
  use Ecto.Repo,
    otp_app: :noizu_prompt_lingua,
    adapter: Ecto.Adapters.Postgres
end
