import assert from 'node:assert/strict';
import test from 'node:test';
import type { AclRule } from '@/types/tool-state';
import { denyFirst, parseRef, refLabel } from './acl-editor';

function rule(id: string, effect: 'allow' | 'deny', kind: string, rid: string): AclRule {
  return { id, effect, subject: { kind, id: rid }, resource: null, scope: 'read', priority: 0 };
}

test('denyFirst sorts deny rules before allow rules', () => {
  const ordered = denyFirst([
    rule('a', 'allow', 'client', 'c1'),
    rule('b', 'deny', 'client', 'c2'),
    rule('c', 'allow', 'user', 'u1'),
    rule('d', 'deny', 'user', 'u2'),
  ]);
  assert.deepEqual(
    ordered.map((r) => r.effect),
    ['deny', 'deny', 'allow', 'allow'],
  );
});

test('denyFirst is stable within an effect and does not mutate input', () => {
  const input = [rule('a', 'allow', 'client', 'c1'), rule('b', 'deny', 'client', 'c2')];
  const ordered = denyFirst(input);
  assert.deepEqual(ordered.map((r) => r.id), ['b', 'a']);
  assert.deepEqual(input.map((r) => r.id), ['a', 'b']);
});

test('parseRef parses kind:id and bare ids', () => {
  assert.deepEqual(parseRef('client:key-1'), { kind: 'client', id: 'key-1' });
  assert.deepEqual(parseRef(' key-1 '), { kind: 'any', id: 'key-1' });
  assert.equal(parseRef(''), null);
  assert.equal(parseRef('broken:'), null);
});

test('refLabel prefers the display label and falls back to kind:id', () => {
  assert.equal(refLabel({ kind: 'client', id: 'k1', label: 'CI runner' }), 'CI runner (client:k1)');
  assert.equal(refLabel({ kind: 'client', id: 'k1' }), 'client:k1');
});
