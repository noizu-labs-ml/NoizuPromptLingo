/**
 * PRD-020 FR-6 contract tests for the endpoint-creation wizard's pure logic
 * module (`endpoint-wizard-state.ts`): slug derivation, the wizard reducer,
 * proposal application, and the proposal -> jsonb config mapping.
 *
 * Pure logic only — node test runner, no DOM, no React.
 *
 * NOTE (TDD contract pin): the PRD names the exported functions and the
 * EndpointWizardState shape; the WizardAction union below is the test-pinned
 * action vocabulary the implementation must satisfy:
 *
 *   { type: 'set_name'; value: string }
 *   { type: 'set_description'; value: string }
 *   { type: 'set_slug'; value: string }                    // manual edit
 *   { type: 'set_answer'; questionId: string; value: string }
 *   { type: 'questions_received'; questions: ClarifyQuestion[] }
 *   { type: 'skip_to_manual' }                             // D2: step 2 skippable
 *   { type: 'llm_unavailable' }                            // D3: fallback path
 *   { type: 'clone_prefill'; source: { id?: string; slug?: string; kind: 'template' | 'own'; name: string; description: string } }
 *   { type: 'cancel' }                                     // clean reset
 */
import assert from 'node:assert/strict';
import { test } from 'node:test';

import {
  applyProposal,
  deriveSlug,
  proposalToConfig,
  reduceWizard,
  type EndpointWizardState,
  type WizardToolSelection,
} from './endpoint-wizard-state';

const initialState = (overrides: Partial<EndpointWizardState> = {}): EndpointWizardState => ({
  mode: 'create',
  name: '',
  description: '',
  slug: '',
  slugTouched: false,
  slugStatus: null,
  questions: [],
  answers: {},
  selections: [],
  proposalSummary: null,
  status: 'idle',
  error: null,
  // Alacarte step-1 display metadata (implementation-added field).
  display: null,
  ...overrides,
});

// ── AT-7: deriveSlug ─────────────────────────────────────────────────────────

test('deriveSlug kebab-cases, collapses separators and trims hyphens', () => {
  assert.equal(deriveSlug('Support Bot'), 'support-bot');
  assert.equal(deriveSlug('Support   Bot!!'), 'support-bot');
  assert.equal(deriveSlug('  Many   Spaces & STUFF  '), 'many-spaces-stuff');
  assert.equal(deriveSlug('-Leading_Trailing-'), 'leading-trailing');
});

test('deriveSlug caps at 63 characters', () => {
  const slug = deriveSlug('X'.repeat(100));
  assert.ok(slug.length <= 63, `expected <= 63, got ${slug.length}`);
  assert.ok(!slug.endsWith('-'), 'slug must not end with a hyphen after capping');
});

test('deriveSlug returns the empty string when nothing valid survives', () => {
  assert.equal(deriveSlug(''), '');
  assert.equal(deriveSlug('!!!'), '');
  assert.equal(deriveSlug('---'), '');
});

test('reducer: derivation stops after the first manual slug edit', () => {
  let state = initialState();
  state = reduceWizard(state, { type: 'set_name', value: 'Support Bot' });
  assert.equal(state.slug, 'support-bot');
  assert.equal(state.slugTouched, false);

  state = reduceWizard(state, { type: 'set_slug', value: 'my-own-slug' });
  assert.equal(state.slugTouched, true);

  state = reduceWizard(state, { type: 'set_name', value: 'Renamed Bot' });
  assert.equal(state.name, 'Renamed Bot');
  assert.equal(state.slug, 'my-own-slug', 'manual slug must never be re-derived');
  assert.equal(state.slugTouched, true);
});

// ── AT-8: reducer ────────────────────────────────────────────────────────────

test('reducer: name/description/slug edits keep the rest of the state intact', () => {
  const state = initialState({
    description: 'Answers support questions',
    answers: { 'r1-1': 'Read-only' },
  });

  const next = reduceWizard(state, { type: 'set_name', value: 'Support Bot' });
  assert.equal(next.name, 'Support Bot');
  assert.equal(next.description, state.description);
  assert.deepEqual(next.answers, state.answers);
});

test('reducer: questions/answers flow preserves earlier answers', () => {
  let state = initialState({ name: 'Support Bot', description: 'Answers tickets' });

  state = reduceWizard(state, { type: 'questions_received', questions: [] });
  state = reduceWizard(state, { type: 'set_answer', questionId: 'r1-1', value: 'Human agents' });
  state = reduceWizard(state, { type: 'set_answer', questionId: 'r1-2', value: '9-5' });

  assert.deepEqual(state.answers, { 'r1-1': 'Human agents', 'r1-2': '9-5' });
  assert.equal(state.name, 'Support Bot', 'answers must not clobber step-1 fields');
});

test('reducer: llm_unavailable falls back to the manual picker with state preserved', () => {
  let state = initialState({
    name: 'Support Bot',
    description: 'Answers tickets',
    answers: { 'r1-1': 'Human agents' },
    selections: [selection('Ticket_Create', 'tickets')],
  });

  state = reduceWizard(state, { type: 'llm_unavailable' });

  assert.equal(state.status, 'fallback');
  assert.equal(state.name, 'Support Bot');
  assert.equal(state.description, 'Answers tickets');
  assert.deepEqual(state.answers, { 'r1-1': 'Human agents' });
  assert.equal(state.selections.length, 1);
});

test('reducer: skip-to-manual routes to the fallback picker (D2)', () => {
  const state = reduceWizard(initialState(), { type: 'skip_to_manual' });
  assert.equal(state.status, 'fallback');
});

test('reducer: clone prefill sets mode + fields from the source (FR-6 step 1)', () => {
  const state = reduceWizard(initialState(), {
    type: 'clone_prefill',
    source: {
      slug: 'core',
      kind: 'template',
      name: 'Core Locker',
      description: 'The core toolset',
    },
  });

  assert.equal(state.mode, 'clone');
  assert.equal(state.name, 'Core Locker');
  assert.equal(state.description, 'The core toolset');
  assert.equal(state.slug, 'core');
  assert.notEqual(state.source, undefined);
  assert.equal(state.source?.slug, 'core');
  assert.equal(state.source?.kind, 'template');
});

test('reducer: cancel resets to a clean wizard', () => {
  let state = initialState();

  state = reduceWizard(state, { type: 'set_name', value: 'Support Bot' });
  state = reduceWizard(state, { type: 'set_answer', questionId: 'r1-1', value: 'x' });
  state = applyProposal(state, [proposed('Ticket_Create', 'tickets')], 'Focused.');

  state = reduceWizard(state, { type: 'cancel' });

  assert.deepEqual(state, initialState());
});

// ── applyProposal (FR-6 step 3) ──────────────────────────────────────────────

test('applyProposal: every proposal defaults to enabled + visible', () => {
  const state = initialState({ name: 'Support Bot', description: 'Answers tickets' });

  const next = applyProposal(
    state,
    [proposed('Ticket_Create', 'tickets'), proposed('Wiki_Search', 'wiki')],
    'A focused support toolkit.',
  );

  assert.deepEqual(
    next.selections,
    [
      { name: 'Ticket_Create', group: 'tickets', rationale: 'Files tickets.', enabled: true, visible: true },
      { name: 'Wiki_Search', group: 'wiki', rationale: 'Finds answers.', enabled: true, visible: true },
    ] satisfies WizardToolSelection[],
  );
  assert.equal(next.proposalSummary, 'A focused support toolkit.');
  assert.equal(next.name, 'Support Bot', 'proposal must not clobber step-1 fields');
});

// ── AT-9: proposalToConfig ───────────────────────────────────────────────────

test('proposalToConfig: enabled+visible maps to an empty tool entry', () => {
  const config = proposalToConfig([selection('Ticket_Create', 'tickets')]);

  assert.deepEqual(config.groups.tickets?.tools?.Ticket_Create, {});
});

test('proposalToConfig: disabled+visible maps to { disabled: true } only', () => {
  const config = proposalToConfig([selection('Ticket_Create', 'tickets', false, true)]);

  assert.deepEqual(config.groups.tickets?.tools?.Ticket_Create, { disabled: true });
});

test('proposalToConfig: enabled+hidden maps to { hidden: true } only', () => {
  const config = proposalToConfig([selection('Ticket_Create', 'tickets', true, false)]);

  assert.deepEqual(config.groups.tickets?.tools?.Ticket_Create, { hidden: true });
});

test('proposalToConfig: disabled+hidden maps to both flags', () => {
  const config = proposalToConfig([selection('Ticket_Create', 'tickets', false, false)]);

  assert.deepEqual(config.groups.tickets?.tools?.Ticket_Create, {
    disabled: true,
    hidden: true,
  });
});

test('proposalToConfig: buckets each selection under its own group', () => {
  const config = proposalToConfig([
    selection('Ticket_Create', 'tickets'),
    selection('Wiki_Search', 'wiki'),
  ]);

  assert.ok(config.groups.tickets?.tools?.Ticket_Create);
  assert.ok(config.groups.wiki?.tools?.Wiki_Search);
});

// ── fixtures ─────────────────────────────────────────────────────────────────

function selection(
  name: string,
  group: string,
  enabled = true,
  visible = true,
): WizardToolSelection {
  return { name, group, rationale: 'Because.', enabled, visible };
}

function proposed(name: string, group: string) {
  return { name, group, rationale: name === 'Ticket_Create' ? 'Files tickets.' : 'Finds answers.' };
}
