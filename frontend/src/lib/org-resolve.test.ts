/**
 * Pure tests for the org route-segment resolver. No React, no DOM, no test
 * runner required — run with the project's existing tsx:
 *
 *   npx tsx src/lib/org-resolve.test.ts
 *
 * Covers ticket 74f5eaeb: a stray/undefined org segment must never resolve to a
 * *different* active org than the one already in context (the "unset active org"
 * regression), and a UUID landing in the slug position must still resolve.
 */
import assert from 'node:assert/strict';
import { resolveOrg } from './org-resolve';
import type { Organization } from './api';

const org = (id: string, slug: string): Organization =>
  ({ id, slug, name: slug } as Organization);

const orgs = [org('11111111-1111-1111-1111-111111111111', 'noizu-labs'), org('22222222-2222-2222-2222-222222222222', 'acme')];
const current = orgs[0];

let passed = 0;
function check(label: string, fn: () => void) {
  fn();
  passed += 1;
  console.log(`  ok  ${label}`);
}

// Canonical: route segment is the slug.
check('resolves by slug', () => assert.equal(resolveOrg(orgs, 'noizu-labs'), orgs[0]));

// The bug: a UUID interpolated into the slug position must still resolve, not null.
check('resolves a UUID in the slug position (self-heals legacy links)', () =>
  assert.equal(resolveOrg(orgs, '11111111-1111-1111-1111-111111111111'), orgs[0]));

// Guard invariant: an unknown/empty/undefined segment resolves to null, and the
// caller's fallback to `current` must never yield a *different* org — i.e. a
// leaked-undefined segment can never silently switch (or unset) the active org.
for (const bad of [undefined, null, '', 'not-an-org', '00000000-0000-0000-0000-000000000000'] as const) {
  check(`unknown/empty segment (${JSON.stringify(bad)}) -> null, fallback keeps current org`, () => {
    const resolved = resolveOrg(orgs, bad);
    assert.equal(resolved, null);
    const active = resolved ?? current; // the fallback useAppNav/useOrgId apply
    assert.equal(active, current);
  });
}

// Resolving by either form returns the same canonical org (so URL building from
// `org.slug` self-heals regardless of which form the param carried).
check('slug and id forms resolve to the same canonical org', () =>
  assert.equal(
    resolveOrg(orgs, 'acme'),
    resolveOrg(orgs, '22222222-2222-2222-2222-222222222222'),
  ));

console.log(`\n${passed} assertions passed.`);
