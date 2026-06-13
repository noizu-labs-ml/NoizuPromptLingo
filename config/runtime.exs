import Config

if url = System.get_env("DATABASE_URL") do
  config :noizu_prompt_lingua, NoizuPromptLingua.Repo, url: url
end

if secret = System.get_env("SECRET_KEY_BASE") do
  config :noizu_prompt_lingua, NPLWeb.Endpoint, secret_key_base: secret
end

if port = System.get_env("PORT") do
  config :noizu_prompt_lingua, NPLWeb.Endpoint, http: [port: String.to_integer(port)]
end
