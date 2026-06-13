import { describe, it, expect } from 'vitest';
import { pathToHash } from '../src/store.js';

describe('pathToHash', () => {
  it('converts a simple absolute path', () => {
    expect(pathToHash('/Users/keith/Github/k8/projects')).toBe('Users-keith-Github-k8-projects');
  });

  it('converts root path to empty string', () => {
    expect(pathToHash('/')).toBe('');
  });

  it('converts single segment path', () => {
    expect(pathToHash('/tmp')).toBe('tmp');
  });

  it('handles relative paths', () => {
    expect(pathToHash('relative/path')).toBe('relative-path');
  });

  it('truncates long paths and appends hash', () => {
    const segments = Array.from({ length: 20 }, () => 'abcdefghij');
    const longPath = '/' + segments.join('/');
    const result = pathToHash(longPath);

    expect(result.length).toBe(209);
    expect(result[200]).toBe('-');

    const suffix = result.slice(201);
    expect(suffix.length).toBe(8);
    expect(suffix).toMatch(/^[0-9a-f]{8}$/);
  });

  it('does not truncate paths at exactly 200 characters', () => {
    const base = 'a'.repeat(199);
    const path = '/' + base;
    const result = pathToHash(path);
    expect(result.length).toBeLessThanOrEqual(200);
    expect(result).not.toContain('-');
  });
});
