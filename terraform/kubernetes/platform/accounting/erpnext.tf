# ---------------------------------------------------------------------------
# ERPNext — deployed via the upstream erpnext subchart (helm_release).
# The umbrella chart owned the shared "sites" PVC (passed as existingClaim), so
# we create it here.
#
# Storage: the chart wants the sites volume ReadWriteMany so its components can
# spread across nodes. Longhorn RWX requires NFS (nfs-utils / mount.nfs) on the
# host nodes, which the NixOS nodes do not currently provide — so RWX mounts
# fail with "nsenter: failed to execute mount" (exit 127). Until the nodes ship
# nfs-utils, we run the sites volume ReadWriteOnce and pin every pod that mounts
# it (nginx, workers, socketio, and the init jobs) to a single node so they can
# share the RWO volume. Flip back to RWX + drop erpnext_pin once nodes have NFS.
# ---------------------------------------------------------------------------
locals {
  # Single node all sites-volume consumers are pinned to (RWO co-location).
  # Co-located with the erpnext mariadb StatefulSet.
  erpnext_pin = { "kubernetes.io/hostname" = "k8s-mvm-2" }
}

# Original RWX claim. Left in place (not destroyed) because it is still
# referenced by the running pods; replacing it in-place would block on its
# consumers. The chart now points at erpnext_sites_rwo below. This claim can be
# removed manually once RWX (node nfs-utils) is restored or it is confirmed idle.
resource "kubernetes_persistent_volume_claim_v1" "erpnext_sites" {
  metadata {
    name      = "erpnext-sites"
    namespace = var.namespace
    labels    = { app = "erpnext" }
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = var.erpnext_sites_size }
    }
  }
  wait_until_bound = false

  depends_on = [kubernetes_namespace_v1.accounting]
}

# RWO sites claim used while the nodes lack nfs-utils for Longhorn RWX. All
# pods that mount it are pinned to local.erpnext_pin (single node) so they can
# share a ReadWriteOnce volume.
resource "kubernetes_persistent_volume_claim_v1" "erpnext_sites_rwo" {
  metadata {
    name      = "erpnext-sites-rwo"
    namespace = var.namespace
    labels    = { app = "erpnext" }
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = var.erpnext_sites_size }
    }
  }
  wait_until_bound = false

  depends_on = [kubernetes_namespace_v1.accounting]
}

resource "helm_release" "erpnext" {
  name       = var.release_name
  namespace  = var.namespace
  repository = "https://helm.erpnext.com"
  chart      = "erpnext"
  version    = var.erpnext_chart_version

  # Give the operator-managed secret + sites PVC time to exist first.
  timeout = 900
  wait    = false

  values = [yamlencode({
    image = {
      repository = "frappe/erpnext"
      tag        = var.erpnext_image_tag
      pullPolicy = "IfNotPresent"
    }

    dbPort     = 3306
    dbRootUser = "root"

    nginx = {
      replicaCount = 1
      nodeSelector = local.erpnext_pin
      environment = {
        upstreamRealIPAddress   = "127.0.0.1"
        upstreamRealIPRecursive = "off"
        upstreamRealIPHeader    = "X-Forwarded-For"
        frappeSiteNameHeader    = "$host"
        proxyReadTimeout        = "120"
        clientMaxBodySize       = "50m"
      }
      resources = {
        requests = { cpu = "100m", memory = "128Mi" }
        limits   = { cpu = "500m", memory = "512Mi" }
      }
    }

    worker = {
      gunicorn = {
        replicaCount = 1
        nodeSelector = local.erpnext_pin
        resources = {
          requests = { cpu = "500m", memory = "1Gi" }
          limits   = { cpu = "2000m", memory = "4Gi" }
        }
      }
      default = {
        replicaCount = 1
        nodeSelector = local.erpnext_pin
        resources = {
          requests = { cpu = "200m", memory = "512Mi" }
          limits   = { cpu = "1000m", memory = "2Gi" }
        }
      }
      short = {
        replicaCount = 1
        nodeSelector = local.erpnext_pin
        resources = {
          requests = { cpu = "200m", memory = "512Mi" }
          limits   = { cpu = "1000m", memory = "2Gi" }
        }
      }
      long = {
        replicaCount = 1
        nodeSelector = local.erpnext_pin
        resources = {
          requests = { cpu = "200m", memory = "512Mi" }
          limits   = { cpu = "1000m", memory = "2Gi" }
        }
      }
      scheduler = {
        replicaCount = 1
        nodeSelector = local.erpnext_pin
        resources = {
          requests = { cpu = "100m", memory = "256Mi" }
          limits   = { cpu = "500m", memory = "1Gi" }
        }
      }
    }

    socketio = {
      replicaCount = 1
      nodeSelector = local.erpnext_pin
      resources = {
        requests = { cpu = "100m", memory = "128Mi" }
        limits   = { cpu = "500m", memory = "512Mi" }
      }
    }

    persistence = {
      worker = {
        enabled       = true
        existingClaim = kubernetes_persistent_volume_claim_v1.erpnext_sites_rwo.metadata[0].name
        size          = var.erpnext_sites_size
        accessModes   = ["ReadWriteOnce"]
      }
      logs = {
        enabled = false
      }
    }

    # Built-in MariaDB StatefulSet.
    "mariadb-sts" = {
      enabled = true
      image = {
        repository = "mariadb"
        tag        = "10.6"
        pullPolicy = "IfNotPresent"
      }
      rootPassword = var.erpnext_mariadb_root_password
      persistence = {
        storageClass = local.storage_class
        size         = var.erpnext_mariadb_size
      }
      resources = {
        requests = { cpu = "200m", memory = "512Mi" }
        limits   = { cpu = "1000m", memory = "2Gi" }
      }
      myCnf = <<-EOT
        [mysqld]
        skip-character-set-client-handshake
        skip-innodb-read-only-compressed
        character-set-server=utf8mb4
        collation-server=utf8mb4_unicode_ci
      EOT
    }

    # Disable all other DB options.
    mariadb          = { enabled = false }
    postgresql       = { enabled = false }
    "postgresql-sts" = { enabled = false }

    # Valkey for cache and queue (chart defaults).
    "valkey-cache" = { enabled = true }
    "valkey-queue" = { enabled = true }

    # Disable alternatives.
    "redis-cache"     = { enabled = false }
    "redis-queue"     = { enabled = false }
    "dragonfly-cache" = { enabled = false }
    "dragonfly-queue" = { enabled = false }

    # Ingress handled by this module (kubernetes_ingress_v1).
    ingress = { enabled = false }

    jobs = {
      volumePermissions = {
        nodeSelector = local.erpnext_pin
      }
      configure = {
        enabled      = true
        fixVolume    = true
        nodeSelector = local.erpnext_pin
      }
      createSite = {
        enabled       = true
        forceCreate   = false
        siteName      = var.erpnext_site_name
        adminPassword = var.erpnext_admin_password
        installApps   = ["erpnext"]
        dbType        = "mariadb"
        backoffLimit  = 0
        nodeSelector  = local.erpnext_pin
      }
    }
  })]

  depends_on = [
    kubernetes_namespace_v1.accounting,
    kubernetes_persistent_volume_claim_v1.erpnext_sites_rwo,
  ]
}
