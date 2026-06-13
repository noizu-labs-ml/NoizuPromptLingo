# =============================================================================
# Import existing Cloudflare Zero Trust resources
# =============================================================================
# Access group IDs: fetch with:
#   curl -s -H "Authorization: Bearer $TF_VAR_noizu_cloudflare_api_token" \
#     "https://api.cloudflare.com/client/v4/accounts/a75e745949fc104ea4c4107a17158f15/access/groups" \
#     | jq '.result[] | "\(.name)  \(.id)"'
# =============================================================================


# ── Access Groups (IDs from CF API — fetch with command above) ────────────
import {
  to = cloudflare_zero_trust_access_group.admins       
  id = "a75e745949fc104ea4c4107a17158f15/TODO"
}
import {
  to = cloudflare_zero_trust_access_group.developers   
  id = "a75e745949fc104ea4c4107a17158f15/TODO"
}
import {
  to = cloudflare_zero_trust_access_group.friends      
  id = "a75e745949fc104ea4c4107a17158f15/TODO"
}
import {
  to = cloudflare_zero_trust_access_group.clients      
  id = "a75e745949fc104ea4c4107a17158f15/TODO"
}
import {
  to = cloudflare_zero_trust_access_group.trusted_ips  
  id = "a75e745949fc104ea4c4107a17158f15/TODO"
}
import {
  to = cloudflare_zero_trust_access_group.service_tokens
  id = "a75e745949fc104ea4c4107a17158f15/TODO"
}

# ── Explicit apps (module paths) ──────────────────────────────────────────
import {
  to = module.argocd.cloudflare_zero_trust_access_application.this  
  id = "a75e745949fc104ea4c4107a17158f15/af52a43d-6c1c-4289-a3f9-ec3a029e2fcc"
}
import {
  to = module.livebook.cloudflare_zero_trust_access_application.this
  id = "a75e745949fc104ea4c4107a17158f15/fd96fe6e-1065-4963-9119-843723dc453d"
}
import {
  to = module.apm.cloudflare_zero_trust_access_application.this     
  id = "a75e745949fc104ea4c4107a17158f15/TODO"
}
import {
  to = module.minio.cloudflare_zero_trust_access_application.this   
  id = "a75e745949fc104ea4c4107a17158f15/TODO"
}

# ── Bulk apps (module for_each paths) ─────────────────────────────────────
import {
  to = module.bulk["chatterbox_tts"].cloudflare_zero_trust_access_application.this
  id = "a75e745949fc104ea4c4107a17158f15/a91ab74c-8bfd-438c-be5a-01fd478f5d95"
}
import {
  to = module.bulk["kitten_tts"].cloudflare_zero_trust_access_application.this    
  id = "a75e745949fc104ea4c4107a17158f15/385d7c9a-294c-4ef1-9250-04d0021fd8d3"
}
import {
  to = module.bulk["oneuptime"].cloudflare_zero_trust_access_application.this     
  id = "a75e745949fc104ea4c4107a17158f15/2cd4284e-c19d-4ca1-a319-62470e56ff5e"
}
import {
  to = module.bulk["posthog"].cloudflare_zero_trust_access_application.this       
  id = "a75e745949fc104ea4c4107a17158f15/0ba968be-1698-4808-b2a6-634e26ed17cc"
}
import {
  to = module.bulk["bottlecrm"].cloudflare_zero_trust_access_application.this     
  id = "a75e745949fc104ea4c4107a17158f15/9326a17b-d027-4093-9716-133de42f7aca"
}
import {
  to = module.bulk["seonaut"].cloudflare_zero_trust_access_application.this       
  id = "a75e745949fc104ea4c4107a17158f15/9c675333-b299-424c-a856-5687fa5a3179"
}
import {
  to = module.bulk["livecodes"].cloudflare_zero_trust_access_application.this     
  id = "a75e745949fc104ea4c4107a17158f15/2f37d2d8-3cd9-4238-8237-666fe3c4a660"
}
import {
  to = module.bulk["ghost"].cloudflare_zero_trust_access_application.this         
  id = "a75e745949fc104ea4c4107a17158f15/cacaa230-724d-467a-86a0-8dd7afa953e7"
}
import {
  to = module.bulk["serpbear"].cloudflare_zero_trust_access_application.this      
  id = "a75e745949fc104ea4c4107a17158f15/8dfec1d8-31ba-4b57-bff5-427d5eddb6dd"
}
import {
  to = module.bulk["espocrm"].cloudflare_zero_trust_access_application.this       
  id = "a75e745949fc104ea4c4107a17158f15/b823ad8c-f99b-43d1-a7b6-67529c4a28cd"
}
import {
  to = module.bulk["postiz"].cloudflare_zero_trust_access_application.this        
  id = "a75e745949fc104ea4c4107a17158f15/099b87e1-4e00-4d67-9eb0-1a6ca736891e"
}
import {
  to = module.bulk["mautic"].cloudflare_zero_trust_access_application.this        
  id = "a75e745949fc104ea4c4107a17158f15/bd71729e-507b-4fed-b1c0-d28aae8c0a1f"
}
import {
  to = module.bulk["labelstudio"].cloudflare_zero_trust_access_application.this   
  id = "a75e745949fc104ea4c4107a17158f15/9280a574-74e9-442f-a846-157535386d75"
}
import {
  to = module.bulk["growthbook"].cloudflare_zero_trust_access_application.this    
  id = "a75e745949fc104ea4c4107a17158f15/3b9d4f53-1db9-4fb7-aac0-67be8ff378ee"
}
import {
  to = module.bulk["matomo"].cloudflare_zero_trust_access_application.this        
  id = "a75e745949fc104ea4c4107a17158f15/0290896b-e2f2-466a-b7d9-3dba5e3a0a3d"
}
import {
  to = module.bulk["metabase"].cloudflare_zero_trust_access_application.this      
  id = "a75e745949fc104ea4c4107a17158f15/a711ba94-e9e5-4eb2-a108-c998354b56ae"
}
import {
  to = module.bulk["langfuse"].cloudflare_zero_trust_access_application.this      
  id = "a75e745949fc104ea4c4107a17158f15/6ac1da32-9f74-4a8c-ba5e-94d865622051"
}
import {
  to = module.bulk["code"].cloudflare_zero_trust_access_application.this          
  id = "a75e745949fc104ea4c4107a17158f15/27e0dc5e-ba52-460d-a441-502db6aadb00"
}
import {
  to = module.bulk["penpot"].cloudflare_zero_trust_access_application.this        
  id = "a75e745949fc104ea4c4107a17158f15/a7ad3f96-d958-40b5-8662-5fae3c3e08cf"
}
import {
  to = module.bulk["kroki"].cloudflare_zero_trust_access_application.this         
  id = "a75e745949fc104ea4c4107a17158f15/bbf2f884-d77a-49cd-a798-c2a3ce08769a"
}
import {
  to = module.bulk["eval"].cloudflare_zero_trust_access_application.this          
  id = "a75e745949fc104ea4c4107a17158f15/bbd92042-c45a-44e3-8970-2dd8f528b7aa"
}
import {
  to = module.bulk["cockpit"].cloudflare_zero_trust_access_application.this       
  id = "a75e745949fc104ea4c4107a17158f15/2a33e7da-df07-4b0e-a698-5fa96c67dfaf"
}
# TODO — remaining bulk apps not in old import script, fetch from CF API:
# import { to = module.bulk["echelon"].cloudflare_zero_trust_access_application.this      ; id = "a75e745949fc104ea4c4107a17158f15/TODO" }
# import { to = module.bulk["infra"].cloudflare_zero_trust_access_application.this        ; id = "a75e745949fc104ea4c4107a17158f15/TODO" }
# import { to = module.bulk["hakatime"].cloudflare_zero_trust_access_application.this     ; id = "a75e745949fc104ea4c4107a17158f15/TODO" }
# import { to = module.bulk["jupyter"].cloudflare_zero_trust_access_application.this      ; id = "a75e745949fc104ea4c4107a17158f15/TODO" }
# import { to = module.bulk["n8n"].cloudflare_zero_trust_access_application.this          ; id = "a75e745949fc104ea4c4107a17158f15/TODO" }
# import { to = module.bulk["webui"].cloudflare_zero_trust_access_application.this        ; id = "a75e745949fc104ea4c4107a17158f15/TODO" }
# import { to = module.bulk["litellm"].cloudflare_zero_trust_access_application.this      ; id = "a75e745949fc104ea4c4107a17158f15/TODO" }
# import { to = module.bulk["mydraft"].cloudflare_zero_trust_access_application.this      ; id = "a75e745949fc104ea4c4107a17158f15/TODO" }
# import { to = module.bulk["webstudio"].cloudflare_zero_trust_access_application.this    ; id = "a75e745949fc104ea4c4107a17158f15/TODO" }
# import { to = module.bulk["drawio"].cloudflare_zero_trust_access_application.this       ; id = "a75e745949fc104ea4c4107a17158f15/TODO" }
# import { to = module.bulk["excalidraw"].cloudflare_zero_trust_access_application.this   ; id = "a75e745949fc104ea4c4107a17158f15/TODO" }
# import { to = module.bulk["mermaid"].cloudflare_zero_trust_access_application.this      ; id = "a75e745949fc104ea4c4107a17158f15/TODO" }
# import { to = module.bulk["chartdb"].cloudflare_zero_trust_access_application.this      ; id = "a75e745949fc104ea4c4107a17158f15/TODO" }
# import { to = module.bulk["weaviate"].cloudflare_zero_trust_access_application.this     ; id = "a75e745949fc104ea4c4107a17158f15/TODO" }
# import { to = module.bulk["minio_console"].cloudflare_zero_trust_access_application.this ; id = "a75e745949fc104ea4c4107a17158f15/TODO" }
# import { to = module.bulk["headlamp"].cloudflare_zero_trust_access_application.this     ; id = "a75e745949fc104ea4c4107a17158f15/TODO" }
# import { to = module.bulk["infisical"].cloudflare_zero_trust_access_application.this    ; id = "a75e745949fc104ea4c4107a17158f15/TODO" }
# import { to = module.bulk["plane"].cloudflare_zero_trust_access_application.this        ; id = "a75e745949fc104ea4c4107a17158f15/TODO" }
# import { to = module.bulk["taiga"].cloudflare_zero_trust_access_application.this        ; id = "a75e745949fc104ea4c4107a17158f15/TODO" }
# import { to = module.bulk["plantuml"].cloudflare_zero_trust_access_application.this     ; id = "a75e745949fc104ea4c4107a17158f15/TODO" }
# import { to = module.bulk["appsmith"].cloudflare_zero_trust_access_application.this     ; id = "a75e745949fc104ea4c4107a17158f15/TODO" }

