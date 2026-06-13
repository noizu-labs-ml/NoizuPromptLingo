# Production environment seeds.
# Invoked via Code.eval_file when Mix.env() == :prod.
#
# Produces ONE bootstrap invite token with no organization binding. The redeemer
# creates their own organization via `POST /api/v1/auth/register` and becomes
# its owner.
#
# The raw token is printed to STDOUT exactly once. Capture it from deployment
# logs immediately — recovery is impossible after the deploy log rotates.
#
# Optional env var:
#
#     CODEFRESH_BOOTSTRAP_EMAIL=founder@example.com   # binds invite to this email

require SeedHelper
import SeedHelper

alias Codefresh.Accounts

seed {"prod_bootstrap_invite", "1"} do
  bootstrap_email = System.get_env("CODEFRESH_BOOTSTRAP_EMAIL")

  base_attrs = %{
    role: "owner",
    max_uses: 1,
    expires_at:
      DateTime.utc_now()
      |> DateTime.add(7 * 24 * 3600, :second)
      |> DateTime.truncate(:second),
    metadata: %{"kind" => "prod-bootstrap"}
  }

  attrs =
    if bootstrap_email, do: Map.put(base_attrs, :email, bootstrap_email), else: base_attrs

  {:ok, _invite, raw_token} = Accounts.create_invite_token(attrs)

  banner = String.duplicate("=", 60)

  IO.puts("")
  IO.puts(banner)
  IO.puts("CODEFRESH PROD BOOTSTRAP INVITE")
  IO.puts(banner)
  IO.puts("Role:       owner (will create a fresh org on redemption)")
  IO.puts("Email:      #{bootstrap_email || "(any)"}")
  IO.puts("Max uses:   1")
  IO.puts("Expires:    #{attrs.expires_at}")
  IO.puts("")
  IO.puts("Raw token (one-time, save NOW — not recoverable):")
  IO.puts("")
  IO.puts("  #{raw_token}")
  IO.puts("")
  IO.puts(banner)
  IO.puts("")
end
