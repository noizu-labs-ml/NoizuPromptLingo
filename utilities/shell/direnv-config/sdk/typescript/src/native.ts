import { readFile, writeFile } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { join } from 'node:path';
import { parse as parseYaml, stringify as stringifyYaml } from 'yaml';
import type { Backend } from './types.js';
import { getPath, setPath, deletePath } from './path.js';
import { layerPath } from './store.js';
import { resolveActive } from './resolve.js';
import { bumpVersion } from './version.js';

export class NativeBackend implements Backend {
  constructor(private storePath: string) {}

  async get(config: string, path?: string): Promise<unknown> {
    const activePath = join(this.storePath, config, '.active');
    const content = await readFile(activePath, 'utf-8');
    const root = parseYaml(content);

    if (!path) return root;
    return getPath(root, path);
  }

  async listConfigs(): Promise<string[]> {
    const metaPath = join(this.storePath, '.meta');
    const content = await readFile(metaPath, 'utf-8');
    const meta = parseYaml(content);
    return meta?.configs ?? [];
  }

  async set(config: string, key: string, value: string, layer = 'local', noBump = false): Promise<void> {
    const filePath = layerPath(this.storePath, config, layer);
    let doc: unknown = {};
    if (existsSync(filePath)) {
      const content = await readFile(filePath, 'utf-8');
      doc = parseYaml(content) ?? {};
    }

    let parsedValue: unknown;
    try {
      parsedValue = parseYaml(value);
      if (parsedValue === undefined) parsedValue = value;
    } catch {
      parsedValue = value;
    }

    doc = setPath(doc, key, parsedValue);
    await writeFile(filePath, stringifyYaml(doc), 'utf-8');
    await resolveActive(this.storePath, config);
    if (!noBump) {
      await bumpVersion(this.storePath);
    }
  }

  async unset(config: string, keys: string[], layer = 'local', noBump = false): Promise<void> {
    const filePath = layerPath(this.storePath, config, layer);
    if (!existsSync(filePath)) return;

    const content = await readFile(filePath, 'utf-8');
    const doc = parseYaml(content);
    if (doc === null || doc === undefined) return;

    for (const key of keys) {
      deletePath(doc, key);
    }

    await writeFile(filePath, stringifyYaml(doc), 'utf-8');
    await resolveActive(this.storePath, config);
    if (!noBump) {
      await bumpVersion(this.storePath);
    }
  }

  async bump(): Promise<number> {
    return bumpVersion(this.storePath);
  }
}
