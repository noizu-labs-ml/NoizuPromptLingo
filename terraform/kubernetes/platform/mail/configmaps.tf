# PostgreSQL database/role bootstrap script (mounted into docker-entrypoint-initdb.d).
resource "kubernetes_config_map_v1" "postgresql_init" {
  metadata {
    name      = "postgresql-init"
    namespace = local.ns
    labels    = local.common_labels
  }
  data = {
    "init-db.sh" = file("${path.module}/files/postgresql-init-db.sh")
  }
}

# Roundcube nginx site config (reproduced from the chart; the running image
# generates its own config and patches it via the postStart hook).
resource "kubernetes_config_map_v1" "roundcube_nginx_conf" {
  metadata {
    name      = "roundcube-nginx-conf"
    namespace = local.ns
    labels    = local.common_labels
  }
  data = {
    "webmail.conf" = file("${path.module}/files/roundcube-webmail.conf")
  }
}

# MTA-STS policy + nginx config.
resource "kubernetes_config_map_v1" "mta_sts" {
  metadata {
    name      = "mta-sts-config"
    namespace = local.ns
    labels    = local.common_labels
  }
  data = {
    "nginx.conf"  = file("${path.module}/files/mta-sts-nginx.conf")
    "mta-sts.txt" = file("${path.module}/files/mta-sts.txt")
  }
}
