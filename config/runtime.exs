import Config

if url = System.get_env("DATABASE_URL") do
  config :noizu_prompt_lingua, NoizuPromptLingua.Repo, url: url
end
