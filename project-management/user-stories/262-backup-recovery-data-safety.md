# US-262: Backup, Recovery & Data Safety

**Persona:** Dave — MUD veteran who has lost irreplaceable game worlds to hardware failures and will not let it happen again
**Priority:** P0
**Epic:** Admin, GM & Infrastructure

## Story
As Dave, I want automated backups with point-in-time recovery, tested disaster recovery procedures, and GDPR-compliant player data export so that no hardware failure, corrupted migration, or regulatory requirement puts the game or its players at risk.

## Acceptance Criteria
- [ ] PostgreSQL WAL archiving enabled; continuous WAL streaming to off-site object storage (S3-compatible); full base backups taken daily at 02:00 UTC; base backups retained for 30 days; WAL retained to support PITR to any point within the retention window
- [ ] Recovery time objective (RTO): full database restore from base backup completable in under 30 minutes on target hardware; tested and documented quarterly; PITR to a specific timestamp completable in under 60 minutes; restoration procedures documented in ops runbook accessible to all Senior GM+
- [ ] Player data export (GDPR Article 20 — data portability): players can request their data export via `/account export`; export is generated within 72 hours and delivered via in-game mail as a link to a time-limited download URL; export includes: character data, chat history (30 days), transaction history (90 days), account settings, reputation reviews given and received
- [ ] Account deletion (GDPR Article 17 — right to erasure): `/account delete` initiates a 14-day grace period during which the account is deactivated but not deleted; after 14 days, personal data is purged (character name, email, IP logs); anonymized gameplay data (aggregate statistics) may be retained; deletion is irreversible and confirmed via two-step: command + email link
- [ ] Disaster recovery runbook: documented step-by-step procedures for: primary database failure (failover to replica), complete data center loss (restore from off-site backup), corrupted deploy (rollback procedure per US-265), accidental mass-deletion (PITR to pre-deletion timestamp); runbook reviewed and updated quarterly
- [ ] Backup integrity validation: each base backup is automatically restored to a validation environment and tested for basic query success within 4 hours of creation; validation failures trigger immediate alert to on-call engineer; backup that fails validation is not counted toward retention window
- [ ] Off-site backup storage in a geographically separate region (minimum 500km from primary); backup storage encrypted at rest with customer-managed keys (not provider-managed); key rotation annual
- [ ] Quarterly disaster recovery drill: Senior Engineering + Dave simulate a disaster scenario (drawn from a rotation: database failure, data center loss, corrupted migration, accidental deletion); drill is time-boxed to 4 hours; results documented; gaps in runbook updated; drill cadence is calendar-scheduled and non-negotiable

## Notes
Dave has run MUDs long enough to know that backups that aren't tested are not backups — they're hope. The backup integrity validation automation (restore to a validation environment, test queries) is the insurance on the insurance. Without it, you find out your backups are broken at the worst possible moment.

WAL archiving is the correct approach over periodic dump-based backups because it provides continuous protection. A nightly dump means up to 24 hours of data loss on failure. WAL archiving means loss is limited to the most recent uncommitted transactions (seconds to minutes). For a game where players spend hours earning items and experience, the difference between "you lost 4 minutes of progress" and "you lost 23 hours of progress" is existential.

The GDPR implementation detail: "anonymized gameplay data may be retained" means aggregate statistics (total kills in the world, economy totals, event attendance counts) that genuinely cannot be re-linked to an individual. Per-player statistics that retain character name, timestamps, and specific actions are not anonymous enough to retain after erasure. The definition of "anonymous" should be reviewed by legal counsel before the deletion feature ships.

The 14-day grace period for account deletion is player-protective (prevents impulsive deletion of years of progress) and operationally useful (reduces irreversible mistakes). Players in the grace period should be able to reactivate by logging in. The grace period should be clearly communicated in the confirmation dialog.

Backup storage key management is a security and business continuity concern. Customer-managed keys mean the game operator (not the cloud provider) controls access to backup data. This protects against cloud provider account compromise. Key rotation annual is the minimum; consider more frequent rotation if the threat model warrants it. Keys must be stored in a separate secrets management system (Infisical, per the infra repo's pattern) with their own backup.

The quarterly DR drill is a cultural commitment as much as a technical one. It must be calendar-scheduled and non-negotiable — the common failure mode is "we'll do it when things are quiet" and things are never quiet. The drill should rotate scenarios so the team builds competency across failure modes, not just the most likely one.
