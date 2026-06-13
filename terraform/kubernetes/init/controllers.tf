# ---------------------------------------------------------------------------
# Sealed Secrets controller (Bitnami)
# ---------------------------------------------------------------------------
# Provides the SealedSecret CRD. Encrypted SealedSecret manifests (committed to
# git) are unsealed by this controller into real Kubernetes Secrets in-cluster.
#
# Installed into kube-system with the controller named "sealed-secrets-controller"
# so the `kubeseal` CLI works with its defaults (--controller-namespace kube-system
# --controller-name sealed-secrets-controller).
resource "helm_release" "sealed_secrets" {
  name       = "sealed-secrets"
  repository = "https://bitnami-labs.github.io/sealed-secrets"
  chart      = "sealed-secrets"
  version    = "2.18.6"
  namespace  = "kube-system"

  wait    = true
  timeout = 300

  set = [
    {
      name  = "fullnameOverride"
      value = "sealed-secrets-controller"
    },
    # Pin the controller to the base node, like every other workload.
    {
      name  = "nodeSelector.kubernetes\\.io/hostname"
      value = var.minio_node_selector["kubernetes.io/hostname"]
    },
  ]
}

# ---------------------------------------------------------------------------
# Ingress NGINX controller
# ---------------------------------------------------------------------------
# This bare-metal cluster has no LoadBalancer implementation (no MetalLB/kube-vip
# — verified against the cluster backup). The prior working setup ran the
# controller with hostNetwork, binding the node's :80/:443 directly; Cloudflare
# points at the base node (noizu-server / 208.64.36.80). We reproduce that and
# pin the controller there. The Service is ClusterIP, NOT LoadBalancer: a
# LoadBalancer Service would leave helm's `wait` blocked forever on an external
# IP that never gets assigned (the original bootstrap-hang root cause).
resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.15.1"
  namespace        = "ingress-nginx"
  create_namespace = true

  # wait_for_jobs covers the admission-webhook patch Jobs (not just the
  # Deployment); without it `wait` can return before the webhook is ready.
  # Bumped past 10m for image pulls on a fresh node, and cleanup_on_fail so a
  # timed-out install doesn't leave a `failed` release that blocks the retry.
  wait            = true
  wait_for_jobs   = true
  timeout         = 900
  cleanup_on_fail = true

  set = [
    # Bind the node's network namespace directly (host :80/:443) — no LB needed.
    {
      name  = "controller.hostNetwork"
      value = "true"
    },
    # Required with hostNetwork so the controller still resolves cluster DNS.
    {
      name  = "controller.dnsPolicy"
      value = "ClusterFirstWithHostNet"
    },
    # ClusterIP (not LoadBalancer) so helm `wait` doesn't block on an external IP.
    {
      name  = "controller.service.type"
      value = "ClusterIP"
    },
    # Pin to the public base node so host :80/:443 are the ones Cloudflare hits.
    # noizu-server is the only node with public IPs (208.64.36.78-83); the
    # workers are internal-only (10.150.0.0/24), so a controller landing there
    # would bind an unreachable host IP and get zero internet traffic.
    {
      name  = "controller.nodeSelector.kubernetes\\.io/hostname"
      value = "noizu-server"
    },
    # Exactly one replica: only one node can bind the host ports, and with the
    # nodeSelector above any extra replica would sit Pending.
    {
      name  = "controller.replicaCount"
      value = "1"
    },
    # Force Accept-Encoding: identity on upstream requests — what the old MinIO
    # ingress did via a configuration-snippet. We do it here through the chart's
    # managed proxy-set-headers ConfigMap instead, so we avoid enabling
    # allow-snippet-annotations (disabled by default since CVE-2023-5044). This is
    # global (all backends), which is benign behind Cloudflare (compresses at the
    # edge) and stops MinIO's S3 responses being corrupted by a rewritten encoding.
    {
      name  = "controller.proxySetHeaders.Accept-Encoding"
      value = "identity"
    },
    # Treat this as the default class so the MinIO ingresses (className: nginx)
    # are served without extra annotations.
    {
      name  = "controller.ingressClassResource.default"
      value = "true"
    },
  ]
}
