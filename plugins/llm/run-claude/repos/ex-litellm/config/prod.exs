import Config

# Prod: cutover port — the gateway on 4443, where Claude Code already points
# (run-claude sets ANTHROPIC_BASE_URL=http://127.0.0.1:4443). The unified
# gateway replaces both the Python front proxy (4443) and the litellm tier.
config :ex_litellm, port: 4443
