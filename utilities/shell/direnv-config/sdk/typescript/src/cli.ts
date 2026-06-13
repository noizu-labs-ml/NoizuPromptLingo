import { execFile } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { parse as parseYaml } from 'yaml';
import type { Backend } from './types.js';

function exec(binary: string, args: string[]): Promise<{ stdout: string; stderr: string }> {
  return new Promise((resolve, reject) => {
    execFile(binary, args, (error, stdout, stderr) => {
      if (error) {
        reject(new Error(`dc command failed: ${stderr || error.message}`));
        return;
      }
      resolve({ stdout, stderr });
    });
  });
}

export class CliBackend implements Backend {
  constructor(
    private storePath: string,
    private dcBinary: string
  ) {}

  async get(config: string, path?: string): Promise<unknown> {
    const args = ['get', config];
    if (path) args.push(path);
    args.push('--raw');
    const { stdout } = await exec(this.dcBinary, args);
    return parseYaml(stdout);
  }

  async listConfigs(): Promise<string[]> {
    const metaPath = join(this.storePath, '.meta');
    const content = await readFile(metaPath, 'utf-8');
    const meta = parseYaml(content);
    return meta?.configs ?? [];
  }

  async set(config: string, key: string, value: string, layer?: string, noBump?: boolean): Promise<void> {
    const args = ['set', config, key, value];
    if (layer) args.push('--layer', layer);
    if (noBump) args.push('--no-bump');
    await exec(this.dcBinary, args);
  }

  async unset(config: string, keys: string[], layer?: string, noBump?: boolean): Promise<void> {
    const args = ['unset', config, ...keys];
    if (layer) args.push('--layer', layer);
    if (noBump) args.push('--no-bump');
    await exec(this.dcBinary, args);
  }

  async bump(): Promise<number> {
    const { stderr } = await exec(this.dcBinary, ['bump']);
    const match = stderr.match(/(\d+)/);
    return match ? parseInt(match[1], 10) : 0;
  }
}
