# Code.eval_file/2 runs this in a fresh scope, so re-import the seed macro.
# The begin_session()/end_session() state from seeds.exs lives in this process.
require SeedHelper
import SeedHelper

alias NoizuPromptLingua.Schema.Auth.Providers.Provider

authentik_id = UUID.uuid5(:oid, "NoizuPromptLingua.Schema.Auth.Providers.Provider@Authentik")

seed {"auth-provider:authentik", "1"} do
  NoizuPromptLingua.Repo.insert!(%Provider{id: authentik_id, title: "Authentik", description: "Authentik OIDC SSO"}, on_conflict: :nothing, conflict_target: :id)
end
