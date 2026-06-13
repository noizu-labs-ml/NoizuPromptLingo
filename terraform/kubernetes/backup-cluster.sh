#!/usr/bin/env bash
#
# Full cluster backup before a destroy/rebuild.
# Dumps every API resource (namespaced + cluster-scoped) to per-resource YAML,
# with extra emphasis on Secrets (TLS certs, sealed-secrets, etc).
#
# Usage:  ./backup-cluster.sh [output-dir]
#
set -euo pipefail

CONTEXT="$(kubectl config current-context)"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT="${1:-cluster-backup-${CONTEXT}-${STAMP}}"

echo ">> Context : ${CONTEXT}"
echo ">> Output  : ${OUT}/"
mkdir -p "${OUT}"/{namespaced,cluster,secrets,crds,raw}

# ----------------------------------------------------------------------------
# 1. A single raw "everything" dump (fast safety net, re-appliable-ish)
# ----------------------------------------------------------------------------
echo ">> [1/5] Raw all-namespaces dump of namespaced resources..."
NS_KINDS="$(kubectl api-resources --verbs=list --namespaced -o name | paste -sd, -)"
kubectl get "${NS_KINDS}" --all-namespaces -o yaml > "${OUT}/raw/namespaced-all.yaml" 2>/dev/null || true

echo ">> [1/5] Raw dump of cluster-scoped resources..."
CL_KINDS="$(kubectl api-resources --verbs=list --namespaced=false -o name | paste -sd, -)"
kubectl get "${CL_KINDS}" -o yaml > "${OUT}/raw/cluster-all.yaml" 2>/dev/null || true

# ----------------------------------------------------------------------------
# 2. Secrets — the thing you're most worried about. One file per namespace.
# ----------------------------------------------------------------------------
echo ">> [2/5] Dumping Secrets per namespace..."
for ns in $(kubectl get ns -o name | cut -d/ -f2); do
  if kubectl get secrets -n "${ns}" -o name 2>/dev/null | grep -q .; then
    kubectl get secrets -n "${ns}" -o yaml > "${OUT}/secrets/${ns}.yaml"
  fi
done

echo ">> [2/5] Listing all TLS-type secrets for quick review..."
kubectl get secrets --all-namespaces \
  --field-selector type=kubernetes.io/tls \
  -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,EXPIRES:.metadata.annotations.cert-manager\.io/certificate-name' \
  > "${OUT}/secrets/_tls-secrets-index.txt" 2>/dev/null || true

# cert-manager Certificate objects (if the CRD exists)
if kubectl get crd certificates.cert-manager.io >/dev/null 2>&1; then
  kubectl get certificates,certificaterequests,issuers,clusterissuers \
    --all-namespaces -o yaml > "${OUT}/secrets/_cert-manager-objects.yaml" 2>/dev/null || true
fi

# ----------------------------------------------------------------------------
# 3. CRD definitions (the schemas themselves)
# ----------------------------------------------------------------------------
echo ">> [3/5] Dumping CRD definitions..."
kubectl get crds -o yaml > "${OUT}/crds/_all-crds.yaml" 2>/dev/null || true

# ----------------------------------------------------------------------------
# 4. Per-resource-kind namespaced dump (easy to browse / diff against TF)
# ----------------------------------------------------------------------------
echo ">> [4/5] Per-kind namespaced dumps..."
for kind in $(kubectl api-resources --verbs=list --namespaced -o name); do
  safe="${kind//\//_}"
  kubectl get "${kind}" --all-namespaces -o yaml > "${OUT}/namespaced/${safe}.yaml" 2>/dev/null || true
done

# ----------------------------------------------------------------------------
# 5. Per-resource-kind cluster-scoped dump
# ----------------------------------------------------------------------------
echo ">> [5/5] Per-kind cluster-scoped dumps..."
for kind in $(kubectl api-resources --verbs=list --namespaced=false -o name); do
  safe="${kind//\//_}"
  kubectl get "${kind}" -o yaml > "${OUT}/cluster/${safe}.yaml" 2>/dev/null || true
done

# Prune empty files so the tree only shows what actually exists
find "${OUT}" -type f -name '*.yaml' -size -1c -delete 2>/dev/null || true
# (a "no resources" dump is usually a few bytes; also strip those)
find "${OUT}/namespaced" "${OUT}/cluster" -type f -name '*.yaml' \
  -exec grep -L 'kind:' {} \; 2>/dev/null | xargs -r rm -f

echo ""
echo ">> Done. Backup written to: ${OUT}/"
echo ">> Secret files (KEEP THESE SAFE — base64, not encrypted):"
ls -1 "${OUT}/secrets/" 2>/dev/null | sed 's/^/     /'
echo ""
echo ">> TLS secrets found:"
cat "${OUT}/secrets/_tls-secrets-index.txt" 2>/dev/null | sed 's/^/     /' || echo "     (none)"
