resource "kubernetes_namespace_v1" "longhorn" {
  metadata {
    name = "longhorn-system"
  }
}

resource "helm_release" "longhorn" {
  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  version    = "1.12.0"
  namespace  = kubernetes_namespace_v1.longhorn.metadata[0].name

  # Longhorn pulls several images and rolls out CSI + instance-manager
  # DaemonSets on every node; on a fresh/single node this routinely exceeds
  # 10m. cleanup_on_fail removes partial objects so a retry isn't blocked by a
  # release stuck in `failed` status.
  timeout         = 1200
  wait            = true
  cleanup_on_fail = true

  set = [
    {
      name  = "defaultSettings.defaultDataPath"
      value = "/var/lib/longhorn"
    },
    {
      name  = "persistence.defaultClassReplicaCount"
      value = "1"
    },
  ]
}
