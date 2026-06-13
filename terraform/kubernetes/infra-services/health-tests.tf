# ---------------------------------------------------------------------------
# Health tests — a one-shot Job that curls key platform endpoints and fails if
# any are unreachable. Ported from the legacy health-tests chart and re-pointed
# at the new platform-ai namespace. Delete the Job to re-run it.
# ---------------------------------------------------------------------------
locals {
  # name|url|expected-status  (internal cluster DNS)
  health_test_targets = [
    "weaviate|http://weaviate.platform-ai.svc.cluster.local/v1/.well-known/ready|200",
    "chatterbox-tts|http://chatterbox-tts.platform-ai.svc.cluster.local:4123/health|200",
    "kitten-tts|http://kitten-tts.platform-ai.svc.cluster.local:8005/docs|200",
  ]

  health_test_script = <<-SH
    set -u
    fail=0
    for entry in ${join(" ", local.health_test_targets)}; do
      name=$(echo "$entry" | cut -d'|' -f1)
      url=$(echo "$entry" | cut -d'|' -f2)
      want=$(echo "$entry" | cut -d'|' -f3)
      got=$(curl -s -o /dev/null -w '%%{http_code}' --max-time 10 "$url" || echo 000)
      if [ "$got" = "$want" ]; then
        echo "OK   $name ($got) $url"
      else
        echo "FAIL $name (got $got, want $want) $url"
        fail=1
      fi
    done
    exit $fail
  SH
}

resource "kubernetes_job_v1" "health_tests" {
  count = var.health_tests_enabled ? 1 : 0

  metadata {
    name      = "health-test-runner"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "health-tests" })
  }
  spec {
    backoff_limit              = 0
    active_deadline_seconds    = 300
    ttl_seconds_after_finished = 600
    template {
      metadata {
        labels = merge(local.common_labels, { "app.kubernetes.io/name" = "health-tests" })
      }
      spec {
        restart_policy = "Never"
        node_selector  = local.node_selector
        container {
          name    = "curl"
          image   = var.health_tests_image
          command = ["/bin/sh", "-c", local.health_test_script]
        }
      }
    }
  }
  wait_for_completion = false
}
