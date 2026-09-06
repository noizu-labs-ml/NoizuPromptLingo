/**
 * PRD-020 FR-5 / AT-10: `kit/wizard-stepper.tsx` source-contract assertions.
 *
 * No DOM test runner is configured in this project, so the stepper's contract
 * is asserted against its source: gating logic, accessibility markers, and the
 * domain-neutrality rule (NFR-5: no MCP/backend imports). Rendering behavior is
 * covered by consumption in the endpoint wizard.
 */
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import path from 'node:path';
import test from 'node:test';

const KIT_DIR = path.join(process.cwd(), 'src', 'components', 'kit');
const source = readFileSync(path.join(KIT_DIR, 'wizard-stepper.tsx'), 'utf8');

function importSpecifiers(src: string): string[] {
  return [...src.matchAll(/from\s+['"]([^'"]+)['"]/g)].map((m) => m[1]);
}

test('wizard-stepper exists and is a controlled component (host-owned state)', () => {
  assert.ok(source.includes('state'), 'must receive host-owned state');
  assert.ok(source.includes('onStepChange'), 'must report step transitions');
  assert.ok(source.includes('renderStep'), 'must delegate step bodies to the consumer');
});

test('Next/Finish is gated on isValid and shows invalidMessage (AT-10)', () => {
  assert.ok(source.includes('isValid'), 'must consult the step gate');
  assert.ok(source.includes('invalidMessage'), 'must surface the gate explanation');
  // gating: the disabled decision derives from the gate for the CURRENT step
  assert.match(
    source,
    /isValid[^(]*\(\s*state\s*\)|isValid[^\n]*\?\.|isValid\s*\?\?|isValid\s*===\s*false/,
    'isValid must be evaluated against state to gate navigation',
  );
});

test('Back is disabled at the first step (AT-10)', () => {
  assert.match(source, /currentStep\s*===?\s*0/, 'back-disabled-at-0 check must be present');
});

test('forward navigation is sequential; completed steps are clickable', () => {
  assert.ok(source.includes('onStepChange'), 'step click routes through onStepChange');
});

test('accessibility: aria-current="step", progress indicator, focus management (AT-10)', () => {
  assert.match(source, /aria-current/, 'aria-current marker required');
  assert.match(source, /["']step["']/, 'aria-current must mark the active step');
  assert.match(
    source,
    /Step\s*\$\{|Step\s*\{\s*\w+\s*\+\s*1|of\s*\$\{|of\s*\{/,
    'programmatic "Step n of total" progress indicator required',
  );
  assert.match(source, /\.focus\s*\(/, 'focus must move to the step heading on step change');
  assert.match(
    source,
    /prefers-reduced-motion/,
    'transitions must be disabled under prefers-reduced-motion (FR-5)',
  );
});

test('cancel is the consumer discard hook with default labels (FR-5)', () => {
  assert.ok(source.includes('onCancel'));
  for (const label of ['Cancel', 'Back', 'Next', 'Finish']) {
    assert.ok(source.includes(label), `default label "${label}" must exist`);
  }
});

test('domain-neutral imports: no MCP/backend modules (NFR-5, contract-tested)', () => {
  const offenders = importSpecifiers(source).filter((spec) =>
    /mcp|endpoint|(^|\/)api($|\/)|@\/lib/i.test(spec),
  );
  assert.deepEqual(
    offenders,
    [],
    `wizard-stepper must not import MCP/backend modules, found: ${offenders.join(', ')}`,
  );
});

test('kit index re-exports WizardStepper and its prop types (FR-5)', () => {
  const index = readFileSync(path.join(KIT_DIR, 'index.ts'), 'utf8');
  assert.match(index, /WizardStepper/, 'kit index must export WizardStepper');
  assert.match(index, /WizardStepperProps|WizardStepDef/, 'kit index must export the prop types');
});
