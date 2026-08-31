import Config

# Dev: single gateway on 4445 so the live Python proxy on 4443/4444 is untouched.
config :ex_litellm, port: 4445
