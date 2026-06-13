# =============================================================================
# Import existing noizu.com DNS records from Cloudflare
# =============================================================================
# Runs automatically on `terraform apply`. Idempotent.
# IDs captured from live CF state on 2026-04-14.
#
# Records added after that date are marked TODO — fetch IDs with:
#   curl -s -H "Authorization: Bearer $TF_VAR_noizu_cloudflare_api_token" \
#     "https://api.cloudflare.com/client/v4/zones/46014d24206a7141ed698d2d9d963e85/dns_records?per_page=500" \
#     | jq '.result[] | "\(.name)  \(.id)"'
# =============================================================================

# ── Cluster A records ─────────────────────────────────────────────────────

import {
  to = cloudflare_dns_record.cluster["apm"]
  id = "46014d24206a7141ed698d2d9d963e85/37a5afa94582a0518ff653d2741e5d54"
}

import {
  to = cloudflare_dns_record.cluster["appsmith"]
  id = "46014d24206a7141ed698d2d9d963e85/62b02120ed04298ced19b1ea563f6fa4"
}

import {
  to = cloudflare_dns_record.cluster["argocd"]
  id = "46014d24206a7141ed698d2d9d963e85/3853b6f5969463b5dd5b7f1eea269e4d"
}

import {
  to = cloudflare_dns_record.cluster["blog"]
  id = "46014d24206a7141ed698d2d9d963e85/396d5aaecef5c05e15262697d9efff91"
}

import {
  to = cloudflare_dns_record.cluster["bottlecrm"]
  id = "46014d24206a7141ed698d2d9d963e85/48c50af6ffae4aafc60f29540bb1c62a"
}

import {
  to = cloudflare_dns_record.cluster["chartdb"]
  id = "46014d24206a7141ed698d2d9d963e85/2ff67fa37a424792e9d265ddf84afe04"
}

import {
  to = cloudflare_dns_record.cluster["chatterbox-tts"]
  id = "46014d24206a7141ed698d2d9d963e85/ae5c418fa6affab56a2918cc0bf3b2de"
}

import {
  to = cloudflare_dns_record.cluster["cockpit"]
  id = "46014d24206a7141ed698d2d9d963e85/067fa6aae6890590f5d1c2e2d09b8ac5"
}

import {
  to = cloudflare_dns_record.cluster["code"]
  id = "46014d24206a7141ed698d2d9d963e85/9a4b2d6c492b133ae863758464b70e86"
}

import {
  to = cloudflare_dns_record.cluster["directus"]
  id = "46014d24206a7141ed698d2d9d963e85/af5a1e60e3500ec92cfd0c3a8c501b9a"
}

import {
  to = cloudflare_dns_record.cluster["docmost"]
  id = "46014d24206a7141ed698d2d9d963e85/2c5b628401592368aa372a364ff0bed4"
}

import {
  to = cloudflare_dns_record.cluster["drawio"]
  id = "46014d24206a7141ed698d2d9d963e85/c231e400184dc26d6d512e79b15b5c69"
}

import {
  to = cloudflare_dns_record.cluster["echelon"]
  id = "46014d24206a7141ed698d2d9d963e85/195a3e7c70dace9a21edf649720163f6"
}

import {
  to = cloudflare_dns_record.cluster["espocrm"]
  id = "46014d24206a7141ed698d2d9d963e85/cb93af70d448870f96969e65d769433b"
}

import {
  to = cloudflare_dns_record.cluster["eval"]
  id = "46014d24206a7141ed698d2d9d963e85/915679aeff0ce2822190bf17cc22d794"
}

import {
  to = cloudflare_dns_record.cluster["excalidraw"]
  id = "46014d24206a7141ed698d2d9d963e85/8cac47694c05029b35f1006baaa4fe10"
}

import {
  to = cloudflare_dns_record.cluster["ghost"]
  id = "46014d24206a7141ed698d2d9d963e85/dc1603bf6c062f2fcf1759924092e3a7"
}

import {
  to = cloudflare_dns_record.cluster["growthbook"]
  id = "46014d24206a7141ed698d2d9d963e85/83cef167c10b2b7ab9d771d0d041b61c"
}

import {
  to = cloudflare_dns_record.cluster["hakatime"]
  id = "46014d24206a7141ed698d2d9d963e85/92e41e4df63e7727eff593cea3993e56"
}

import {
  to = cloudflare_dns_record.cluster["headlamp"]
  id = "46014d24206a7141ed698d2d9d963e85/c5272e3e0180f05e1f43d7f2e10b3bcd"
}

import {
  to = cloudflare_dns_record.cluster["infisical"]
  id = "46014d24206a7141ed698d2d9d963e85/7bcac1501cfb4ba0ad8cb8d93cab5525"
}

import {
  to = cloudflare_dns_record.cluster["infra"]
  id = "46014d24206a7141ed698d2d9d963e85/4c069821cc16e39cb510c05834d52f7a"
}

import {
  to = cloudflare_dns_record.cluster["jupyter"]
  id = "46014d24206a7141ed698d2d9d963e85/e78c1775a3518522107c1292b990c4b8"
}

import {
  to = cloudflare_dns_record.cluster["keygen"]
  id = "46014d24206a7141ed698d2d9d963e85/b60f19a097531cb7d1ee006b6a4bdd78"
}

import {
  to = cloudflare_dns_record.cluster["kitten-tts"]
  id = "46014d24206a7141ed698d2d9d963e85/9004330bae2f5df893141b4f1118577d"
}

import {
  to = cloudflare_dns_record.cluster["kroki"]
  id = "46014d24206a7141ed698d2d9d963e85/4d05f0a6d7c1a3f60dcb32d0af7dd11a"
}

import {
  to = cloudflare_dns_record.cluster["labelstudio"]
  id = "46014d24206a7141ed698d2d9d963e85/a11489da011a9e9e4e879139cebc13b1"
}

import {
  to = cloudflare_dns_record.cluster["langfuse"]
  id = "46014d24206a7141ed698d2d9d963e85/b856aebb5ae9d436a85b58d1de3ddf2b"
}

import {
  to = cloudflare_dns_record.cluster["listmonk"]
  id = "46014d24206a7141ed698d2d9d963e85/e97ccd95a5dc2aa18fabd68247a8cba6"
}

import {
  to = cloudflare_dns_record.cluster["litellm"]
  id = "46014d24206a7141ed698d2d9d963e85/5e759ccb5d1b3b9f3de15582b117cbf6"
}

import {
  to = cloudflare_dns_record.cluster["livecodes"]
  id = "46014d24206a7141ed698d2d9d963e85/378085c045fd7402555e7ca51a07ca87"
}

import {
  to = cloudflare_dns_record.cluster["matomo"]
  id = "46014d24206a7141ed698d2d9d963e85/66a72d273cfe72b32d3f7ea1d9049b87"
}

import {
  to = cloudflare_dns_record.cluster["mautic"]
  id = "46014d24206a7141ed698d2d9d963e85/4e799f4e24409b6a1e5312aa2d579662"
}

import {
  to = cloudflare_dns_record.cluster["mermaid"]
  id = "46014d24206a7141ed698d2d9d963e85/70d67cfcc920a769d0f4b463568b1e8d"
}

import {
  to = cloudflare_dns_record.cluster["metabase"]
  id = "46014d24206a7141ed698d2d9d963e85/a3b806e3d5baf7bf98369539b254d699"
}

import {
  to = cloudflare_dns_record.cluster["mydraft"]
  id = "46014d24206a7141ed698d2d9d963e85/913bd06e4128c9b8248801434d3460fd"
}

import {
  to = cloudflare_dns_record.cluster["n8n"]
  id = "46014d24206a7141ed698d2d9d963e85/b0f5e7ec0ef60fdbdd9c05830e93f978"
}

import {
  to = cloudflare_dns_record.cluster["nb"]
  id = "46014d24206a7141ed698d2d9d963e85/deac76237c72410f32777878c2e14d9c"
}

import {
  to = cloudflare_dns_record.cluster["nextcloud"]
  id = "46014d24206a7141ed698d2d9d963e85/a73eb509bbbda46d5e59bdb8d4369f41"
}

import {
  to = cloudflare_dns_record.cluster["oneuptime"]
  id = "46014d24206a7141ed698d2d9d963e85/3ea7f707d0b26677d812a67e683ee03c"
}

import {
  to = cloudflare_dns_record.cluster["penpot"]
  id = "46014d24206a7141ed698d2d9d963e85/17c1fd5870b95676a1a605682b3ccf5b"
}

import {
  to = cloudflare_dns_record.cluster["plane"]
  id = "46014d24206a7141ed698d2d9d963e85/c077d119f47e061fdcce52a1605026b3"
}

import {
  to = cloudflare_dns_record.cluster["plantuml"]
  id = "46014d24206a7141ed698d2d9d963e85/6c5b5f9a1cfe2b072dd6348124fcf404"
}

import {
  to = cloudflare_dns_record.cluster["posthog"]
  id = "46014d24206a7141ed698d2d9d963e85/fc28ed0067f973f4328a94fc784c68d5"
}

import {
  to = cloudflare_dns_record.cluster["postiz"]
  id = "46014d24206a7141ed698d2d9d963e85/0d7c86896dfae885e5f67f3748507b21"
}

import {
  to = cloudflare_dns_record.cluster["seonaut"]
  id = "46014d24206a7141ed698d2d9d963e85/753c5f9e8004f6273bf6dc113998ae15"
}

import {
  to = cloudflare_dns_record.cluster["serpbear"]
  id = "46014d24206a7141ed698d2d9d963e85/ba419a9afd2af3ebcb0b099e6308453c"
}

import {
  to = cloudflare_dns_record.cluster["taiga"]
  id = "46014d24206a7141ed698d2d9d963e85/3cb1e4f44d6cba18a2d75cd86e2deff2"
}

import {
  to = cloudflare_dns_record.cluster["weaviate"]
  id = "46014d24206a7141ed698d2d9d963e85/f9ce2b404fe5ee6dac8471841de051f9"
}

import {
  to = cloudflare_dns_record.cluster["webstudio"]
  id = "46014d24206a7141ed698d2d9d963e85/a14bf8aac79a3b4fecf9415cc7b91e42"
}

import {
  to = cloudflare_dns_record.cluster["webui"]
  id = "46014d24206a7141ed698d2d9d963e85/fba407e3c9ad31022254c6cfa3dedd2e"
}

# TODO — added after 2026-04-14, fill in IDs from CF API before applying:
# import {
#   to = cloudflare_dns_record.cluster["accounting"]
#   id = "46014d24206a7141ed698d2d9d963e85/TODO"
# }
# import {
#   to = cloudflare_dns_record.cluster["minio"]
#   id = "46014d24206a7141ed698d2d9d963e85/TODO"
# }
# import {
#   to = cloudflare_dns_record.cluster["minio-console"]
#   id = "46014d24206a7141ed698d2d9d963e85/TODO"
# }
# import {
#   to = cloudflare_dns_record.cluster["npm"]
#   id = "46014d24206a7141ed698d2d9d963e85/TODO"
# }

# ── Special A records ─────────────────────────────────────────────────────

import {
  to = cloudflare_dns_record.root
  id = "46014d24206a7141ed698d2d9d963e85/8d75e16e557c7879324ac46fd362fdcf"
}

import {
  to = cloudflare_dns_record.www
  id = "46014d24206a7141ed698d2d9d963e85/2b9df9f1fd017a6f2136be5e0eb7a9eb"
}

import {
  to = cloudflare_dns_record.ipmi
  id = "46014d24206a7141ed698d2d9d963e85/368a816fe740a732088a7900dffab0aa"
}

import {
  to = cloudflare_dns_record.ops
  id = "46014d24206a7141ed698d2d9d963e85/f6569d9d4878081030bf1d06634fe2c0"
}

# ── Microsoft 365 CNAMEs ──────────────────────────────────────────────────

import {
  to = cloudflare_dns_record.autodiscover
  id = "46014d24206a7141ed698d2d9d963e85/6997447868df52dc3e75faee9918907e"
}

import {
  to = cloudflare_dns_record.autodiscover_o365
  id = "46014d24206a7141ed698d2d9d963e85/eac2b0d996e6fe1c17da067378d6924e"
}

import {
  to = cloudflare_dns_record.enterpriseenrollment
  id = "46014d24206a7141ed698d2d9d963e85/5bd9ea101fa73d2e3b209871b5b6c78c"
}

import {
  to = cloudflare_dns_record.enterpriseenrollment_o365
  id = "46014d24206a7141ed698d2d9d963e85/b9beab9997d7da84ee5d4f2f0cbdc829"
}

import {
  to = cloudflare_dns_record.enterpriseregistration
  id = "46014d24206a7141ed698d2d9d963e85/2232621b54df1961a105e9656040529d"
}

import {
  to = cloudflare_dns_record.enterpriseregistration_o365
  id = "46014d24206a7141ed698d2d9d963e85/dcc78c0f0e175a6b11def7e0adbe6b21"
}

import {
  to = cloudflare_dns_record.lyncdiscover
  id = "46014d24206a7141ed698d2d9d963e85/f0b643f2d676b82e447289f66b947c48"
}

import {
  to = cloudflare_dns_record.lyncdiscover_o365
  id = "46014d24206a7141ed698d2d9d963e85/bb0cf326516052f366359a89dbcb711a"
}

import {
  to = cloudflare_dns_record.sip
  id = "46014d24206a7141ed698d2d9d963e85/e28bb1e1e22d77b6fdaaff0ea74463b3"
}

import {
  to = cloudflare_dns_record.sip_o365
  id = "46014d24206a7141ed698d2d9d963e85/0a8d1e1a23ec9e9f0a3488cbcb45f2f3"
}

# ── Google Workspace CNAMEs ───────────────────────────────────────────────

import {
  to = cloudflare_dns_record.calendar
  id = "46014d24206a7141ed698d2d9d963e85/ba2b9ea66373a0dea9b3ab6716be7efe"
}

import {
  to = cloudflare_dns_record.docs
  id = "46014d24206a7141ed698d2d9d963e85/3048c00dea0588aa36dd745f562a68c7"
}

import {
  to = cloudflare_dns_record.mail
  id = "46014d24206a7141ed698d2d9d963e85/50005b881dcd4f813567e9fc638a424b"
}

# ── DKIM CNAMEs ───────────────────────────────────────────────────────────

import {
  to = cloudflare_dns_record.dkim_selector1
  id = "46014d24206a7141ed698d2d9d963e85/e34a9beb288cb199724189fc2b8bf5cf"
}

import {
  to = cloudflare_dns_record.dkim_selector2
  id = "46014d24206a7141ed698d2d9d963e85/3ddd15bc16369cd5bdaaa6f8f873d46e"
}

# ── MX records ────────────────────────────────────────────────────────────

import {
  to = cloudflare_dns_record.mx_google_primary
  id = "46014d24206a7141ed698d2d9d963e85/728298ad4a572ac771592bed796cd65b"
}

import {
  to = cloudflare_dns_record.mx_google_alt1
  id = "46014d24206a7141ed698d2d9d963e85/6e2ba99a41ac2d90b048c32289377739"
}

import {
  to = cloudflare_dns_record.mx_google_alt2
  id = "46014d24206a7141ed698d2d9d963e85/e13b110704ea8b954acabe30aacd3bfc"
}

import {
  to = cloudflare_dns_record.mx_google_aspmx2
  id = "46014d24206a7141ed698d2d9d963e85/d67922134b2fba6b231e054a38ea431b"
}

import {
  to = cloudflare_dns_record.mx_google_aspmx3
  id = "46014d24206a7141ed698d2d9d963e85/c4f2ee208591f512de0b7bc55ee6334b"
}

import {
  to = cloudflare_dns_record.mx_outlook_fallback
  id = "46014d24206a7141ed698d2d9d963e85/679571f1de07ab48ea36e76b1f746f6f"
}

import {
  to = cloudflare_dns_record.mx_o365
  id = "46014d24206a7141ed698d2d9d963e85/8cf359bef192eb74e26d6e613e82c719"
}

import {
  to = cloudflare_dns_record.mx_gsuite
  id = "46014d24206a7141ed698d2d9d963e85/abfc1e0cc16da67b98cc8423ce6c5c9c"
}

# ── SRV records ───────────────────────────────────────────────────────────

import {
  to = cloudflare_dns_record.srv_sip_tls
  id = "46014d24206a7141ed698d2d9d963e85/63dc71c577ae256416d656a55027f7c3"
}

import {
  to = cloudflare_dns_record.srv_sipfederation
  id = "46014d24206a7141ed698d2d9d963e85/9ae860bee47557758168a6d603e71685"
}

# ── TXT records ───────────────────────────────────────────────────────────

import {
  to = cloudflare_dns_record.txt_spf
  id = "46014d24206a7141ed698d2d9d963e85/756e61b3d7175622fc5a56fd26905f4d"
}

import {
  to = cloudflare_dns_record.txt_ms_verification
  id = "46014d24206a7141ed698d2d9d963e85/2204402c164ded1849c3a14168209ceb"
}

import {
  to = cloudflare_dns_record.txt_openai
  id = "46014d24206a7141ed698d2d9d963e85/01a58c5c8b5460e9e55554074ce0e704"
}

import {
  to = cloudflare_dns_record.txt_google_verification
  id = "46014d24206a7141ed698d2d9d963e85/4a3c85b92caa2d6a56ef93962687e3ec"
}

import {
  to = cloudflare_dns_record.txt_spf_o365
  id = "46014d24206a7141ed698d2d9d963e85/790fe1a450f7fcb74e8fab8ab62e16f4"
}
