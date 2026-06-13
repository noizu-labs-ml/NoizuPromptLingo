import { readFile, writeFile } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { join } from 'node:path';
import { parse as parseYaml, stringify as stringifyYaml } from 'yaml';
import { deepMergeMulti } from './merge.js';

export async function resolveActive(storePath: string, name: string): Promise<unknown> {
  const env = process.env['DC_ENV'] ?? 'dev';
  const layerNames = ['base', env, 'local', 'secrets'];

  const layers: unknown[] = [];
  for (const layer of layerNames) {
    const filePath = join(storePath, name, `${layer}.yaml`);
    if (existsSync(filePath)) {
      const content = await readFile(filePath, 'utf-8');
      const parsed = parseYaml(content);
      if (parsed !== null && parsed !== undefined) {
        layers.push(parsed);
      }
    }
  }

  const merged = deepMergeMulti(layers);
  const activePath = join(storePath, name, '.active');
  await writeFile(activePath, stringifyYaml(merged), 'utf-8');
  return merged;
}
