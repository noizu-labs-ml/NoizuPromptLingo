import type { Backend, DcClientOptions, DcMode } from './types.js';
import { NativeBackend } from './native.js';
import { CliBackend } from './cli.js';
import { findCurrentStore } from './store.js';
import { readVersion, watchVersion } from './version.js';

export class DcClient {
  private backendPromise: Promise<Backend>;
  private storePathPromise: Promise<string>;
  private mode: DcMode;
  private dcBinary: string;

  constructor(options?: DcClientOptions) {
    this.mode = options?.mode ?? 'native';
    this.dcBinary = options?.dcBinary ?? 'dc';

    if (options?.stateDir) {
      this.storePathPromise = Promise.resolve(options.stateDir);
    } else {
      this.storePathPromise = findCurrentStore(options?.directory);
    }

    this.backendPromise = this.storePathPromise.then((sp) => {
      if (this.mode === 'cli') {
        return new CliBackend(sp, this.dcBinary);
      }
      return new NativeBackend(sp);
    });
  }

  async get(config: string, path?: string): Promise<unknown> {
    const backend = await this.backendPromise;
    const result = await backend.get(config, path);
    return result ?? null;
  }

  async getOrThrow(config: string, path?: string): Promise<unknown> {
    const result = await this.get(config, path);
    if (result === null || result === undefined) {
      const target = path ? `${config}.${path}` : config;
      throw new Error(`Value not found: ${target}`);
    }
    return result;
  }

  async getString(config: string, path: string): Promise<string | null> {
    const result = await this.get(config, path);
    if (result === null || result === undefined) return null;
    return String(result);
  }

  async getInt(config: string, path: string): Promise<number | null> {
    const result = await this.get(config, path);
    if (result === null || result === undefined) return null;
    const num = Number(result);
    return Number.isNaN(num) ? null : Math.trunc(num);
  }

  async getBool(config: string, path: string): Promise<boolean | null> {
    const result = await this.get(config, path);
    if (result === null || result === undefined) return null;
    if (typeof result === 'boolean') return result;
    if (result === 'true') return true;
    if (result === 'false') return false;
    return null;
  }

  async listConfigs(): Promise<string[]> {
    const backend = await this.backendPromise;
    return backend.listConfigs();
  }

  async version(): Promise<number> {
    const sp = await this.storePathPromise;
    return readVersion(sp);
  }

  async hasChanged(since: number): Promise<boolean> {
    const current = await this.version();
    return current !== since;
  }

  watch(callback: (version: number) => void, intervalMs?: number): { dispose(): void } {
    let watcher: { dispose(): void } | null = null;

    this.storePathPromise.then((sp) => {
      watcher = watchVersion(sp, callback, intervalMs);
    });

    return {
      dispose() {
        watcher?.dispose();
      },
    };
  }

  async set(config: string, key: string, value: string, options?: { layer?: string; noBump?: boolean }): Promise<void> {
    const backend = await this.backendPromise;
    await backend.set(config, key, value, options?.layer, options?.noBump);
  }

  async unset(config: string, keys: string[], options?: { layer?: string; noBump?: boolean }): Promise<void> {
    const backend = await this.backendPromise;
    await backend.unset(config, keys, options?.layer, options?.noBump);
  }

  async bump(): Promise<number> {
    const backend = await this.backendPromise;
    return backend.bump();
  }
}
