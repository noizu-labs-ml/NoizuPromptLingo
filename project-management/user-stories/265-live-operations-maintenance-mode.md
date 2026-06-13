# US-265: Live Operations & Maintenance Mode

**Persona:** Dave — MUD veteran sysadmin who wants zero-downtime operations and graceful degradation
**Priority:** P1
**Epic:** Admin, GM & Infrastructure

## Story
As Dave, I want to deploy updates and run maintenance without taking the game offline so that players never lose a session to a scheduled maintenance window, and so that canary deployments let me validate changes on a small percentage of traffic before full rollout.

## Acceptance Criteria
- [ ] Rolling deployments: Kubernetes rolling update strategy configured for all Phoenix node deployments; new pods are brought up before old pods are terminated; minimum 1 healthy pod maintained at all times during deploy; deploy is fully automated via the project's `helm-upgrade` pipeline
- [ ] WebSocket session continuity during rolling deploy: clients connect to load balancer, not directly to pods; when a pod is terminated during rolling deploy, affected WebSocket clients reconnect automatically (client-side reconnect with exponential backoff); reconnected clients restore session from database checkpoint (per US-262); player sees: "Connection briefly interrupted. Reconnecting..." — no data loss beyond the checkpoint window
- [ ] Maintenance mode: `/gm maintenance on [duration] [message]` initiates a maintenance countdown; players receive ARIA live region announcement: "Server maintenance begins in 15 minutes. Please find a safe location. [optional GM message]"; countdown reminders at 15, 10, 5, and 1 minute; at maintenance start, new connections are rejected with maintenance message; existing connections are gracefully closed after countdown
- [ ] Player state preservation on maintenance: when maintenance mode closes connections, player state is checkpointed to database immediately (not waiting for the 30-second cycle); players logging back in after maintenance are restored to their last saved location with a narrated message: "You wake from a strange dream, finding yourself exactly where you were."
- [ ] Canary deployments: deploy pipeline supports deploying new image to a configurable percentage of pods (default: 10%); canary pods serve a percentage of new WebSocket connections; canary is monitored for error rate and latency vs. stable pods; if canary error rate exceeds stable by 2x, automatic rollback is triggered; canary can be promoted to full rollout or rolled back via single command
- [ ] Database migrations run before pod rollout via a Kubernetes Job; migration job must complete successfully before new pods are started; if migration fails, pod rollout is blocked and alert fires; migrations must be backward-compatible with the previous application version (old code + new schema must work) to support rolling deploy
- [ ] Deployment notifications: all GM Lead+ staff notified 24 hours before a planned deploy via in-game mail and email; deploy start/complete logged in GM audit trail; players notified of completed deploys via world announcement if the deploy included player-facing changes (patch notes)
- [ ] Emergency rollback: `helm-rollback <release>` returns all pods to the previous version within 5 minutes; database migrations are forward-only (no down migrations) but rollback is designed to work with the previous schema version; rollback procedure tested in staging before each production deploy

## Notes
Dave's zero-downtime standard is a professional pride and player experience issue combined. MUDs traditionally had maintenance windows; modern online games do not. The zero-downtime architecture is not a nice-to-have — it's a commitment to players that their time is valued.

The backward-compatible migration requirement is the most technically demanding constraint. Every database migration must leave the schema in a state where both the current version and the previous version of the application can operate. This means: new columns are nullable or have defaults, old columns are not dropped until the new code has been running for at least one full deploy cycle (two-step deprecation), and index additions are done concurrently (no table locks). This pattern is known as "expand and contract" — expand the schema to support new behavior, deploy new code, then contract the schema by removing old columns in a subsequent migration.

Canary deployment percentage should be configurable without a redeploy. The ability to say "increase canary to 25%, I want more signal" and have that take effect immediately (via a config map change or a feature flag update, not a new deployment) is operationally valuable. The canary percentage should be surfaced in the GM dashboard (US-258) alongside the canary vs. stable error rate comparison.

The automatic rollback trigger (canary error rate 2x stable) needs careful calibration. Too sensitive and every canary triggers a false rollback on normal traffic variance; too loose and a bad deploy reaches 10% of players before rollback. The 2x threshold with a 5-minute observation window (not instant) is a reasonable starting point. The threshold and window should be configurable.

Maintenance mode UX for screen reader users: the countdown announcements must be delivered via `aria-live="polite"` so they don't interrupt active interactions, but the final warning (1 minute) should be `aria-live="assertive"`. The maintenance message should be specific about what's happening: "Server maintenance for version 2.4.0 begins in 1 minute. All progress has been saved." Vague messages ("server will be down shortly") create anxiety; specific messages create confidence.

Patch notes delivered as a world announcement post-deploy should be accessible: structured as a heading ("Version 2.4.0 Update") followed by a bulleted list of changes, delivered via ARIA live region in segments (not one massive block). Players who miss the live announcement can access patch notes via `/news` command for 7 days after deployment.
