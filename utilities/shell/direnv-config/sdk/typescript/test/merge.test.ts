import { describe, it, expect } from 'vitest';
import { deepMerge, deepMergeMulti } from '../src/merge.js';

describe('deepMerge', () => {
  it('overlay scalar replaces base scalar', () => {
    expect(deepMerge('old', 'new')).toBe('new');
    expect(deepMerge(1, 2)).toBe(2);
  });

  it('overlay adds new keys to base map', () => {
    const result = deepMerge({ a: 1 }, { b: 2 });
    expect(result).toEqual({ a: 1, b: 2 });
  });

  it('maps merge recursively', () => {
    const base = { db: { host: 'localhost', port: 5432 } };
    const overlay = { db: { port: 3306, name: 'mydb' } };
    const result = deepMerge(base, overlay);
    expect(result).toEqual({ db: { host: 'localhost', port: 3306, name: 'mydb' } });
  });

  it('array from overlay replaces base array entirely', () => {
    const result = deepMerge({ items: [1, 2, 3] }, { items: [4, 5] });
    expect(result).toEqual({ items: [4, 5] });
  });

  it('type mismatch: overlay wins', () => {
    expect(deepMerge({ a: 'string' }, { a: 42 })).toEqual({ a: 42 });
    expect(deepMerge({ a: [1] }, { a: 'scalar' })).toEqual({ a: 'scalar' });
    expect(deepMerge('scalar', { a: 1 })).toEqual({ a: 1 });
  });

  it('tombstone (_dc_pruned: true) strips subtree', () => {
    const base = { keep: 1, remove: { nested: 'data' } };
    const overlay = { remove: { _dc_pruned: true } };
    const result = deepMerge(base, overlay);
    expect(result).toEqual({ keep: 1 });
  });

  it('nested tombstone strips only that branch', () => {
    const base = { a: { b: { c: 1 }, d: 2 } };
    const overlay = { a: { b: { _dc_pruned: true } } };
    const result = deepMerge(base, overlay);
    expect(result).toEqual({ a: { d: 2 } });
  });
});

describe('deepMergeMulti', () => {
  it('with empty array returns null', () => {
    expect(deepMergeMulti([])).toBeNull();
  });

  it('with single element returns it (stripped)', () => {
    const result = deepMergeMulti([{ a: 1, b: { _dc_pruned: true } }]);
    expect(result).toEqual({ a: 1 });
  });

  it('folds left-to-right correctly', () => {
    const layers = [
      { a: 1, b: 'base' },
      { b: 'middle', c: 3 },
      { c: 'top', d: 4 },
    ];
    const result = deepMergeMulti(layers);
    expect(result).toEqual({ a: 1, b: 'middle', c: 'top', d: 4 });
  });
});
