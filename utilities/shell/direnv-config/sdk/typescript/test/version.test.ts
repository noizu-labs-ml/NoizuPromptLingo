import { describe, it, expect, beforeEach } from 'vitest';
import { mkdtemp } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { bumpVersion, readVersion } from '../src/version.js';

describe('bumpVersion', () => {
  let store: string;

  beforeEach(async () => {
    store = await mkdtemp(join(tmpdir(), 'dc-version-'));
  });

  it('bump from zero returns 1', async () => {
    const version = await bumpVersion(store);
    expect(version).toBe(1);
  });

  it('bump increments existing version', async () => {
    await bumpVersion(store); // -> 1
    const version = await bumpVersion(store);
    expect(version).toBe(2);
  });

  it('sequential bumps increment correctly', async () => {
    const v1 = await bumpVersion(store);
    const v2 = await bumpVersion(store);
    const v3 = await bumpVersion(store);
    expect(v1).toBe(1);
    expect(v2).toBe(2);
    expect(v3).toBe(3);
  });

  it('readVersion returns 0 when no .version file exists', async () => {
    const version = await readVersion(store);
    expect(version).toBe(0);
  });
});
