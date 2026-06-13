import { describe, it, expect } from 'vitest';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { parse as parseYaml } from 'yaml';
import { NativeBackend } from '../src/native.js';
import { readVersion } from '../src/version.js';
import { pathToHash } from '../src/store.js';

const FIXTURES = resolve(import.meta.dirname, '../../contract-tests/fixtures');
const EXPECTATIONS = resolve(import.meta.dirname, '../../contract-tests/expectations.yaml');

interface TestCase {
  name: string;
  store?: string;
  config?: string;
  path?: string | null;
  expected?: unknown;
  expected_keys?: string[];
  expected_version?: number;
  expected_configs?: string[];
  expected_hash?: string;
  input_path?: string;
  type?: string;
}

async function loadExpectations(): Promise<TestCase[]> {
  const content = await readFile(EXPECTATIONS, 'utf-8');
  const parsed = parseYaml(content);
  return parsed.tests;
}

describe('contract tests', async () => {
  const tests = await loadExpectations();

  for (const tc of tests) {
    it(tc.name, async () => {
      if (tc.input_path !== undefined && tc.expected_hash !== undefined) {
        expect(pathToHash(tc.input_path)).toBe(tc.expected_hash);
        return;
      }

      if (tc.expected_version !== undefined) {
        const version = await readVersion(resolve(FIXTURES, tc.store!));
        expect(version).toBe(tc.expected_version);
        return;
      }

      if (tc.expected_configs !== undefined) {
        const backend = new NativeBackend(resolve(FIXTURES, tc.store!));
        const configs = await backend.listConfigs();
        expect(configs).toEqual(tc.expected_configs);
        return;
      }

      const backend = new NativeBackend(resolve(FIXTURES, tc.store!));
      const path = tc.path === null ? undefined : tc.path;
      const result = await backend.get(tc.config!, path);

      switch (tc.type) {
        case 'string':
          expect(result).toBe(tc.expected);
          break;
        case 'integer':
          expect(result).toBe(tc.expected);
          break;
        case 'boolean':
          expect(result).toBe(tc.expected);
          break;
        case 'null':
          expect(result).toBeNull();
          break;
        case 'string_array':
          expect(result).toEqual(tc.expected);
          break;
        case 'integer_array':
          expect(result).toEqual(tc.expected);
          break;
        case 'map':
          expect(result).toBeTypeOf('object');
          expect(result).not.toBeNull();
          for (const key of tc.expected_keys!) {
            expect(result).toHaveProperty(key);
          }
          break;
        default:
          throw new Error(`Unknown test type: ${tc.type}`);
      }
    });
  }
});
