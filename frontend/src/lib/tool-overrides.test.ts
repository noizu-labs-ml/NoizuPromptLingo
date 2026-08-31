/**
 * Pure tests for W9 tool-override config helpers. No React, no DOM, no test
 * runner required — run with the project's existing tsx:
 *
 *   npx tsx src/lib/tool-overrides.test.ts
 *
 * Covers TOBOR-CONTRACTS.md §7: name_override / description_override /
 * arg_overrides entries in scope config jsonb, keyed by canonical underscore
 * tool name (§4), with toggle fields (disabled/hidden) preserved and empty
 * values pruned.
 */
import assert from 'node:assert/strict';
import { test } from 'node:test';

import {
  applyOverridePatch,
  canonicalToolName,
  hasOverrides,
  normalizeConfigToolKeys,
  overrideEntry,
} from './tool-overrides';
import type { McpCustomScopeConfig } from './api';

const base = (): McpCustomScopeConfig => ({
  groups: {
    sessions: {
      tools: {
        Session_Create: { disabled: true },
        'Session.List': { hidden: true }, // legacy dotted-key entry
      },
    },
  },
});

test('canonicalToolName normalizes dotted names', () => {
  assert.equal(canonicalToolName('Session.Create'), 'Session_Create');
  assert.equal(canonicalToolName('ToolCall'), 'ToolCall');
});

test('applyOverridePatch keys by canonical name and preserves toggles', () => {
  const next = applyOverridePatch(base(), 'sessions', 'Session_Create', {
    name_override: 'CreateSession',
  });
  const entry = next.groups.sessions.tools?.Session_Create;
  assert.equal(entry?.disabled, true, 'existing disabled flag must survive');
  assert.equal(entry?.name_override, 'CreateSession');
  // untouched legacy dotted entry stays put
  assert.ok(next.groups.sessions.tools?.['Session.List']);
});

test('applyOverridePatch migrates legacy dotted-key entry', () => {
  const next = applyOverridePatch(base(), 'sessions', 'Session.List', {
    description_override: 'List sessions (custom blurb)',
  });
  const tools = next.groups.sessions.tools ?? {};
  assert.equal(tools['Session.List'], undefined, 'dotted key must be migrated away');
  assert.equal(tools.Session_List?.hidden, true, 'hidden flag carried to canonical key');
  assert.equal(tools.Session_List?.description_override, 'List sessions (custom blurb)');
});

test('empty string overrides prune to nothing', () => {
  let cfg = applyOverridePatch(base(), 'sessions', 'Ticket_Create', {
    name_override: '   ',
    description_override: '',
    arg_overrides: { title: '  ' },
  });
  assert.equal(cfg.groups.sessions.tools?.Ticket_Create, undefined);

  cfg = applyOverridePatch(cfg, 'sessions', 'Ticket_Create', {
    name_override: 'X',
    description_override: undefined,
    arg_overrides: undefined,
  });
  assert.equal(cfg.groups.sessions.tools?.Ticket_Create?.name_override, 'X');

  // clearing (explicit empty values, as the editor emits) removes the entry
  cfg = applyOverridePatch(cfg, 'sessions', 'Ticket_Create', {
    name_override: '',
    description_override: '',
    arg_overrides: {},
  });
  assert.equal(cfg.groups.sessions.tools?.Ticket_Create, undefined);
});

test('arg_overrides keeps non-empty args and drops blank ones', () => {
  const cfg = applyOverridePatch(base(), 'sessions', 'Session_Create', {
    arg_overrides: { title: 'Session title', body: '' },
  });
  const args = cfg.groups.sessions.tools?.Session_Create?.arg_overrides;
  assert.deepEqual(args, { title: 'Session title' });
});

test('toggle-only entry survives a clear-overrides patch', () => {
  const cfg = applyOverridePatch(base(), 'sessions', 'Session_Create', {});
  const entry = cfg.groups.sessions.tools?.Session_Create;
  assert.deepEqual(entry, { disabled: true }, 'disabled toggle must not be wiped');
});

test('overrideEntry + hasOverrides round-trip', () => {
  let cfg = base();
  assert.equal(hasOverrides(cfg, 'sessions', 'Session_Create'), false);
  cfg = applyOverridePatch(cfg, 'sessions', 'Session_Create', {
    name_override: 'CreateSession',
    arg_overrides: { title: 't' },
  });
  const entry = overrideEntry(cfg, 'sessions', 'Session_Create');
  assert.equal(entry.name_override, 'CreateSession');
  assert.deepEqual(entry.arg_overrides, { title: 't' });
  assert.equal(hasOverrides(cfg, 'sessions', 'Session_Create'), true);
  assert.equal(hasOverrides(cfg, 'sessions', 'Session.List'), false);
});

test('source config is never mutated', () => {
  const cfg = base();
  applyOverridePatch(cfg, 'sessions', 'Session_Create', { name_override: 'Z' });
  assert.equal(cfg.groups.sessions.tools?.Session_Create?.name_override, undefined);
  assert.deepEqual(Object.keys(cfg.groups), ['sessions']);
});

// ── D3 dotted-write normalization ──────────────────────────────────────────

test('normalizeConfigToolKeys collapses dotted aliases under canonical entries', () => {
  const cfg = normalizeConfigToolKeys(base());
  const tools = cfg.groups.sessions.tools ?? {};
  assert.deepEqual(Object.keys(tools).sort(), ['Session_Create', 'Session_List']);
  assert.equal(tools.Session_Create?.disabled, true);
  // Session.List is the legacy dotted spelling of Session_List — its fields
  // ride the canonical key, and no dotted spelling survives.
  assert.equal(tools.Session_List?.hidden, true);
  assert.ok(!Object.keys(tools).some((k) => k.includes('.')), 'no dotted keys survive');
});

test('normalizeConfigToolKeys keeps multiple tools and non-tool group keys', () => {
  const cfg: McpCustomScopeConfig = {
    groups: {
      tickets: {
        hidden: true,
        tools: {
          'Ticket.List': { disabled: true },
          Ticket_Create: { hidden: true },
          'Ticket.Get': { name_override: 'fetch' },
        },
      },
    },
  };
  const next = normalizeConfigToolKeys(cfg);
  const tools = next.groups.tickets.tools ?? {};
  assert.deepEqual(Object.keys(tools).sort(), ['Ticket_Create', 'Ticket_Get', 'Ticket_List']);
  assert.equal(next.groups.tickets.hidden, true, 'group-level flags untouched');
  assert.equal(cfg.groups.tickets.tools?.['Ticket.List']?.disabled, true, 'input never mutated');
});

test('normalizeConfigToolKeys is a no-op on already-canonical configs', () => {
  const cfg: McpCustomScopeConfig = {
    groups: { sessions: { tools: { Session_Create: { disabled: true } } } },
  };
  assert.deepEqual(normalizeConfigToolKeys(cfg), cfg);
});
