#!/usr/bin/env bash
# rebuild-subtrees.sh
# Recreate all subtree entries with --squash to flatten history.
#
# Usage:
#   1. Start from a clean branch with only the non-subtree content
#   2. Run this script to re-add all subtrees with --squash
#
# NOTE: Some repos may need branch adjustments if they've changed default branches.
#       Repos marked TODO could not be verified on GitHub — check they still exist.
set -euo pipefail

##############################################################################
# STEP 1: Add remotes
##############################################################################

# --- 3rd-party (noizu-forks) ---
git remote add noizu-forks-chartdb              git@github.com:noizu-forks/chartdb.git
git remote add noizu-forks-clickhouse           git@github.com:noizu-forks/ClickHouse.git
git remote add noizu-forks-directus             git@github.com:noizu-forks/directus.git
git remote add noizu-forks-drawio               git@github.com:noizu-forks/drawio.git
git remote add noizu-forks-excalidraw           git@github.com:noizu-forks/excalidraw.git
git remote add noizu-forks-excalidraw-room      git@github.com:noizu-forks/excalidraw-room.git
git remote add noizu-forks-kroki                git@github.com:noizu-forks/kroki.git
git remote add noizu-forks-mermaid-live-editor  git@github.com:noizu-forks/mermaid-live-editor.git
git remote add noizu-forks-mydraft-server2      git@github.com:noizu-forks/server2.git
git remote add noizu-forks-n8n                  git@github.com:noizu-forks/n8n.git
git remote add noizu-forks-penpot               git@github.com:noizu-forks/penpot.git
git remote add noizu-forks-plantuml             git@github.com:noizu-forks/plantuml.git
git remote add noizu-forks-plantuml-server      git@github.com:noizu-forks/plantuml-server.git
git remote add noizu-forks-terraform-provider-signoz https://github.com/noizu-forks/terraform-provider-signoz.git
git remote add noizu-forks-webstudio            git@github.com:noizu-forks/webstudio.git
git remote add noizu-forks-zellij               git@github.com:noizu-forks/zellij.git

echo "# --- components (the-robot-lives) ---"
git remote add start-app                        git@github.com:the-robot-lives/start-app.git
git remote add styleguide                       git@github.com:the-robot-lives/styleguide.git

echo "# --- libs ---"
git remote add elixir-mcp                       git@github.com:noizu-labs-ml/elixir-mcp-lib.git
git remote add scaffolding-core                 git@github.com:noizu-labs/ElixirCore.git
git remote add scaffolding-entities             git@github.com:noizu-labs/ElixirScaffolding.git

echo "# --- share ---"
git remote add k8-lib                           git@github.com:the-robot-lives/k8-lib.git

echo "# --- skills ---"
git remote add skills                           git@github.com:the-robot-lives/skills.git

echo "# --- projects (the-robot-lives) ---"
git remote add aifighter-dot-com                git@github.com:the-robot-lives/aifighter.com.git
git remote add bladeofeternity-dot-com          git@github.com:the-robot-lives/bladeofeternity.com.git
git remote add bloggerscompete-dot-com          git@github.com:the-robot-lives/bloggerscompete.com.git
git remote add bookmarkflow-dot-com             git@github.com:the-robot-lives/bookmarkflow.com.git
git remote add codefre-dot-sh                   git@github.com:the-robot-lives/codefre.sh.git
git remote add derobot-dot-is                   git@github.com:the-robot-lives/derobot.is.git
git remote add game-workshop                    git@github.com:the-robot-lives/game-workshop.git
git remote add gamesborn-dot-com                git@github.com:the-robot-lives/gamesborn.com.git
git remote add genai-dot-dev                    git@github.com:the-robot-lives/genai.dev.git
git remote add gotta-dot-cc                     git@github.com:the-robot-lives/gotta.cc.git
git remote add intellectparadox-dot-ai          git@github.com:the-robot-lives/intellectparadox.ai.git
git remote add interactive-pdf                  git@github.com:the-robot-lives/interactive-pdf.git
git remote add iotgo-dot-io                     git@github.com:the-robot-lives/iotgo.io.git
git remote add jailbreakingsite-dot-com         git@github.com:the-robot-lives/jailbreakingsite.com.git
git remote add kopigajj                         git@github.com:the-robot-lives/kopigajj.git
git remote add mcp-host                         git@github.com:the-robot-lives/mcp-host.git
git remote add meat-brains-therobotlives-dot-com git@github.com:the-robot-lives/meat-brains.therobotlives.com.git
git remote add mockup-mcp                       git@github.com:the-robot-lives/mockup-mcp.git
git remote add noizurpg-dot-com                 git@github.com:the-robot-lives/noizurpg.com.git
git remote add robots-unite-dot-com             git@github.com:the-robot-lives/robots-unite.com.git
git remote add rokos-coin                       git@github.com:the-robot-lives/rokos-coin.git
git remote add therobotbrowses                  git@github.com:the-robot-lives/therobotbrowses.git
git remote add therobotknows-dot-com            git@github.com:the-robot-lives/therobotknows.com.git
git remote add therobotlives-dot-com            git@github.com:the-robot-lives/therobotlives.com.git
git remote add therobotmakes-dot-com            git@github.com:the-robot-lives/therobotmakes.com.git
git remote add therobotpaints                   git@github.com:the-robot-lives/therobotpaints.git
git remote add therobotplans-dot-com            git@github.com:the-robot-lives/therobotplans.com.git
git remote add therobotremembers                git@github.com:the-robot-lives/therobotremembers.git
git remote add the-waitcher                     git@github.com:the-robot-lives/theWaitcher.git
git remote add vibeucation-dot-com              git@github.com:the-robot-lives/vibeucation.com.git

echo "# --- projects (noizu-labs) ---"
git remote add infra-noizu-com                  git@github.com:noizu-labs/infra.noizu.com.git
git remote add noizu-dot-com                    git@github.com:noizu-labs/website.git

echo "# --- projects (noizu-labs-ml) ---"
git remote add noizu-prompt-lingo               git@github.com:noizu-labs-ml/NoizuPromptLingo.git

echo "# --- projects (TODO: repo not found on GitHub — may be deleted/private) ---"
echo "# git remote add tobornalp-dot-com              git@github.com:the-robot-lives/tobornalp.com.git  # TODO: 404"

echo "# --- utilities (the-robot-lives) ---"
git remote add claude-assist                    git@github.com:the-robot-lives/claude-assist.git
git remote add dangerously-safe                 git@github.com:the-robot-lives/dangerously-safe.git
git remote add mallm                            git@github.com:the-robot-lives/mallm.git
git remote add media-tool                       git@github.com:the-robot-lives/media-tools.git
git remote add run-claude                       git@github.com:the-robot-lives/run-claude.git 
echo " # TODO: 404 — verify"
git remote add auto-sudo                        git@github.com:the-robot-lives/auto-sudo.git
git remote add colo-utils                       git@github.com:the-robot-lives/colo-tools.git
git remote add cluster-utils                    git@github.com:the-robot-lives/cluster-tools.git
git remote add database-utils                   git@github.com:the-robot-lives/database-tools.git
git remote add direnv-config                    git@github.com:the-robot-lives/direnv-config.git
git remote add docker-utils                     git@github.com:the-robot-lives/docker-tools.git
git remote add fstab                            git@github.com:the-robot-lives/fstab-mounter.git
git remote add github-utils                     git@github.com:the-robot-lives/github-tools.git
git remote add helm-utils                       git@github.com:the-robot-lives/helm-tools.git
git remote add infra-utils                      git@github.com:the-robot-lives/infra-tools.git
git remote add make-repo                        git@github.com:the-robot-lives/make-repo.git
git remote add misc-git-utils                   git@github.com:the-robot-lives/util-misc.git
git remote add queue-populator                  git@github.com:the-robot-lives/util-queue-populator.git
git remote add remote-tunnel                    git@github.com:the-robot-lives/remote-tunnel.git
git remote add secret-bucket                    git@github.com:the-robot-lives/secret-bucket.git
git remote add secret-utils                     git@github.com:the-robot-lives/secrets-tools.git
git remote add staging-utils                    git@github.com:the-robot-lives/staging-tools.git
git remote add tabbing-on                       git@github.com:the-robot-lives/tabbing-on.git  
echo "# TODO: 404 — verify"
git remote add terraform-utils                  git@github.com:the-robot-lives/terraform-tools.git
git remote add zellij-util                      git@github.com:the-robot-lives/util-zellij.git

##############################################################################
# STEP 2: Fetch all remotes
##############################################################################

git fetch --all

##############################################################################
# STEP 3: Add subtrees with --squash
##############################################################################

# --- 3rd-party ---
git subtree add --prefix=3rd-party/chartdb              noizu-forks-chartdb             main    --squash
git subtree add --prefix=3rd-party/clickhouse            noizu-forks-clickhouse           master  --squash
git subtree add --prefix=3rd-party/directus              noizu-forks-directus             main    --squash
git subtree add --prefix=3rd-party/drawio                noizu-forks-drawio               dev     --squash
git subtree add --prefix=3rd-party/excalidraw            noizu-forks-excalidraw           master  --squash
git subtree add --prefix=3rd-party/excalidraw-room       noizu-forks-excalidraw-room      master  --squash
git subtree add --prefix=3rd-party/kroki                 noizu-forks-kroki                main    --squash
git subtree add --prefix=3rd-party/mermaid-live-editor   noizu-forks-mermaid-live-editor  develop --squash
git subtree add --prefix=3rd-party/mydraft-server2       noizu-forks-mydraft-server2      main    --squash
git subtree add --prefix=3rd-party/n8n                   noizu-forks-n8n                  master  --squash
git subtree add --prefix=3rd-party/penpot                noizu-forks-penpot               develop --squash
git subtree add --prefix=3rd-party/plantuml              noizu-forks-plantuml             master  --squash
git subtree add --prefix=3rd-party/plantuml-server       noizu-forks-plantuml-server      master  --squash
git subtree add --prefix=3rd-party/terraform-provider-signoz noizu-forks-terraform-provider-signoz main --squash
git subtree add --prefix=3rd-party/webstudio             noizu-forks-webstudio            main    --squash
git subtree add --prefix=3rd-party/zellij                noizu-forks-zellij               main    --squash

# --- components ---
git subtree add --prefix=components/start-app            start-app                        main    --squash
git subtree add --prefix=components/styleguide           styleguide                       main    --squash

# --- libs ---
git subtree add --prefix=libs/elixir-mcp                 elixir-mcp                       main    --squash
git subtree add --prefix=libs/scaffolding/core           scaffolding-core                 master  --squash
git subtree add --prefix=libs/scaffolding/entities       scaffolding-entities             master  --squash

# --- share ---
git subtree add --prefix=share/k8-lib                    k8-lib                           main    --squash

# --- skills ---
git subtree add --prefix=skills                          skills                           main    --squash

# --- projects ---
git subtree add --prefix=projects/aifighter.com                    aifighter-dot-com                main --squash
git subtree add --prefix=projects/bladeofeternity.com              bladeofeternity-dot-com          main --squash
git subtree add --prefix=projects/bloggerscompete.com              bloggerscompete-dot-com          main --squash
git subtree add --prefix=projects/bookmarkflow.com                 bookmarkflow-dot-com             main --squash
git subtree add --prefix=projects/codefre.sh                       codefre-dot-sh                   main --squash
git subtree add --prefix=projects/derobot.is                       derobot-dot-is                   main --squash
git subtree add --prefix=projects/game-workshop                    game-workshop                    main --squash
git subtree add --prefix=projects/gamesborn.com                    gamesborn-dot-com                main --squash
git subtree add --prefix=projects/genai.dev                        genai-dot-dev                    main --squash
git subtree add --prefix=projects/gotta.cc                         gotta-dot-cc                     main --squash
git subtree add --prefix=projects/infra.noizu.com                  infra-noizu-com                  main --squash
git subtree add --prefix=projects/intellectparadox.ai              intellectparadox-dot-ai          main --squash
git subtree add --prefix=projects/interactive-pdf                  interactive-pdf                  main --squash
git subtree add --prefix=projects/iotgo.io                         iotgo-dot-io                     main --squash
git subtree add --prefix=projects/jailbreakingsite.com             jailbreakingsite-dot-com         main --squash
git subtree add --prefix=projects/kopigajj                         kopigajj                         main --squash
git subtree add --prefix=projects/mcp-host                         mcp-host                         main --squash
git subtree add --prefix=projects/meat-brains.therobotlives.com    meat-brains-therobotlives-dot-com main --squash
git subtree add --prefix=projects/mockup-mcp                       mockup-mcp                       main --squash
git subtree add --prefix=projects/noizu.com                        noizu-dot-com                    main --squash
git subtree add --prefix=projects/NoizuPromptLingo                 noizu-prompt-lingo               main --squash
git subtree add --prefix=projects/noizurpg.com                     noizurpg-dot-com                 main --squash
git subtree add --prefix=projects/robots-unite.com                 robots-unite-dot-com             main --squash
git subtree add --prefix=projects/rokos-coin                       rokos-coin                       main --squash
git subtree add --prefix=projects/therobotbrowses                  therobotbrowses                  main --squash
git subtree add --prefix=projects/therobotknows.com                therobotknows-dot-com            main --squash
git subtree add --prefix=projects/therobotlives.com                therobotlives-dot-com            main --squash
git subtree add --prefix=projects/therobotmakes.com                therobotmakes-dot-com            main --squash
git subtree add --prefix=projects/therobotpaints                   therobotpaints                   main --squash
git subtree add --prefix=projects/therobotplans.com                therobotplans-dot-com            main --squash
git subtree add --prefix=projects/therobotremembers                therobotremembers                main --squash
git subtree add --prefix=projects/theWaitcher                      the-waitcher                     main --squash
git subtree add --prefix=projects/vibeucation.com                  vibeucation-dot-com              main --squash
# git subtree add --prefix=projects/tobornalp.com                  tobornalp-dot-com                main --squash  # TODO: repo 404

# --- utilities/agent ---
git subtree add --prefix=utilities/agent/claude-assist     claude-assist                  main --squash
git subtree add --prefix=utilities/agent/dangerously-safe  dangerously-safe               main --squash
git subtree add --prefix=utilities/agent/mallm             mallm                          main --squash
git subtree add --prefix=utilities/agent/media-tool        media-tool                     main --squash
# git subtree add --prefix=utilities/agent/run-claude      run-claude                     main --squash  # TODO: repo 404

# --- utilities/colo ---
git subtree add --prefix=utilities/colo/colo-utils         colo-utils                     main --squash

# --- utilities/database ---
git subtree add --prefix=utilities/database/database-utils database-utils                 main --squash

# --- utilities/k8 ---
git subtree add --prefix=utilities/k8/cluster-utils        cluster-utils                  main --squash
git subtree add --prefix=utilities/k8/docker-utils         docker-utils                   main --squash
git subtree add --prefix=utilities/k8/helm-utils           helm-utils                     main --squash
git subtree add --prefix=utilities/k8/infra-utils          infra-utils                    main --squash
git subtree add --prefix=utilities/k8/secret-utils         secret-utils                   main --squash
git subtree add --prefix=utilities/k8/staging-utils        staging-utils                  main --squash

# --- utilities/osx ---
git subtree add --prefix=utilities/osx/fstab               fstab                          main --squash
git subtree add --prefix=utilities/osx/queue-populator     queue-populator                main --squash

# --- utilities/shell ---
git subtree add --prefix=utilities/shell/auto-sudo         auto-sudo                      main --squash
git subtree add --prefix=utilities/shell/direnv-config     direnv-config                  main --squash
git subtree add --prefix=utilities/shell/github-utils      github-utils                   main --squash
git subtree add --prefix=utilities/shell/make-repo         make-repo                      main --squash
git subtree add --prefix=utilities/shell/misc-git-utils    misc-git-utils                 main --squash
git subtree add --prefix=utilities/shell/remote-tunnel     remote-tunnel                  main --squash
git subtree add --prefix=utilities/shell/secret-bucket     secret-bucket                  main --squash
# git subtree add --prefix=utilities/shell/tabbing-on      tabbing-on                     main --squash  # TODO: repo 404
git subtree add --prefix=utilities/shell/zellij            zellij-util                    main --squash

# --- utilities/terraform ---
git subtree add --prefix=utilities/terraform/terraform-utils terraform-utils              main --squash

echo ""
echo "=== Subtree rebuild complete ==="
echo "Directories NOT added as subtrees (not subtrees — regular dirs):"
echo "  - projects/backburner"
echo "  - projects/NoizuPromptLingua"
echo "  - services/modal"
echo ""
echo "Commented out (repo 404 — verify):"
echo "  - projects/tobornalp.com"
echo "  - utilities/agent/run-claude"
echo "  - utilities/shell/tabbing-on"
