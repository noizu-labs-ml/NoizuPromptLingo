#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Canonical coverage invocation for the NPL backend (measurement-integrity recipe).
#
# WHY THIS SCRIPT EXISTS
# Coverage numbers are only trustworthy under MIX_ENV=test. In :dev the Endpoint
# compiles in Phoenix.CodeReloader, so requests trigger reload!/purge — a purged
# module reloads from its plain beam and silently reports exact-zero coverage
# while tests stay green (and :cover.analyse can crash ExCoveralls with
# {:error, :not_cover_compiled}). MIX_ENV=dev overrides coveralls'
# @preferred_cli_env, so the environment is enforced HERE and in
# test/test_helper.exs (hard guard).
#
# USAGE
#   scripts/coverage.sh                    # full suite → cover/excoveralls.json
#   scripts/coverage.sh test/path/x_test.exs [more files…]   # scoped run
#   scripts/coverage.sh --detail           # extra args pass through to mix coveralls
#
# NOTES
#   * Worktree recipe: deps/ is a symlink to the main checkout's deps/ — leave it.
#   * Test DB: noizu_prompt_lingua_test (+ $MIX_TEST_PARTITION), see config/test.exs.
#   * For comparable numbers: one suite per machine-moment — don't run suites
#     concurrently in the same worktree (shared _build + shared test DB).
#   * Parse per-file numbers:
#       python3 - <<'EOF'
#       import json
#       d = json.load(open('cover/excoveralls.json'))
#       for f in d['source_files']:
#           rel = [c for c in f['coverage'] if c is not None]
#           hit = [c for c in rel if c]
#           print(f"{len(hit)/len(rel)*100 if rel else 0:5.1f}%  {f['name']}")
#       EOF
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ -n "${MIX_ENV:-}" && "${MIX_ENV}" != "test" ]]; then
  echo "ERROR: MIX_ENV=${MIX_ENV} is set — unset it; coverage must run in MIX_ENV=test" >&2
  echo "       (see test/test_helper.exs measurement-integrity guards for why)." >&2
  exit 1
fi

if [[ ! -L deps ]]; then
  echo "NOTE: deps/ is not a symlink — main-checkout layout? Continuing." >&2
fi

if pgrep -x beam.smp >/dev/null 2>&1; then
  echo "WARNING: another BEAM is running; concurrent suites share _build + the test DB" >&2
  echo "         and can corrupt each other's numbers. Wait for it or expect skew." >&2
fi

export MIX_ENV=test
mix coveralls.json "$@"
echo "==> per-file report written to cover/excoveralls.json"
