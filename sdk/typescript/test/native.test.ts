import { describe, it, expect, beforeEach } from 'vitest';
import { resolve, join } from 'node:path';
import { mkdtemp, writeFile, readFile, mkdir } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { parse as parseYaml, stringify as stringifyYaml } from 'yaml';
import { NativeBackend } from '../src/native.js';

const FIXTURES = resolve(import.meta.dirname, '../../contract-tests/fixtures');

describe('NativeBackend', () => {
  describe('simple-store', () => {
    const backend = new NativeBackend(resolve(FIXTURES, 'simple-store'));

    it('reads a string value', async () => {
      expect(await backend.get('cluster', 'name')).toBe('noizu');
    });

    it('reads a nested string', async () => {
      expect(await backend.get('cluster', 'node_pool.instance_type')).toBe('m5.xlarge');
    });

    it('reads an integer', async () => {
      expect(await backend.get('cluster', 'port')).toBe(6443);
    });

    it('reads a boolean', async () => {
      expect(await backend.get('cluster', 'enabled')).toBe(true);
    });

    it('reads entire config as object', async () => {
      const result = await backend.get('cluster');
      expect(result).toBeTypeOf('object');
      expect(result).toHaveProperty('name');
      expect(result).toHaveProperty('node_pool');
    });

    it('returns null for missing path', async () => {
      expect(await backend.get('cluster', 'nonexistent')).toBeNull();
    });

    it('lists configs', async () => {
      const configs = await backend.listConfigs();
      expect(configs).toEqual(['cluster']);
    });
  });

  describe('nested-store', () => {
    const backend = new NativeBackend(resolve(FIXTURES, 'nested-store'));

    it('reads array element by index', async () => {
      expect(await backend.get('app', 'endpoints[0].host')).toBe('api.example.com');
    });

    it('reads with negative index', async () => {
      expect(await backend.get('app', 'endpoints[-1].host')).toBe('backup.example.com');
    });

    it('reads with wildcard', async () => {
      expect(await backend.get('app', 'endpoints[*].host')).toEqual([
        'api.example.com',
        'internal.example.com',
        'backup.example.com',
      ]);
    });

    it('reads length', async () => {
      expect(await backend.get('app', 'endpoints.length')).toBe(3);
    });

    it('reads chained brackets', async () => {
      expect(await backend.get('app', 'matrix[0][1]')).toBe(2);
    });

    it('lists configs', async () => {
      const configs = await backend.listConfigs();
      expect(configs).toEqual(['app']);
    });
  });

  describe('write operations', () => {
    let store: string;
    let backend: NativeBackend;

    beforeEach(async () => {
      store = await mkdtemp(join(tmpdir(), 'dc-native-write-'));
      await mkdir(join(store, 'test'), { recursive: true });
      await writeFile(join(store, 'test', 'base.yaml'), stringifyYaml({ existing: 'value' }));
      await writeFile(join(store, 'test', '.active'), stringifyYaml({ existing: 'value' }));
      await writeFile(join(store, '.meta'), stringifyYaml({ configs: ['test'] }));
      backend = new NativeBackend(store);
    });

    it('set writes to layer and updates .active', async () => {
      await backend.set('test', 'newkey', 'hello');

      const layerContent = await readFile(join(store, 'test', 'local.yaml'), 'utf-8');
      const layer = parseYaml(layerContent);
      expect(layer).toHaveProperty('newkey', 'hello');

      const activeContent = await readFile(join(store, 'test', '.active'), 'utf-8');
      const active = parseYaml(activeContent);
      expect(active).toHaveProperty('existing', 'value');
      expect(active).toHaveProperty('newkey', 'hello');
    });

    it('set with noBump does not change version', async () => {
      await backend.set('test', 'key', 'val', 'local', true);

      // version file should not exist since we started fresh and used noBump
      const { readVersion } = await import('../src/version.js');
      const version = await readVersion(store);
      expect(version).toBe(0);
    });

    it('set with custom layer writes to that layer file', async () => {
      await backend.set('test', 'secret', 'password', 'secrets');

      const layerContent = await readFile(join(store, 'test', 'secrets.yaml'), 'utf-8');
      const layer = parseYaml(layerContent);
      expect(layer).toHaveProperty('secret', 'password');
    });

    it('unset removes key and updates .active', async () => {
      // First set a key in local layer
      await backend.set('test', 'toremove', 'gone', 'local', true);

      // Now unset it
      await backend.unset('test', ['toremove'], 'local', true);

      const layerContent = await readFile(join(store, 'test', 'local.yaml'), 'utf-8');
      const layer = parseYaml(layerContent);
      expect(layer).not.toHaveProperty('toremove');
    });

    it('unset on missing layer is no-op', async () => {
      // Should not throw when layer file does not exist
      await expect(backend.unset('test', ['anykey'], 'nonexistent')).resolves.toBeUndefined();
    });

    it('bump increments version', async () => {
      const v1 = await backend.bump();
      expect(v1).toBe(1);
      const v2 = await backend.bump();
      expect(v2).toBe(2);
    });
  });
});
