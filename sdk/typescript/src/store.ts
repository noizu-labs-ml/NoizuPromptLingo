import { createHash } from 'node:crypto';
import { homedir } from 'node:os';
import { join, dirname } from 'node:path';
import { existsSync } from 'node:fs';
import { mkdir, writeFile } from 'node:fs/promises';
import { stringify as stringifyYaml } from 'yaml';

export function stateDir(): string {
  const xdg = process.env['XDG_STATE_HOME'];
  if (xdg) return join(xdg, 'direnv-config');
  return join(homedir(), '.local', 'state', 'direnv-config');
}

export function pathToHash(dir: string): string {
  const stripped = dir.startsWith('/') ? dir.slice(1) : dir;
  const name = stripped.replace(/\//g, '-');

  if (name.length <= 200) return name;

  const hash = createHash('sha256').update(dir).digest('hex');
  return `${name.slice(0, 200)}-${hash.slice(0, 8)}`;
}

export function storePath(dir: string): string {
  return join(stateDir(), pathToHash(dir));
}

export async function findCurrentStore(startDir?: string): Promise<string> {
  let dir = startDir ?? process.cwd();

  while (true) {
    const sp = storePath(dir);
    if (existsSync(sp)) return sp;

    const parent = dirname(dir);
    if (parent === dir) break;
    dir = parent;
  }

  throw new Error(
    `No store found for ${startDir ?? process.cwd()} (searched all parent directories). Run \`dc init\` first.`
  );
}

export async function ensureStore(dir: string): Promise<string> {
  const sp = storePath(dir);
  await mkdir(sp, { recursive: true });
  const metaPath = join(sp, '.meta');
  if (!existsSync(metaPath)) {
    const meta = {
      source: dir,
      created: new Date().toISOString(),
      configs: [] as string[],
    };
    await writeFile(metaPath, stringifyYaml(meta), 'utf-8');
  }
  return sp;
}

export async function ensureConfig(store: string, name: string): Promise<string> {
  const configDir = join(store, name);
  await mkdir(configDir, { recursive: true });
  return configDir;
}

export function layerPath(store: string, name: string, layer: string): string {
  return join(store, name, `${layer}.yaml`);
}

export function activePath(store: string, name: string): string {
  return join(store, name, '.active');
}
