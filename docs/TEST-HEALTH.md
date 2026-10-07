# Test Health — NoizuPromptLingo
_Last measured: 2026-10-07 · branch develop@acc0b0b92 (+ PR #74)_

CI = `.github/workflows/ci.yml`. Jobs: `test-backend` (smoke gate), `test-frontend`
(npm ci + tsc), `build-push` (main release lane, parallel to tests) → `promote-release`
→ `bump-chart`; stage twins on `refs/heads/stage`. Before-numbers from runs 34383345443
(PR, warm), 35602316635 (PR, cold), 34384148016 (main, warm), 35603498646 (main, cold).
After-numbers from PR #74 runs 37569682761 (cold, new cache key) and 37570108458 (warm).

| Metric | Before | After |
|---|---|---|
| CI PR wall-clock — critical path (warm / cold) | 142s / 427s (test-backend) | 103s / 235s |
| Main release build (warm / cold) | 171s / 485s (first job start → bump-chart end) | not yet measured (needs a release); cold build expected ≈ max(253, 170)s via parallel matrix legs |
| CI acceptance test job (warm / cold) | 142s / 427s | 103s / 235s |
| Local full-suite runtime (uptime load) | not measured — host load 45–58; CI is authoritative | — |
| Docker build (warm / cold) | 100s / 452s (backend 253s + frontend 170s, serial) | parallel matrix legs; unmeasured until a release |
| Tests in acceptance / slow tier | 344 tests (19 curated files, `mix smoke`) / full suite manual-only | same / full suite nightly |
| Async modules / total | 44 / 294 test files | 44 / 294 |
| Coverage — acceptance pass | not measured | 17.2% (ExCoveralls, smoke) |
| Coverage — full pass | not measured in CI | nightly report (`coverage-full` artifact) |
| Coverage gate | — | 12% (`backend/coveralls.json` minimum_coverage) |

Where test-backend time went before (cold PR): containers 34s, `mix compile` (:dev, unused)
169s, `MIX_ENV=test mix ecto.create` 165s (full :test recompile), Liquibase 10s, smoke 28s
(25.6s of tests: 2.3s async / 23.2s sync). Warm PRs only stayed warm while the exact
lock-hash cache was alive; it never re-saved, and no caches survived the 12-day gap
before the 2026-09-21 release.
After: one compile in :test (138s cold, incremental warm — no compile step ≥3s), smoke
tests 9.0–16.7s (bcrypt `log_rounds: 4`; was 25.6s), `--cover` instrumentation adds
~10–15s to the smoke step.

## Caching status
- GitHub Actions: deps ✅ · build ✅ (re-saved per sha, keyed on OTP/Elixir + lock, prefix restore) · npm ✅ · .next/cache n.a. (no `next build` in CI) · PLT n.a. (no dialyzer) · develop-ref seeding ✅ (`push: develop` added — test jobs only)
- Docker: buildx gha cache ✅ (log-verified: main 09-09 backend 9s / frontend 63s warm; 09-21 cold after a 12-day gap) · cache mounts ✅ (backend hex/deps/_build, per-arch ids) · .dockerignore ✅ · release-cache warmer ✅ (nightly `warm-docker-cache`, main ref, `push: false`)

## Slow tests (tier: nightly)
| Test | Time | Why slow | Fix idea |
|---|---|---|---|
| Full exhaustive suite (`mix test --exclude memory --exclude live_trp`) | not timed | 294 files incl. non-hermetic suites; curated out of the push gate by design | runs nightly (schedule) with coverage; promote stable suites into `mix smoke` |

## Test debt
| Item | Kind | Notes |
|---|---|---|
| Push gate covers 19 of 294 test files | coverage gap | Curated hermetic subset (`mix smoke`); the rest only ran on manual dispatch until the nightly |
| `:memory` suites (live Weaviate) | skipped | Need Cloudflare-Access-authed Weaviate; never run in CI |
| `:live_trp` contract suite | skipped | Opt-in at activation (TRP_LIVE_CONTRACT_URL/KEY) |
| Frontend `test:contracts` (12 node:test files) | coverage gap | Exist but not wired into CI (CI = npm ci + tsc only); cheap to add |
| Frontend Playwright / Cypress e2e | skipped | Not wired into CI |
| Python `tests/` (40 pytest files, legacy `src/npl_mcp` tooling) | coverage gap | No CI job; legacy server superseded by the Phoenix backend |
| Smoke run is ~88% sync (14.8s of 16.7s) | sync-only | Test step is no longer the critical-path driver; not worth the async flake hunt this pass |

Entity UID collisions / sref race: none outstanding. `noizu_labs_entities` 0.3.4 mints ids with the library
default `Noizu.Entity.UID.Default` (no app-level `:uid_provider`).
`backend/test/noizu_prompt_lingua/entities/entity_uid_concurrency_test.exs` creates 50 versioned strings
concurrently and asserts unique ids that round-trip (`fetched.id == created.id`, all listed). It fails with the old
`{ms, 0}` stub. `test/test_helper.exs` warms the sref handler table (`EntityRepo.warm_sref_handlers/0`) before the
suite, and `Application.start/2` does the same at boot.

## Nightly
`ci.yml` `schedule: "23 7 * * *"` (main): `test-backend` + `test-frontend` (warm main-ref
mix/npm caches), `test-backend-exhaustive` (full suite + full-pass coverage artifact),
`warm-docker-cache` (build-only, `push: false`). No image push / chart bump on schedule —
those jobs stay gated on `github.event_name == 'push'` + ref.
