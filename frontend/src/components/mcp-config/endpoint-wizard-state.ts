/**
 * PRD-020 FR-6 — pure logic for the endpoint-creation wizard: slug
 * derivation, the wizard reducer, proposal application, and the
 * proposal -> jsonb config mapping.
 *
 * Pure only: no React, no DOM, no network. The wizard component
 * (`endpoint-wizard.tsx`) owns effects and drives this module via
 * `reduceWizard` / `applyProposal`.
 *
 * NOTE (TDD contract pin): the WizardAction union is the test-pinned action
 * vocabulary from `endpoint-wizard-state.test.ts`
 * (set_name / set_description / set_slug / set_answer / questions_received /
 * skip_to_manual / llm_unavailable / clone_prefill / cancel). The single
 * additional action `slug_status` carries the debounced slug-availability
 * check result from the wizard component — it touches only `slugStatus` and
 * none of the pinned behaviors.
 */
import type {
  ClarifyQuestion,
  McpCustomScopeConfig,
  ProposedTool,
  SlugAvailabilityResponse,
} from '@/lib/api';

export interface WizardSource {
  id?: string;
  slug?: string;
  kind: 'template' | 'own';
}

export interface WizardToolSelection {
  name: string;
  group: string;
  rationale?: string;
  enabled: boolean;
  visible: boolean;
}

export interface EndpointWizardState {
  mode: 'create' | 'clone';
  source?: WizardSource;
  name: string;
  description: string;
  slug: string;
  slugTouched: boolean;
  slugStatus: SlugAvailabilityResponse | null;
  questions: ClarifyQuestion[];
  answers: Record<string, string | string[]>;
  selections: WizardToolSelection[];
  proposalSummary: string | null;
  status: 'idle' | 'loading-questions' | 'loading-proposal' | 'fallback' | 'submitting';
  error: string | null;
}

export type WizardAction =
  | { type: 'set_name'; value: string }
  | { type: 'set_description'; value: string }
  | { type: 'set_slug'; value: string }
  | { type: 'set_answer'; questionId: string; value: string }
  | { type: 'questions_received'; questions: ClarifyQuestion[] }
  | { type: 'skip_to_manual' }
  | { type: 'llm_unavailable' }
  | {
      type: 'clone_prefill';
      source: WizardSource & { name: string; description: string };
    }
  | { type: 'cancel' }
  // Implementation-added (beyond the pinned nine): debounced availability result.
  | { type: 'slug_status'; status: SlugAvailabilityResponse | null }
  // Implementation-added: review-step Enabled/Visible toggles and manual-picker
  // merges (FR-6 step 3 / FR-7); touch only `selections`.
  | { type: 'toggle_selection'; name: string; field: 'enabled' | 'visible'; value: boolean }
  | { type: 'add_selections'; selections: WizardToolSelection[] }
  // Implementation-added: async phase marker (loading-questions /
  // loading-proposal / submitting / idle) for spinner + cancel affordances.
  | { type: 'status'; value: EndpointWizardState['status'] }
  // Implementation-added: proposal round landed — delegates to applyProposal.
  | { type: 'proposal_received'; tools: ProposedTool[]; summary: string };

const LLM_UNAVAILABLE_MESSAGE =
  'LLM-powered suggestions are unavailable. Pick tools manually — nothing you entered was lost.';

export function initialWizardState(): EndpointWizardState {
  return {
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
  };
}

/**
 * Kebab-case slug from a human name: lowercase, `[^a-z0-9]+` -> `-`, collapse,
 * trim hyphens, cap at 63 (never ending on a hyphen). Empty string when
 * nothing valid survives.
 */
export function deriveSlug(name: string): string {
  const slug = name
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');

  if (!slug) return '';
  return slug.slice(0, 63).replace(/-+$/g, '');
}

export function reduceWizard(state: EndpointWizardState, action: WizardAction): EndpointWizardState {
  switch (action.type) {
    case 'set_name':
      // Slug auto-derives from the name until the first manual slug edit;
      // afterwards the manual slug is never re-derived.
      return {
        ...state,
        name: action.value,
        slug: state.slugTouched ? state.slug : deriveSlug(action.value),
      };

    case 'set_description':
      return { ...state, description: action.value };

    case 'set_slug':
      // First manual keystroke permanently stops derivation.
      return { ...state, slug: action.value, slugTouched: true };

    case 'set_answer':
      return {
        ...state,
        answers: { ...state.answers, [action.questionId]: action.value },
      };

    case 'questions_received':
      return { ...state, questions: action.questions, status: 'idle' };

    // D2: step 2 is skippable — route to the manual picker.
    case 'skip_to_manual':
      return { ...state, status: 'fallback' };

    // D3: LLM failure path — fall back to the manual picker with every
    // earlier field preserved (name/description/answers/selections).
    case 'llm_unavailable':
      return { ...state, status: 'fallback', error: LLM_UNAVAILABLE_MESSAGE };

    case 'clone_prefill':
      return {
        ...state,
        mode: 'clone',
        source: { id: action.source.id, slug: action.source.slug, kind: action.source.kind },
        name: action.source.name,
        description: action.source.description,
        slug: action.source.slug ?? deriveSlug(action.source.name),
        slugTouched: true,
        slugStatus: null,
        error: null,
      };

    // Clean reset: deep-equal to a fresh wizard (no stale keys).
    case 'cancel':
      return initialWizardState();

    case 'slug_status':
      return { ...state, slugStatus: action.status };

    case 'toggle_selection':
      return {
        ...state,
        selections: state.selections.map((sel) =>
          sel.name === action.name ? { ...sel, [action.field]: action.value } : sel,
        ),
      };

    case 'add_selections': {
      const existing = new Set(state.selections.map((sel) => sel.name));
      const additions = action.selections.filter((sel) => !existing.has(sel.name));
      return { ...state, selections: [...state.selections, ...additions] };
    }

    case 'status':
      return { ...state, status: action.value };

    case 'proposal_received':
      return applyProposal(state, action.tools, action.summary);

    default: {
      // Exhaustiveness guard: the union above is the full vocabulary.
      const never: never = action;
      return never;
    }
  }
}

/**
 * Merge a proposal round into the wizard state: every proposed tool defaults
 * to enabled + visible; step-1 fields and answers are untouched.
 */
export function applyProposal(
  state: EndpointWizardState,
  tools: ProposedTool[],
  summary: string,
): EndpointWizardState {
  return {
    ...state,
    selections: tools.map((tool) => ({
      name: tool.name,
      group: tool.group,
      rationale: tool.rationale,
      enabled: true,
      visible: true,
    })),
    proposalSummary: summary,
  };
}

/**
 * Map selections onto the `mcp_custom_scopes.config` jsonb (inverted storage
 * semantics — the store keeps disable/hide flags): enabled+visible -> `{}`,
 * otherwise `{"disabled": true}` / `{"hidden": true}` / both, bucketed under
 * `config.groups[group].tools[name]`. Unconfigured tools default enabled +
 * visible server-side.
 */
export function proposalToConfig(selections: WizardToolSelection[]): McpCustomScopeConfig {
  const config: McpCustomScopeConfig = { groups: {} };

  for (const selection of selections) {
    const entry: { disabled?: boolean; hidden?: boolean } = {};
    if (!selection.enabled) entry.disabled = true;
    if (!selection.visible) entry.hidden = true;

    const group = config.groups[selection.group] ?? {};
    const tools = group.tools ?? {};
    tools[selection.name] = entry;
    group.tools = tools;
    config.groups[selection.group] = group;
  }

  return config;
}
