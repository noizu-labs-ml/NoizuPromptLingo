-- Seed invite token for local testing.
-- Run: docker exec -i lets-go-db-1 psql -U mermaid -d mermaid_dev -f /dev/stdin < scripts/seed-dev.sql
--
-- After seeding, use the signup page at /auth/signup with:
--   Invite token: noizu-invite-2026
--   Email: any valid email
--   Password: at least 8 characters
--
-- Or use the pre-created dev account:
--   Email: dev@noizu.com
--   Password: devpass123

-- Invite token: reusable, 100 uses, no expiry
INSERT INTO invite_tokens (id, token, created_by, max_uses, use_count, created_at)
VALUES (
  'inv_dev_001',
  'noizu-invite-2026',
  NULL,
  100,
  0,
  NOW()
)
ON CONFLICT (id) DO UPDATE SET use_count = 0;
