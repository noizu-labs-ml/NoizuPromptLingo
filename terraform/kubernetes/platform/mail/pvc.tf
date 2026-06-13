# PersistentVolumeClaims for mailu services.

resource "kubernetes_persistent_volume_claim_v1" "postgresql" {
  metadata {
    name      = "mailu-postgresql-data"
    namespace = local.ns
    labels    = local.labels["postgresql"]
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = "10Gi" }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_persistent_volume_claim_v1" "redis" {
  metadata {
    name      = "mailu-redis-data"
    namespace = local.ns
    labels    = local.labels["redis"]
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = "2Gi" }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_persistent_volume_claim_v1" "mail" {
  metadata {
    name      = "mailu-mail-data"
    namespace = local.ns
    labels    = local.labels["dovecot"]
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = "50Gi" }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_persistent_volume_claim_v1" "dkim" {
  metadata {
    name      = "mailu-dkim-data"
    namespace = local.ns
    labels    = local.labels["mailu-dkim"]
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = "1Gi" }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_persistent_volume_claim_v1" "filter" {
  metadata {
    name      = "mailu-filter-data"
    namespace = local.ns
    labels    = local.labels["rspamd"]
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = "2Gi" }
    }
  }
  wait_until_bound = false
}
