#!/usr/bin/env bash
# Recover the ops.noizu.com registry TLS cert+key from a cluster backup into the
# central secrets store (<repo>/.secrets/tls/ops.noizu.com/, gitignored).
#
# The previous cluster — and its platform-ns/ops-noizu-com-tls secret — is gone,
# so the committed backup is the source of truth. Writes cert.pem (full chain)
# and key.pem. Seal them for the live cluster afterwards with ./seal-secrets.sh.
#
#   ./recover-ops-tls.sh [path/to/cluster-backup-dir]
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(git -C "$HERE" rev-parse --show-toplevel)"

BACKUP="${1:-$(ls -d "$HERE"/../cluster-backup-*/ 2>/dev/null | sort | tail -1)}"
BACKUP="${BACKUP%/}"
SRC="$BACKUP/namespaced/secrets.yaml"
OUT_DIR="${OPS_TLS_DIR:-$REPO_ROOT/.secrets/tls/ops.noizu.com}"

[[ -f "$SRC" ]] || { echo "Secrets dump not found: $SRC" >&2; exit 1; }
mkdir -p "$OUT_DIR"

uv run --with pyyaml python - "$SRC" "$OUT_DIR" <<'PY'
import base64, sys, pathlib, yaml
src, out = sys.argv[1], pathlib.Path(sys.argv[2])
items = []
for doc in yaml.safe_load_all(open(src)):
    if doc:
        items += doc.get("items", [doc])
for s in items:
    md = s.get("metadata", {})
    if md.get("name") == "ops-noizu-com-tls" and md.get("namespace") == "platform-ns":
        data = s["data"]
        (out / "cert.pem").write_bytes(base64.b64decode(data["tls.crt"]))
        (out / "key.pem").write_bytes(base64.b64decode(data["tls.key"]))
        print(f"wrote {out}/cert.pem + {out}/key.pem")
        break
else:
    sys.exit("ops-noizu-com-tls (platform-ns) not found in backup")
PY

chmod 600 "$OUT_DIR/key.pem"
echo "Recovered ops.noizu.com TLS into $OUT_DIR"