/**
 * Alacarte WP5 contract tests: the `?t=` toolset param encoder and the TS
 * compile mirror (`computeEffectiveTools`). The precedence golden vectors
 * mirror the backend `UrlToolsetParam` ExUnit vectors — white-list beats
 * black-list; `{"default":"core"}` preset expansion; tools-map `visible`
 * re-enable without a constraining white-list. Keep both sides in lockstep.
 *
 * Pure logic only — node test runner, no DOM, no network.
 */
import assert from 'node:assert/strict';
import test from 'node:test';

import {
  compactToolsetSpec,
  computeEffectiveTools,
  encodeToolsetParam,
  parseMediaRef,
  toolSelectionUrl,
  universeFromCatalog,
  type ToolsetParamSpec,
  type ToolsetUniverseEntry,
} from './mcp-setup';

const UNIVERSE: ToolsetUniverseEntry[] = [
  { group: 'sessions', name: 'Session_Create' },
  { group: 'sessions', name: 'Session_Overview' },
  { group: 'orgs', name: 'Organization_Get' },
];

const NO_CONFIG = { groups: {} };

// ── encoder ──────────────────────────────────────────────────────────────────

function decodeToken(token: string): unknown {
  const padded = token.replace(/-/g, '+').replace(/_/g, '/') + '='.repeat((4 - (token.length % 4)) % 4);
  return JSON.parse(decodeURIComponent(escape(atob(padded))));
}

test('encodeToolsetParam: base64url without padding, JSON round-trips', () => {
  const spec: ToolsetParamSpec = {
    "white-list": ['Session_Create', { name: 'Session_Overview', visible: false }],
    "black-list": ['Organization_Get'],
    tools: { Org_Search: { visible: true } },
    default: 'core',
  };
  const token = encodeToolsetParam(spec);
  assert.ok(!token.includes('+'), 'no + (charset guard)');
  assert.ok(!token.includes('/'), 'no / (charset guard)');
  assert.ok(!token.includes('='), 'no padding');
  assert.match(token, /^[A-Za-z0-9_-]+$/);
  assert.deepEqual(decodeToken(token), {
    "white-list": ['Session_Create', { name: 'Session_Overview', visible: false }],
    "black-list": ['Organization_Get'],
    tools: { Org_Search: { visible: true } },
    default: 'core',
  });
});

test('encodeToolsetParam: unicode emoji in the JSON survives the round-trip', () => {
  const spec: ToolsetParamSpec = { "white-list": ['Résumé_⚡Generate'] };
  const token = encodeToolsetParam(spec);
  assert.deepEqual(decodeToken(token), { "white-list": ['Résumé_⚡Generate'] });
});

test('compactToolsetSpec drops empty keys so short specs stay short', () => {
  assert.deepEqual(compactToolsetSpec({}), {});
  assert.deepEqual(compactToolsetSpec({ "white-list": [], "black-list": [], tools: {} }), {});
  assert.deepEqual(compactToolsetSpec({ default: false, "white-list": ['A'] }), { "white-list": ['A'] });
  assert.deepEqual(compactToolsetSpec({ tools: { A: {} } }), {});
});

test('snake_case keys are accepted and canonicalized to kebab-case', () => {
  assert.deepEqual(
    compactToolsetSpec({ white_list: ['Session_Create'], black_list: ['Organization_Get'] }),
    { "white-list": ['Session_Create'], "black-list": ['Organization_Get'] },
  );
  const snake = computeEffectiveTools(
    NO_CONFIG,
    UNIVERSE,
    { white_list: ['Session_Create'], black_list: ['Session_Create'] },
  );
  const kebab = computeEffectiveTools(
    NO_CONFIG,
    UNIVERSE,
    { "white-list": ['Session_Create'], "black-list": ['Session_Create'] },
  );
  assert.deepEqual(snake, kebab);
  assert.equal(
    encodeToolsetParam({ white_list: ['Session_Create'] }),
    encodeToolsetParam({ "white-list": ['Session_Create'] }),
    'encoder always emits the canonical kebab-case token',
  );
});

// ── precedence golden vectors (mirror the backend ExUnit vectors) ────────────

test('golden: white-list beats black-list', () => {
  const result = computeEffectiveTools(
    NO_CONFIG,
    UNIVERSE,
    { "white-list": ['Session_Create'], "black-list": ['Session_Create'] },
  );
  assert.equal(result.Session_Create.enabled, true);
  assert.equal(result.Session_Overview.enabled, false, 'absent-from-set → disabled');
  assert.equal(result.Organization_Get.enabled, false);
});

test('golden: {"default":"core"} expands from the preset registry', () => {
  const result = computeEffectiveTools(
    NO_CONFIG,
    UNIVERSE,
    { default: 'core' },
    { presets: { core: ['Session_Create', 'Session_Overview'] } },
  );
  assert.equal(result.Session_Create.enabled, true);
  assert.equal(result.Session_Overview.enabled, true);
  assert.equal(result.Organization_Get.enabled, false, 'outside the preset set → disabled');
});

test('golden: tools-map visible re-enables stored-disabled without a white-list', () => {
  const config = { groups: { sessions: { tools: { Session_Create: { disabled: true } } } } };
  const result = computeEffectiveTools(
    config,
    UNIVERSE,
    { tools: { Session_Create: { visible: true } } },
  );
  assert.equal(result.Session_Create.enabled, true);
  assert.equal(result.Session_Create.visible, true);
  assert.equal(result.Session_Overview.enabled, true, 'unlisted tools keep the stored baseline');
});

test('white-list defines the enable set; absent-from-set is disabled', () => {
  const result = computeEffectiveTools(NO_CONFIG, UNIVERSE, { "white-list": ['Session_Create'] });
  assert.equal(result.Session_Create.enabled, true);
  assert.equal(result.Session_Overview.enabled, false);
  assert.equal(result.Organization_Get.enabled, false);
});

test('white-list re-enables a tool the stored config disabled', () => {
  const config = { groups: { sessions: { tools: { Session_Create: { disabled: true } } } } };
  const result = computeEffectiveTools(config, UNIVERSE, { "white-list": ['Session_Create'] });
  assert.equal(result.Session_Create.enabled, true, 'param layer wins per key');
});

test('black-list without a white-list disables listed tools', () => {
  const result = computeEffectiveTools(NO_CONFIG, UNIVERSE, { "black-list": ['Session_Overview'] });
  assert.equal(result.Session_Overview.enabled, false);
  assert.equal(result.Session_Create.enabled, true);
});

test('black-list beats default expansion but not an explicit white-list entry', () => {
  const presets = { core: ['Session_Overview'] };
  const blacked = computeEffectiveTools(
    NO_CONFIG,
    UNIVERSE,
    { default: 'core', "black-list": ['Session_Overview'] },
    { presets },
  );
  assert.equal(blacked.Session_Overview.enabled, false);

  const whitelisted = computeEffectiveTools(
    NO_CONFIG,
    UNIVERSE,
    { default: 'core', "black-list": ['Session_Overview'], "white-list": ['Session_Overview'] },
    { presets },
  );
  assert.equal(whitelisted.Session_Overview.enabled, true);
});

test('white-list entry visible flags hide a tool without disabling it', () => {
  const result = computeEffectiveTools(
    NO_CONFIG,
    UNIVERSE,
    { "white-list": [{ name: 'Session_Create', visible: false }] },
  );
  assert.equal(result.Session_Create.enabled, true);
  assert.equal(result.Session_Create.visible, false);
});

test('tools map is dead when a white-list constrains', () => {
  const result = computeEffectiveTools(
    NO_CONFIG,
    UNIVERSE,
    { "white-list": ['Session_Create'], tools: { Session_Overview: { visible: true } } },
  );
  assert.equal(result.Session_Overview.enabled, false, 'no re-enable under a white-list');
  assert.equal(result.Session_Overview.visible, true);
});

test('default:true resolves the endpoint stored-config enabled set', () => {
  const config = { groups: { sessions: { tools: { Session_Create: { disabled: true } } } } };
  const result = computeEffectiveTools(config, UNIVERSE, { default: true });
  assert.equal(result.Session_Create.enabled, false);
  assert.equal(result.Session_Overview.enabled, true);
  assert.equal(result.Organization_Get.enabled, true);
});

test('unknown names are dead entries — never added to the result', () => {
  const result = computeEffectiveTools(
    NO_CONFIG,
    UNIVERSE,
    { "white-list": ['Nonexistent_Tool'], "black-list": ['Also_Missing'] },
  );
  assert.equal(result.Nonexistent_Tool, undefined);
  assert.equal(result.Also_Missing, undefined);
  for (const entry of UNIVERSE) {
    assert.equal(result[entry.name].enabled, false, 'white-list of a dead name still disables the set');
  }
});

test('absent param returns the stored-config baseline (no-param behavior)', () => {
  const config = {
    groups: { sessions: { tools: { Session_Create: { disabled: true, hidden: true } } } },
  };
  const result = computeEffectiveTools(config, UNIVERSE, null);
  assert.deepEqual(result.Session_Create, { enabled: false, visible: false });
  assert.deepEqual(result.Session_Overview, { enabled: true, visible: true });
  assert.deepEqual(result.Organization_Get, { enabled: true, visible: true });
});

test('catalog dotted names match canonical underscore config/param keys', () => {
  const universe: ToolsetUniverseEntry[] = [{ group: 'sessions', name: 'Session.Create' }];
  const config = { groups: { sessions: { tools: { Session_Create: { disabled: true } } } } };
  const result = computeEffectiveTools(
    config,
    universe,
    { tools: { Session_Create: { visible: true } } },
  );
  assert.deepEqual(result.Session_Create, { enabled: true, visible: true });
});

// ── universe bounding ────────────────────────────────────────────────────────

test('universeFromCatalog bounds the param to included groups', () => {
  const catalog = [
    {
      id: 'sessions',
      label: 'Sessions',
      desc: '',
      tools: [{ name: 'Session_Create', category: '', description: '', parameters: [], hidden: false }],
    },
    {
      id: 'orgs',
      label: 'Organizations',
      desc: '',
      tools: [{ name: 'Organization_Get', category: '', description: '', parameters: [], hidden: true }],
    },
  ];
  assert.deepEqual(
    universeFromCatalog(catalog, { groups: { sessions: {} } }).map((entry) => entry.name),
    ['Session_Create'],
  );
  assert.deepEqual(
    universeFromCatalog(catalog, { groups: { sessions: { disabled: true } } }),
    [],
  );
});

// ── media refs / URL assembly ────────────────────────────────────────────────

test('parseMediaRef: short_id → thumb/banner variants; http(s) passes through', () => {
  assert.deepEqual(parseMediaRef(null), { thumb: null, banner: null });
  assert.deepEqual(parseMediaRef(''), { thumb: null, banner: null });
  assert.deepEqual(parseMediaRef('  '), { thumb: null, banner: null });
  assert.deepEqual(parseMediaRef('abc123'), {
    thumb: '/media/abc123?w=200&f=webp',
    banner: '/media/abc123?w=1600&fit=cover',
  });
  assert.deepEqual(parseMediaRef('/media/abc123'), {
    thumb: '/media/abc123?w=200&f=webp',
    banner: '/media/abc123?w=1600&fit=cover',
  });
  const external = 'https://cdn.example.com/logo.png';
  assert.deepEqual(parseMediaRef(external), { thumb: external, banner: external });
  assert.equal(parseMediaRef('http://insecure.example/x.gif').banner, 'http://insecure.example/x.gif');
});

test('toolSelectionUrl appends ?t= (or &t= on existing queries) with a url-safe token', () => {
  const url = toolSelectionUrl('https://tobor.locker/custom/tobor/mcp', {
    "white-list": ['Session_Create'],
  });
  assert.match(url, /^https:\/\/tobor\.locker\/custom\/tobor\/mcp\?t=[A-Za-z0-9_-]+$/);
  assert.match(toolSelectionUrl('https://tobor.locker/custom/tobor/mcp?org=1', {}), /[?&]t=[A-Za-z0-9_-]*$/);
});
