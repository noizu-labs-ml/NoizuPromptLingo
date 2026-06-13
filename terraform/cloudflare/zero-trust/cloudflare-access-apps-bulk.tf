# =============================================================================
# Cloudflare Zero Trust — Bulk Access Applications (module per app)
# =============================================================================
# Each entry in `local.bulk_access_apps` is passed to the cf-access-app module
# which creates the application + standard 3-policy set (team/tokens/ips).
#
# Adding a new service = one entry here + terraform apply.
#
# Apps needing special policy wiring (argocd, livebook, apm, minio) live in
# cloudflare-access-apps.tf with explicit module calls and custom policies.
# =============================================================================

locals {
  bulk_access_apps = {
    # ── Dev tools ────────────────────────────────────────────────────────
    code = {
      name   = "Code"
      domain = "code.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    echelon = {
      name   = "Echelon"
      domain = "echelon.noizu.com"
      perms  = ["admin", "developer"]
    }
    infra = {
      name   = "Infra"
      domain = "infra.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    hakatime = {
      name   = "Hakatime"
      domain = "hakatime.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    livecodes = {
      name   = "LiveCodes"
      domain = "livecodes.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }

    # ── Analytics / Observability ────────────────────────────────────────
    langfuse = {
      name   = "Langfuse"
      domain = "langfuse.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    metabase = {
      name   = "Metabase"
      domain = "metabase.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    matomo = {
      name   = "Matomo"
      domain = "matomo.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    growthbook = {
      name   = "GrowthBook"
      domain = "growthbook.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    labelstudio = {
      name   = "Label Studio"
      domain = "labelstudio.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    posthog = {
      name   = "PostHog"
      domain = "posthog.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    serpbear = {
      name   = "SerpBear"
      domain = "serpbear.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    seonaut = {
      name   = "Seonaut"
      domain = "seonaut.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    oneuptime = {
      name   = "OneUptime"
      domain = "oneuptime.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }

    # ── Marketing / CRM / CMS ────────────────────────────────────────────
    mautic = {
      name   = "Mautic"
      domain = "mautic.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    postiz = {
      name   = "Postiz"
      domain = "postiz.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    espocrm = {
      name   = "EspoCRM"
      domain = "espocrm.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    bottlecrm = {
      name   = "BottleCRM"
      domain = "bottlecrm.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    ghost = {
      name   = "Ghost"
      domain = "ghost.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }

    # ── TTS / LLM UIs ────────────────────────────────────────────────────
    chatterbox_tts = {
      name   = "Chatterbox TTS"
      domain = "chatterbox-tts.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    kitten_tts = {
      name   = "Kitten TTS"
      domain = "kitten-tts.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    webui = {
      name   = "Open WebUI"
      domain = "privwebui.noizu.com"
      perms  = ["admin", "developer", "friend"]
    }
    litellm = {
      name   = "LiteLLM"
      domain = "litellm.noizu.com"
      perms  = ["admin", "developer"]
    }

    # ── Notebooks / Automation ────────────────────────────────────────────
    jupyter = {
      name   = "JupyterHub"
      domain = "jupyter.noizu.com"
      perms  = ["admin", "developer", "friend"]
    }
    n8n = {
      name   = "n8n"
      domain = "n8n.noizu.com"
      perms  = ["admin", "developer", "friend"]
    }

    # ── Design ────────────────────────────────────────────────────────────
    penpot = {
      name   = "Penpot"
      domain = "penpot.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    mydraft = {
      name   = "MyDraft"
      domain = "mydraft.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    webstudio = {
      name   = "Webstudio"
      domain = "webstudio.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }

    # ── Diagrams ──────────────────────────────────────────────────────────
    kroki = {
      name   = "Kroki"
      domain = "kroki.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    drawio = {
      name   = "Drawio"
      domain = "drawio.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    excalidraw = {
      name   = "Excalidraw"
      domain = "excalidraw.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    mermaid = {
      name   = "Mermaid"
      domain = "mermaid.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    chartdb = {
      name   = "ChartDB"
      domain = "chartdb.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }

    # ── Telemetry ─────────────────────────────────────────────────────────
    eval = {
      name   = "Telemetry"
      domain = "eval.noizu.com"
      perms  = ["admin", "developer", "friend"]
    }
    weaviate = {
      name   = "Weaviate"
      domain = "weaviate.noizu.com"
      perms  = ["admin", "developer"]
    }

    # ── Object Storage ────────────────────────────────────────────────────
    minio_console = {
      name   = "MinIO Console"
      domain = "minio-console.noizu.com"
      perms  = ["admin"]
    }

    # ── Admin / Infra ─────────────────────────────────────────────────────
    cockpit = {
      name   = "Cockpit"
      domain = "cockpit.noizu.com"
      perms  = ["admin"]
    }
    headlamp = {
      name   = "Headlamp"
      domain = "headlamp.noizu.com"
      perms  = ["admin"]
    }
    infisical = {
      name   = "Infisical"
      domain = "infisical.noizu.com"
      perms  = ["admin"]
    }

    # ── Project management ────────────────────────────────────────────────
    plane = {
      name   = "Plane"
      domain = "plane.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    taiga = {
      name   = "Taiga"
      domain = "taiga.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }

    # ── Diagram / low-code ────────────────────────────────────────────────
    plantuml = {
      name   = "PlantUML"
      domain = "plantuml.noizu.com"
      perms  = ["admin", "developer", "friend", "client"]
    }
    appsmith = {
      name   = "Appsmith"
      domain = "appsmith.noizu.com"
      perms  = ["admin", "developer"]
    }
  }
}

# ── Bulk module calls — one module instance per app ──────────────────────────

module "bulk" {
  for_each = local.bulk_access_apps
  source   = "../../modules/cf-access-app"

  account_id             = local.cf_account_id
  name                   = each.value.name
  domain                 = each.value.domain
  perms                  = each.value.perms
  group_ids              = local.cf_group_ids
  service_token_group_id = cloudflare_zero_trust_access_group.service_tokens.id
  trusted_ip_group_id    = cloudflare_zero_trust_access_group.trusted_ips.id
}
