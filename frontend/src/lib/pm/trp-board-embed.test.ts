import assert from 'node:assert/strict';
import test from 'node:test';
import {
  TRP_PROXY_BASE,
  trpEmbedConfig,
  trpBundleUrl,
  resolveProxySegments,
  upstreamUrl,
  proxyAccessAllowed,
} from './trp-board-embed.ts';

test('trpEmbedConfig returns null until host + key are provisioned', () => {
  assert.equal(trpEmbedConfig({}), null);
  assert.equal(trpEmbedConfig({ TRP_COMPONENT_BASE_URL: 'https://app.therobotplans.com' }), null);
  assert.equal(trpEmbedConfig({ TRP_EMBED_API_KEY: 'shared-key' }), null);
});

test('trpEmbedConfig reads server env with defaults and trims the base url', () => {
  const config = trpEmbedConfig({
    TRP_COMPONENT_BASE_URL: 'https://app.therobotplans.com///',
    TRP_EMBED_API_KEY: ' shared-key ',
  });
  assert.deepEqual(config, {
    baseUrl: 'https://app.therobotplans.com',
    componentName: 'trp-item-timeline',
    apiKey: 'shared-key',
    orgIdOverride: null,
  });
});

test('trpEmbedConfig honors component-name + org overrides', () => {
  const config = trpEmbedConfig({
    TRP_COMPONENT_BASE_URL: 'https://trp.example.test',
    TRP_EMBED_API_KEY: 'k',
    TRP_COMPONENT_NAME: 'trp-item-timeline-pro',
    TRP_EMBED_ORG_ID: 'org-fixed',
  });
  assert.equal(config?.componentName, 'trp-item-timeline-pro');
  assert.equal(config?.orgIdOverride, 'org-fixed');
});

test('the bundle maps onto the TRP public static asset path', () => {
  const config = trpEmbedConfig({ TRP_COMPONENT_BASE_URL: 'https://trp.example.test', TRP_EMBED_API_KEY: 'k' })!;
  assert.equal(
    trpBundleUrl(config),
    'https://trp.example.test/components/trp-item-timeline/trp-item-timeline.js',
  );
});

test('resolveProxySegments routes the bundle and the org data plane only', () => {
  assert.deepEqual(resolveProxySegments(['component-bundle']), { kind: 'bundle' });
  assert.deepEqual(resolveProxySegments(['api', 'v1', 'organizations', 'org-1', 'items', 'TRP-1', 'activity']), {
    kind: 'data',
    path: '/api/v1/organizations/org-1/items/TRP-1/activity',
  });
});

test('resolveProxySegments rejects traversal, empty segments and unknown prefixes', () => {
  assert.equal(resolveProxySegments(['..', 'etc']), null);
  assert.equal(resolveProxySegments(['component-bundle', '..', 'env']), null);
  assert.equal(resolveProxySegments(['']), null);
  assert.equal(resolveProxySegments(['api', 'v1', 'admin', 'keys']), null);
  assert.equal(resolveProxySegments(['anything']), null);
  assert.equal(resolveProxySegments([]), null);
});

test('upstreamUrl resolves bundle + data targets, null for rejected segments', () => {
  const config = trpEmbedConfig({ TRP_COMPONENT_BASE_URL: 'https://trp.example.test', TRP_EMBED_API_KEY: 'k' })!;
  assert.equal(
    upstreamUrl(config, resolveProxySegments(['component-bundle'])),
    'https://trp.example.test/components/trp-item-timeline/trp-item-timeline.js',
  );
  assert.equal(
    upstreamUrl(config, resolveProxySegments(['api', 'v1', 'organizations', 'org-1', 'items', 'i-1'])),
    'https://trp.example.test/api/v1/organizations/org-1/items/i-1',
  );
  assert.equal(upstreamUrl(config, resolveProxySegments(['secrets'])), null);
  assert.equal(upstreamUrl(config, null), null);
});

test('the proxy gate mirrors the middleware session-cookie requirement', () => {
  assert.equal(proxyAccessAllowed(false), false);
  assert.equal(proxyAccessAllowed(true), true);
  assert.equal(TRP_PROXY_BASE, '/api/trp-board');
});
