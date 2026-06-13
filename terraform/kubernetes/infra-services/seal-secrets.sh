#!/usr/bin/env bash
# Generate the infra-services app secrets ONCE, then seal them into committed
# SealedSecrets (secrets/*.sealedsecret.yaml). The sealed files are the source of
# truth — Terraform only applies them (secrets.tf), so an apply can never
# regenerate the values.
#
# This REPLACES the old copy-from-live-cluster approach: that cluster is gone
# (platform-ns / observability-ns / argocd no longer exist), so nothing can be
# kubectl-copied. Only init / infra / infra-services define the platform now.
#
# Value sources, by kind:
#   * shared with infra  — DB passwords + the SigNoz JWT are read from infra's
#     gitignored values.env (single source of truth across modules). Run infra's
#     ./seal-managed-secrets.sh first.
#   * generated once     — app session/secret keys, htpasswd; written to this
#     module's own gitignored values store and reused on re-run (stable values).
#   * external           — Google OAuth, SMTP/SendGrid: cannot be synthesised.
#     Read from an overrides.env you fill in; empty placeholders otherwise (the
#     app deploys, that integration stays inert until you supply real values).
#   * recovered          — the *.noizu.com wildcard TLS (cloudflare-tls-synced)
#     and *.derobot.is wildcard TLS (derobotis-tls) are pulled from the cluster
#     backup and sealed as kubernetes.io/tls secrets.
#
# Requires: kubectl + kubeseal + the sealed-secrets controller (init installs it
# into kube-system as sealed-secrets-controller); openssl; htpasswd or `uv`.
#
#   ./seal-secrets.sh
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(git -C "$HERE" rev-parse --show-toplevel)"

NS="${TARGET_NS:-infra}"
CNS="${CONTROLLER_NS:-kube-system}"
CNAME="${CONTROLLER_NAME:-sealed-secrets-controller}"
OUT="$HERE/secrets"

# Per-module gitignored stores.
STORE="${SVC_SECRETS_STORE:-$REPO_ROOT/.secrets/infra-services}"
VALUES="$STORE/values.env"         # generated-once randoms (reused, stable)
OVERRIDES="$STORE/overrides.env"   # external creds you supply (OAuth/SMTP)
HTPASSWD_FILE="$STORE/verdaccio.htpasswd"

# Shared infra values (DB creds + SigNoz JWT) — produced by infra's sealer.
INFRA_VALUES="${INFRA_SECRETS_STORE:-$REPO_ROOT/.secrets/infra}/values.env"

# Recovered wildcard TLS lands here (plaintext, gitignored).
TLS_DIR="$REPO_ROOT/.secrets/tls/cloudflare.noizu.com"     # *.noizu.com
DEROBOT_TLS_DIR="$REPO_ROOT/.secrets/tls/derobot.is"       # *.derobot.is

# Cluster backup to recover the wildcard cert from.
BACKUP_DIR="${BACKUP_DIR:-$(ls -d "$HERE"/../cluster-backup-noizu-* 2>/dev/null | sort | tail -1)}"

PG_HOST="infra-timescaledb.${NS}.svc.cluster.local"

rand() { LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c "$1"; }

mkdir -p "$STORE" "$OUT" "$TLS_DIR" "$DEROBOT_TLS_DIR"
chmod 700 "$STORE" 2>/dev/null || true

# --- shared infra values (required) ----------------------------------------
if [[ ! -f "$INFRA_VALUES" ]]; then
  echo "ERROR: $INFRA_VALUES not found." >&2
  echo "       Run ../infra/seal-managed-secrets.sh first (it generates the DB" >&2
  echo "       passwords + SIGNOZ_TOKENIZER_JWT_SECRET this module reuses)." >&2
  exit 1
fi
# shellcheck disable=SC1090
source "$INFRA_VALUES"
: "${AUTHENTIK_DB_PASSWORD:?missing in infra values.env — add AUTHENTIK to infra and re-seal}"
: "${PHOENIX_DB_PASSWORD:?missing in infra values.env}"
: "${POSTHOG_DB_PASSWORD:?missing in infra values.env}"
: "${INFISICAL_DB_PASSWORD:?missing in infra values.env — add INFISICAL to infra and re-seal}"
: "${SIGNOZ_TOKENIZER_JWT_SECRET:?missing in infra values.env}"

# --- generated-once randoms (top up missing keys, never rewrite) -----------
touch "$VALUES"; chmod 600 "$VALUES"
ensure() {  # KEY VALUE
  local key="$1" val="$2"
  grep -q "^${key}=" "$VALUES" || { printf '%s=%s\n' "$key" "$val" >> "$VALUES"; echo "   + $key"; }
}
ensure AUTHENTIK_SECRET_KEY       "$(rand 50)"
ensure AUTHENTIK_BOOTSTRAP_PASSWORD "$(rand 24)"
ensure PHOENIX_SECRET             "$(rand 32)"
ensure PHOENIX_ADMIN_SECRET       "$(rand 32)"
ensure POSTHOG_SECRET_KEY         "$(rand 50)"
ensure INFISICAL_ENCRYPTION_KEY   "$(openssl rand -hex 16)"     # 32 hex chars (128-bit)
ensure INFISICAL_AUTH_SECRET      "$(openssl rand -base64 32)"
ensure VERDACCIO_USERNAME         "noizu"
ensure VERDACCIO_PASSWORD         "$(rand 24)"
# shellcheck disable=SC1090
source "$VALUES"

# --- external overrides (you fill these in; empty = integration inert) ------
if [[ ! -f "$OVERRIDES" ]]; then
  cat > "$OVERRIDES" <<EOF
# infra-services external credentials — fill in, then re-run ./seal-secrets.sh.
# Left empty, the app still deploys; the integration just stays inactive.
# Extract these from the canonical dc store (.envrc.dc): per-service SendGrid
# keys live under secrets.sendgrid.<service>; Phoenix OAuth under
# services.telemetry.phoenix_oauth2_google_*.
ADMIN_EMAIL=keith.brings@noizu.com
MAIL_FROM=no-reply@noizu.com

# SendGrid — per-service keys (dc: secrets.sendgrid.authentik / .phoenix / .infisical).
# SENDGRID_API_KEY is the shared fallback if a per-service key is unset.
SENDGRID_API_KEY=
SENDGRID_API_KEY_AUTHENTIK=
SENDGRID_API_KEY_PHOENIX=
SENDGRID_API_KEY_INFISICAL=

# Google OAuth for Phoenix login (dc: services.telemetry.phoenix_oauth2_google_*).
PHOENIX_OAUTH2_GOOGLE_CLIENT_ID=
PHOENIX_OAUTH2_GOOGLE_CLIENT_SECRET=
EOF
  chmod 600 "$OVERRIDES"
  echo ">> wrote override template $OVERRIDES (fill in external creds, re-run to bake them in)"
fi
# shellcheck disable=SC1090
source "$OVERRIDES"
: "${ADMIN_EMAIL:=admin@noizu.com}"
: "${MAIL_FROM:=no-reply@noizu.com}"
: "${SENDGRID_API_KEY:=}"
: "${SENDGRID_API_KEY_AUTHENTIK:=$SENDGRID_API_KEY}"   # per-service, fall back to shared
: "${SENDGRID_API_KEY_PHOENIX:=$SENDGRID_API_KEY}"
: "${SENDGRID_API_KEY_INFISICAL:=$SENDGRID_API_KEY}"
: "${PHOENIX_OAUTH2_GOOGLE_CLIENT_ID:=}"
: "${PHOENIX_OAUTH2_GOOGLE_CLIENT_SECRET:=}"

# bcrypt htpasswd for verdaccio (key "htpasswd"; $ chars kept out of values.env).
if [[ ! -f "$HTPASSWD_FILE" ]]; then
  if command -v htpasswd > /dev/null; then
    htpasswd -nbBC 10 "$VERDACCIO_USERNAME" "$VERDACCIO_PASSWORD" > "$HTPASSWD_FILE"
  else
    uv run --with bcrypt python - "$VERDACCIO_USERNAME" "$VERDACCIO_PASSWORD" > "$HTPASSWD_FILE" <<'PY'
import sys, bcrypt
u, p = sys.argv[1], sys.argv[2]
print(f"{u}:" + bcrypt.hashpw(p.encode(), bcrypt.gensalt(10)).decode())
PY
  fi
  chmod 600 "$HTPASSWD_FILE"
fi
VERDACCIO_HTPASSWD="$(cat "$HTPASSWD_FILE")"

# --- recover wildcard TLS secrets from the cluster backup -------------------
# Pull a kubernetes.io/tls Secret out of the backup by name into <dir>/cert.pem
# + key.pem. Searches the per-namespace secrets/*.yaml dumps first, then the
# combined namespaced/secrets.yaml List (derobotis-tls only lives in the latter).
recover_tls() {  # <secret-name> <out-dir>
  local name="$1" dir="$2"
  [[ -s "$dir/cert.pem" && -s "$dir/key.pem" ]] && return 0
  [[ -d "$BACKUP_DIR" ]] || { echo "ERROR: no cluster backup dir (set BACKUP_DIR=...)" >&2; exit 1; }
  echo ">> recovering $name from $(basename "$BACKUP_DIR")"
  uv run --with pyyaml python - "$BACKUP_DIR" "$dir" "$name" <<'PY'
import sys, os, glob, base64, yaml
backup, out, name = sys.argv[1], sys.argv[2], sys.argv[3]
def docs():
    files = sorted(glob.glob(os.path.join(backup, "secrets", "*.yaml"))) \
          + sorted(glob.glob(os.path.join(backup, "namespaced", "secrets.yaml")))
    for f in files:
        with open(f) as fh:
            for d in yaml.safe_load_all(fh):
                if not d: continue
                for item in (d.get("items", [d]) if d.get("kind") == "List" else [d]):
                    yield item
for s in docs():
    if (s.get("kind") == "Secret"
            and s.get("metadata", {}).get("name") == name
            and s.get("type") == "kubernetes.io/tls"):
        data = s["data"]
        open(os.path.join(out, "cert.pem"), "wb").write(base64.b64decode(data["tls.crt"]))
        open(os.path.join(out, "key.pem"),  "wb").write(base64.b64decode(data["tls.key"]))
        print("   recovered tls.crt + tls.key")
        sys.exit(0)
sys.exit("ERROR: %s (kubernetes.io/tls) not found in backup" % name)
PY
  chmod 600 "$dir/key.pem"
}

recover_tls cloudflare-tls-synced "$TLS_DIR"          # *.noizu.com
recover_tls derobotis-tls         "$DEROBOT_TLS_DIR"  # *.derobot.is

# --- seal -------------------------------------------------------------------
seal() {  # <name> <kubectl create secret generic args...>
  kubectl create secret generic "$1" -n "$NS" "${@:2}" --dry-run=client -o yaml \
    | kubeseal --controller-namespace "$CNS" --controller-name "$CNAME" --format yaml \
    > "$OUT/$1.sealedsecret.yaml"
  echo "   sealed $1"
}
seal_tls() {  # <name> <cert> <key>
  kubectl create secret tls "$1" -n "$NS" --cert="$2" --key="$3" --dry-run=client -o yaml \
    | kubeseal --controller-namespace "$CNS" --controller-name "$CNAME" --format yaml \
    > "$OUT/$1.sealedsecret.yaml"
  echo "   sealed $1 (tls)"
}

echo ">> sealing into $OUT (controller $CNS/$CNAME, ns $NS)"

# Authentik connection config (non-secret; envFrom). Creds come from
# authentik-secrets (below) and authentik-valkey (init-owned, valkey-users.tf).
seal authentik \
  --from-literal=AUTHENTIK_POSTGRESQL__HOST="$PG_HOST" \
  --from-literal=AUTHENTIK_POSTGRESQL__PORT="5432" \
  --from-literal=AUTHENTIK_POSTGRESQL__NAME="authentik" \
  --from-literal=AUTHENTIK_REDIS__HOST="infra-valkey" \
  --from-literal=AUTHENTIK_REDIS__PORT="6379" \
  --from-literal=AUTHENTIK_EMAIL__HOST="smtp.sendgrid.net" \
  --from-literal=AUTHENTIK_EMAIL__PORT="587" \
  --from-literal=AUTHENTIK_EMAIL__USERNAME="apikey" \
  --from-literal=AUTHENTIK_EMAIL__USE_TLS="true" \
  --from-literal=AUTHENTIK_EMAIL__FROM="$MAIL_FROM"

seal authentik-secrets \
  --from-literal=AUTHENTIK_DB_USER="${AUTHENTIK_DB_USER:-authentik}" \
  --from-literal=AUTHENTIK_DB_PASSWORD="$AUTHENTIK_DB_PASSWORD" \
  --from-literal=AUTHENTIK_SECRET_KEY="$AUTHENTIK_SECRET_KEY" \
  --from-literal=AUTHENTIK_BOOTSTRAP_PASSWORD="$AUTHENTIK_BOOTSTRAP_PASSWORD" \
  --from-literal=AUTHENTIK_BOOTSTRAP_EMAIL="$ADMIN_EMAIL" \
  --from-literal=SENDGRID_API_KEY="$SENDGRID_API_KEY_AUTHENTIK"

seal phoenix-secrets \
  --from-literal=PHOENIX_DATABASE_URL="postgresql://${PHOENIX_DB_USER:-phoenix}:${PHOENIX_DB_PASSWORD}@${PG_HOST}:5432/phoenix" \
  --from-literal=PHOENIX_SECRET="$PHOENIX_SECRET" \
  --from-literal=PHOENIX_ADMIN_SECRET="$PHOENIX_ADMIN_SECRET" \
  --from-literal=PHOENIX_OAUTH2_GOOGLE_CLIENT_ID="$PHOENIX_OAUTH2_GOOGLE_CLIENT_ID" \
  --from-literal=PHOENIX_OAUTH2_GOOGLE_CLIENT_SECRET="$PHOENIX_OAUTH2_GOOGLE_CLIENT_SECRET" \
  --from-literal=PHOENIX_SMTP_HOSTNAME="smtp.sendgrid.net" \
  --from-literal=PHOENIX_SMTP_USERNAME="apikey" \
  --from-literal=PHOENIX_SMTP_PASSWORD="$SENDGRID_API_KEY_PHOENIX" \
  --from-literal=PHOENIX_SMTP_MAIL_FROM="$MAIL_FROM"

seal posthog-secrets \
  --from-literal=POSTHOG_DATABASE_URL="postgresql://${POSTHOG_DB_USER:-posthog}:${POSTHOG_DB_PASSWORD}@${PG_HOST}:5432/posthog" \
  --from-literal=POSTHOG_SECRET_KEY="$POSTHOG_SECRET_KEY"

# Infisical uses the shared infra-timescaledb (DB "infisical"). REDIS_URL is NOT
# sealed here — it's built in Terraform (infisical.tf) from init's valkey password.
seal infisical-core-secrets \
  --from-literal=ENCRYPTION_KEY="$INFISICAL_ENCRYPTION_KEY" \
  --from-literal=AUTH_SECRET="$INFISICAL_AUTH_SECRET" \
  --from-literal=DB_CONNECTION_URI="postgresql://${INFISICAL_DB_USER:-infisical}:${INFISICAL_DB_PASSWORD}@${PG_HOST}:5432/infisical" \
  --from-literal=SMTP_HOST="smtp.sendgrid.net" \
  --from-literal=SMTP_USERNAME="apikey" \
  --from-literal=SMTP_PASSWORD="$SENDGRID_API_KEY_INFISICAL" \
  --from-literal=SMTP_PORT="587" \
  --from-literal=SMTP_FROM_ADDRESS="no-reply@noizu.com" \
  --from-literal=SMTP_FROM_NAME="Infisical"

seal signoz-secrets \
  --from-literal=SIGNOZ_TOKENIZER_JWT_SECRET="$SIGNOZ_TOKENIZER_JWT_SECRET"

seal verdaccio-htpasswd --from-literal=htpasswd="$VERDACCIO_HTPASSWD"

seal_tls cloudflare-tls-synced "$TLS_DIR/cert.pem" "$TLS_DIR/key.pem"
seal_tls derobotis-tls "$DEROBOT_TLS_DIR/cert.pem" "$DEROBOT_TLS_DIR/key.pem"

echo
echo "Done. Commit the *.sealedsecret.yaml files in $OUT."
echo "Plaintext (gitignored): $VALUES  +  $OVERRIDES"
[[ -z "$SENDGRID_API_KEY_AUTHENTIK" ]] && echo "NOTE: Authentik SendGrid key empty — Authentik email inert until you fill $OVERRIDES and re-run."
[[ -z "$SENDGRID_API_KEY_PHOENIX" ]] && echo "NOTE: Phoenix SendGrid key empty — Phoenix SMTP inert until you fill $OVERRIDES and re-run."
[[ -z "$SENDGRID_API_KEY_INFISICAL" ]] && echo "NOTE: Infisical SendGrid key empty — Infisical SMTP inert until you fill $OVERRIDES and re-run."
[[ -z "$PHOENIX_OAUTH2_GOOGLE_CLIENT_ID" ]] && echo "NOTE: Google OAuth empty — Phoenix Google login inert until you fill $OVERRIDES and re-run."
echo "Verdaccio login: ${VERDACCIO_USERNAME} / ${VERDACCIO_PASSWORD}"
echo "Authentik admin: ${ADMIN_EMAIL} / ${AUTHENTIK_BOOTSTRAP_PASSWORD}"
