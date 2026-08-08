#!/usr/bin/env bash
# Run durable dual-path tests for Project List/Get/Resolve/Create (pm_core cutover).
#
# Covers:
#   - source contracts (List dual-path, Resolve PM prefer, Get via Resolve,
#     Create rescue/format_create_error/"already exists",
#     app+vendor schema name: :uq_projects_org_slug)
#   - legacy List/Get/Resolve live path
#   - PM-entry fallback without live Repo
#   - optional :pm_core_live (insert via Noizu.PM.Repo)
#
# Usage (from backend/):
#   ./scripts/run_project_dual_path_tests.sh
#   ./scripts/run_project_dual_path_tests.sh --live   # also require PM_CORE_DATABASE_URL
#
# Full PM path (insert via Noizu.PM.Repo, list via Project.List):
#   export PM_CORE_DATABASE_URL='ecto://USER:PASS@HOST:5432/noizu_prompt_lingua_test'
#   ./scripts/run_project_dual_path_tests.sh --live
set -euo pipefail
cd "$(dirname "$0")/.."

FILES=(
  test/noizu_prompt_lingua/pm_core_test.exs
  test/noizu_prompt_lingua/mcp/project_dual_path_test.exs
)

if [[ "${1:-}" == "--live" ]]; then
  if [[ -z "${PM_CORE_DATABASE_URL:-}" ]]; then
    echo "error: --live requires PM_CORE_DATABASE_URL" >&2
    exit 1
  fi
  echo "Running dual-path tests including :pm_core_live against PM_CORE_DATABASE_URL"
  exec mix test "${FILES[@]}" --include pm_core_live
fi

echo "Running dual-path tests (legacy + source contracts + Create/constraint + PM-entry fallback)"
echo "Tip: set PM_CORE_DATABASE_URL and pass --live for insert-via-PM coverage"
exec mix test "${FILES[@]}" --exclude pm_core_live
