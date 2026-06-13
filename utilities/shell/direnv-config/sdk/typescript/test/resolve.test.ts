import { describe, it, expect, beforeEach } from 'vitest';
import { mkdtemp, writeFile, readFile, mkdir } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { parse as parseYaml, stringify as stringifyYaml } from 'yaml';
import { resolveActive } from '../src/resolve.js';

describe('resolveActive', () => {
  let store: string;

  beforeEach(async () => {
    store = await mkdtemp(join(tmpdir(), 'dc-resolve-'));
    await mkdir(join(store, 'myconfig'), { recursive: true });
  });

  it('merges base + local layers', async () => {
    await writeFile(join(store, 'myconfig', 'base.yaml'), stringifyYaml({ a: 1, b: 2 }));
    await writeFile(join(store, 'myconfig', 'local.yaml'), stringifyYaml({ b: 20, c: 3 }));

    const result = await resolveActive(store, 'myconfig');
    expect(result).toEqual({ a: 1, b: 20, c: 3 });
  });

  it('respects DC_ENV layer', async () => {
    const origEnv = process.env['DC_ENV'];
    process.env['DC_ENV'] = 'staging';
    try {
      await writeFile(join(store, 'myconfig', 'base.yaml'), stringifyYaml({ env: 'base', port: 3000 }));
      await writeFile(join(store, 'myconfig', 'staging.yaml'), stringifyYaml({ env: 'staging' }));

      const result = await resolveActive(store, 'myconfig');
      expect(result).toEqual({ env: 'staging', port: 3000 });
    } finally {
      if (origEnv === undefined) {
        delete process.env['DC_ENV'];
      } else {
        process.env['DC_ENV'] = origEnv;
      }
    }
  });

  it('skips missing layers', async () => {
    await writeFile(join(store, 'myconfig', 'base.yaml'), stringifyYaml({ only: 'base' }));
    // no local.yaml, no dev.yaml, no secrets.yaml

    const result = await resolveActive(store, 'myconfig');
    expect(result).toEqual({ only: 'base' });
  });

  it('writes .active file', async () => {
    await writeFile(join(store, 'myconfig', 'base.yaml'), stringifyYaml({ x: 1 }));

    await resolveActive(store, 'myconfig');

    const activeContent = await readFile(join(store, 'myconfig', '.active'), 'utf-8');
    const parsed = parseYaml(activeContent);
    expect(parsed).toEqual({ x: 1 });
  });

  it('returns the merged value', async () => {
    await writeFile(join(store, 'myconfig', 'base.yaml'), stringifyYaml({ k: 'v' }));

    const result = await resolveActive(store, 'myconfig');
    expect(result).toEqual({ k: 'v' });
  });
});
