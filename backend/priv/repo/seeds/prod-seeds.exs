require SeedHelper
import SeedHelper

dir = Path.dirname(__ENV__.file)
Code.eval_file("#{dir}/auth_providers/002-sso-providers.exs")

seed {"unicode-codex:curated-v1", "1"} do
  NoizuPromptLingua.Domains.UnicodeCodex.SeedLoader.seed_all!()
end
