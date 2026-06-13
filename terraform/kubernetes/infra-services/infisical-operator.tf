# ---------------------------------------------------------------------------
# Infisical Secrets Operator
# ---------------------------------------------------------------------------
# Provides the secrets.infisical.com CRDs (InfisicalSecret, InfisicalDynamicSecret,
# InfisicalPushSecret, ClusterGenerator) that sync secrets from Infisical into
# Kubernetes. Runs in the shared infra namespace (created by init); the CRDs it
# installs are cluster-scoped, so it still reconciles across all namespaces.
resource "helm_release" "infisical_operator" {
  name             = "infisical-secrets-operator"
  repository       = "https://dl.cloudsmith.io/public/infisical/helm-charts/helm/charts/"
  chart            = "secrets-operator"
  version          = "0.10.23"
  namespace        = local.ns
  create_namespace = false

  # Pin the controller-manager pod to the base node, like every other workload.
  values = [yamlencode({
    controllerManager = {
      nodeSelector = local.node_selector
    }
  })]

  wait    = true
  timeout = 300
}
