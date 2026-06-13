import { describe, it, expect } from 'vitest';
import { parsePath, getPath, setPath, deletePath } from '../src/path.js';

describe('parsePath', () => {
  it('parses a simple key', () => {
    expect(parsePath('name')).toEqual([{ type: 'key', value: 'name' }]);
  });

  it('parses dotted keys', () => {
    expect(parsePath('a.b.c')).toEqual([
      { type: 'key', value: 'a' },
      { type: 'key', value: 'b' },
      { type: 'key', value: 'c' },
    ]);
  });

  it('parses a positive index', () => {
    expect(parsePath('items[0]')).toEqual([
      { type: 'key', value: 'items' },
      { type: 'index', value: 0 },
    ]);
  });

  it('parses a negative index', () => {
    expect(parsePath('items[-1]')).toEqual([
      { type: 'key', value: 'items' },
      { type: 'index', value: -1 },
    ]);
  });

  it('parses a wildcard', () => {
    expect(parsePath('endpoints[*].host')).toEqual([
      { type: 'key', value: 'endpoints' },
      { type: 'wildcard' },
      { type: 'key', value: 'host' },
    ]);
  });

  it('parses length as terminal', () => {
    expect(parsePath('items.length')).toEqual([
      { type: 'key', value: 'items' },
      { type: 'length' },
    ]);
  });

  it('treats length as key when it is the first segment', () => {
    expect(parsePath('length')).toEqual([{ type: 'key', value: 'length' }]);
  });

  it('parses chained brackets', () => {
    expect(parsePath('matrix[0][1]')).toEqual([
      { type: 'key', value: 'matrix' },
      { type: 'index', value: 0 },
      { type: 'index', value: 1 },
    ]);
  });

  it('parses mixed path', () => {
    expect(parsePath('folder[5].person.mobile')).toEqual([
      { type: 'key', value: 'folder' },
      { type: 'index', value: 5 },
      { type: 'key', value: 'person' },
      { type: 'key', value: 'mobile' },
    ]);
  });

  it('returns empty array for empty string', () => {
    expect(parsePath('')).toEqual([]);
  });
});

describe('getPath', () => {
  it('resolves a simple key', () => {
    expect(getPath({ name: 'alice' }, 'name')).toBe('alice');
  });

  it('resolves nested keys', () => {
    expect(getPath({ db: { host: 'localhost', port: 5432 } }, 'db.host')).toBe('localhost');
    expect(getPath({ db: { host: 'localhost', port: 5432 } }, 'db.port')).toBe(5432);
  });

  it('returns null for missing key', () => {
    expect(getPath({ a: 1 }, 'b')).toBeNull();
  });

  it('returns null for deep missing key', () => {
    expect(getPath({ a: { b: 1 } }, 'a.c.d')).toBeNull();
  });

  it('resolves positive array index', () => {
    expect(getPath({ items: ['alpha', 'beta', 'gamma'] }, 'items[0]')).toBe('alpha');
    expect(getPath({ items: ['alpha', 'beta', 'gamma'] }, 'items[2]')).toBe('gamma');
  });

  it('resolves negative array index', () => {
    expect(getPath({ items: ['alpha', 'beta', 'gamma'] }, 'items[-1]')).toBe('gamma');
    expect(getPath({ items: ['alpha', 'beta', 'gamma'] }, 'items[-2]')).toBe('beta');
  });

  it('returns null for out of bounds index', () => {
    expect(getPath({ items: ['a'] }, 'items[5]')).toBeNull();
    expect(getPath({ items: ['a'] }, 'items[-5]')).toBeNull();
  });

  it('resolves wildcard to collect values', () => {
    const data = {
      endpoints: [
        { host: 'a.com', port: 80 },
        { host: 'b.com', port: 443 },
      ],
    };
    expect(getPath(data, 'endpoints[*].host')).toEqual(['a.com', 'b.com']);
    expect(getPath(data, 'endpoints[*].port')).toEqual([80, 443]);
  });

  it('resolves length of array', () => {
    expect(getPath({ items: ['a', 'b', 'c'] }, 'items.length')).toBe(3);
  });

  it('resolves length of object', () => {
    expect(getPath({ m: { a: 1, b: 2 } }, 'm.length')).toBe(2);
  });

  it('resolves chained brackets for nested arrays', () => {
    const data = {
      matrix: [
        [1, 2, 3],
        [4, 5, 6],
      ],
    };
    expect(getPath(data, 'matrix[0][1]')).toBe(2);
    expect(getPath(data, 'matrix[1][-1]')).toBe(6);
  });
});

describe('setPath', () => {
  it('sets a simple top-level key', () => {
    const obj = { a: 1 };
    const result = setPath(obj, 'b', 2);
    expect(result).toEqual({ a: 1, b: 2 });
  });

  it('sets a nested key and creates intermediates', () => {
    const obj = {};
    const result = setPath(obj, 'a.b.c', 'deep');
    expect(result).toEqual({ a: { b: { c: 'deep' } } });
  });

  it('sets an array index on an existing array', () => {
    const obj = { items: ['a', 'b', 'c'] };
    setPath(obj, 'items[1]', 'B');
    expect(obj.items).toEqual(['a', 'B', 'c']);
  });

  it('extends array with nulls when index is beyond length', () => {
    const obj = { items: ['a'] };
    setPath(obj, 'items[3]', 'D');
    expect(obj.items).toEqual(['a', null, null, 'D']);
  });

  it('creates array when next segment is index', () => {
    const obj: Record<string, unknown> = {};
    setPath(obj, 'list[0]', 'first');
    expect(obj['list']).toEqual(['first']);
  });

  it('on null root creates object', () => {
    const result = setPath(null, 'key', 'value');
    expect(result).toEqual({ key: 'value' });
  });

  it('on undefined root creates object', () => {
    const result = setPath(undefined, 'key', 'value');
    expect(result).toEqual({ key: 'value' });
  });

  it('throws on wildcard segment', () => {
    expect(() => setPath({ items: [1] }, 'items[*]', 99)).toThrow(/wildcard/);
  });

  it('throws on length segment', () => {
    expect(() => setPath({ items: [1] }, 'items.length', 5)).toThrow(/length/);
  });
});

describe('deletePath', () => {
  it('deletes a top-level key from object', () => {
    const obj = { a: 1, b: 2 };
    expect(deletePath(obj, 'a')).toBe(true);
    expect(obj).toEqual({ b: 2 });
  });

  it('deletes a nested key', () => {
    const obj = { a: { b: { c: 3 }, d: 4 } };
    expect(deletePath(obj, 'a.b.c')).toBe(true);
    expect(obj).toEqual({ a: { b: {}, d: 4 } });
  });

  it('deletes an array element by splicing', () => {
    const obj = { items: ['a', 'b', 'c'] };
    expect(deletePath(obj, 'items[1]')).toBe(true);
    expect(obj.items).toEqual(['a', 'c']);
  });

  it('returns false for missing key', () => {
    const obj = { a: 1 };
    expect(deletePath(obj, 'b')).toBe(false);
  });

  it('returns false on non-object root', () => {
    expect(deletePath('string', 'key')).toBe(false);
    expect(deletePath(42, 'key')).toBe(false);
    expect(deletePath(null, 'key')).toBe(false);
  });
});
