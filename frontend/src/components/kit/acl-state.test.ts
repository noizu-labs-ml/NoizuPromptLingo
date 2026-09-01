import assert from 'node:assert/strict';
import test from 'node:test';
import type { AclRule, AclState } from '@/types/tool-state';
import {
  addGroupMember,
  addRule,
  patchResource,
  patchRule,
  removeGroupMember,
  removeRule,
  sameRef,
} from './acl-state';
import { newRowId } from './ids';

function state(rules: AclRule[] = [], groups: AclState['groups'] = []): AclState {
  return { rules, groups };
}

function rule(id: string, over: Partial<AclRule> = {}): AclRule {
  return { id, subject: { kind: 'any', id: '' }, resource: null, effect: 'deny', scope: 'read', priority: 0, ...over };
}

test('addRule appends a deny rule for the any-subject with the default scope', () => {
  const next = addRule(state([rule('a')]), 'admin');
  assert.equal(next.rules.length, 2);
  const added = next.rules[1];
  assert.equal(added.effect, 'deny');
  assert.deepEqual(added.subject, { kind: 'any', id: '' });
  assert.equal(added.resource, null);
  assert.equal(added.scope, 'admin');
  assert.equal(added.priority, 0);
  assert.ok(added.id && added.id !== 'a');
  // untouched state
  assert.deepEqual(state([rule('a')]).rules, [rule('a')]);
});

test('addRule keeps groups untouched and defaults scope to read', () => {
  const base = state([], [{ id: 'g1', name: 'ops', members: [] }]);
  const next = addRule(base);
  assert.deepEqual(next.groups, base.groups);
  assert.equal(next.rules[0].scope, 'read');
});

test('patchRule merges into the matching rule only', () => {
  const next = patchRule(state([rule('a'), rule('b', { effect: 'allow' })]), 'b', { effect: 'deny', scope: 'write' });
  assert.equal(next.rules[0].effect, 'deny');
  assert.equal(next.rules[1].effect, 'deny');
  assert.equal(next.rules[1].scope, 'write');
});

test('patchRule ignores unknown rule ids', () => {
  const base = state([rule('a')]);
  const next = patchRule(base, 'missing', { scope: 'write' });
  assert.deepEqual(next.rules, base.rules);
});

test('removeRule drops only the matching rule', () => {
  const next = removeRule(state([rule('a'), rule('b')]), 'a');
  assert.deepEqual(next.rules.map((r) => r.id), ['b']);
});

test('patchResource nulls the resource only when both kind and id are empty', () => {
  const withRef = rule('a', { resource: { kind: 'doc', id: 'd1' } });
  // clearing one half keeps the ref
  assert.deepEqual(patchResource(withRef, { kind: '' }).resource, { kind: '', id: 'd1' });
  assert.deepEqual(patchResource(withRef, { id: '' }).resource, { kind: 'doc', id: '' });
  // clearing both halves nulls it
  assert.equal(patchResource(patchResource(withRef, { kind: '' }), { id: '' }).resource, null);
  // setting on a null resource creates the ref
  assert.deepEqual(patchResource(rule('a'), { kind: 'doc' }).resource, { kind: 'doc', id: '' });
});

test('addGroupMember dedupes on kind+id (no duplicate members)', () => {
  const group = { id: 'g1', name: 'ops', members: [{ kind: 'client', id: 'c1' }] };
  const again = addGroupMember(group, { kind: 'client', id: 'c1', label: 'ignored label' });
  assert.equal(again, group); // no-op returns the same object
  const added = addGroupMember(group, { kind: 'client', id: 'c2' });
  assert.deepEqual(added.members, [{ kind: 'client', id: 'c1' }, { kind: 'client', id: 'c2' }]);
  // label difference does not defeat dedupe
  assert.equal(addGroupMember(group, { kind: 'client', id: 'c1', label: 'Other' }), group);
});

test('removeGroupMember removes all matching members', () => {
  const group = { id: 'g1', name: 'ops', members: [{ kind: 'client', id: 'c1' }, { kind: 'user', id: 'u1' }] };
  const next = removeGroupMember(group, { kind: 'client', id: 'c1' });
  assert.deepEqual(next.members, [{ kind: 'user', id: 'u1' }]);
});

test('sameRef ignores labels and compares kind+id', () => {
  assert.ok(sameRef({ kind: 'client', id: 'c1' }, { kind: 'client', id: 'c1', label: 'x' }));
  assert.ok(!sameRef({ kind: 'client', id: 'c1' }, { kind: 'client', id: 'c2' }));
  assert.ok(!sameRef({ kind: 'client', id: 'c1' }, { kind: 'user', id: 'c1' }));
});

test('newRowId is unique across calls', () => {
  const seen = new Set(Array.from({ length: 200 }, () => newRowId('acl')));
  assert.equal(seen.size, 200);
  for (const id of seen) assert.ok(id.startsWith('acl-'));
});
