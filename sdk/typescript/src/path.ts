type Segment =
  | { type: 'key'; value: string }
  | { type: 'index'; value: number }
  | { type: 'wildcard' }
  | { type: 'length' };

export function parsePath(path: string): Segment[] {
  const segments: Segment[] = [];
  if (!path) return segments;

  for (const token of path.split('.')) {
    if (token === 'length' && segments.length > 0) {
      segments.push({ type: 'length' });
      continue;
    }

    const bracketPos = token.indexOf('[');
    if (bracketPos !== -1) {
      const keyPart = token.slice(0, bracketPos);
      if (keyPart) {
        segments.push({ type: 'key', value: keyPart });
      }

      let rest = token.slice(bracketPos);
      while (rest.includes('[')) {
        const open = rest.indexOf('[');
        const close = rest.indexOf(']');
        const inner = rest.slice(open + 1, close);
        if (inner === '*') {
          segments.push({ type: 'wildcard' });
        } else {
          segments.push({ type: 'index', value: parseInt(inner, 10) });
        }
        rest = rest.slice(close + 1);
      }
    } else {
      segments.push({ type: 'key', value: token });
    }
  }

  return segments;
}

function resolveIndex(idx: number, len: number): number | null {
  const resolved = idx < 0 ? len + idx : idx;
  if (resolved < 0 || resolved >= len) return null;
  return resolved;
}

function getSegments(current: unknown, segments: Segment[]): unknown {
  if (segments.length === 0) return current;

  const [seg, ...rest] = segments;

  switch (seg.type) {
    case 'key': {
      if (current === null || current === undefined || typeof current !== 'object' || Array.isArray(current)) {
        return null;
      }
      const map = current as Record<string, unknown>;
      if (!(seg.value in map)) return null;
      return getSegments(map[seg.value], rest);
    }
    case 'index': {
      if (!Array.isArray(current)) return null;
      const resolved = resolveIndex(seg.value, current.length);
      if (resolved === null) return null;
      return getSegments(current[resolved], rest);
    }
    case 'wildcard': {
      if (!Array.isArray(current)) return null;
      return current
        .map((elem) => getSegments(elem, rest))
        .filter((v) => v !== null);
    }
    case 'length': {
      if (rest.length > 0) return null;
      if (Array.isArray(current)) return current.length;
      if (current !== null && typeof current === 'object') return Object.keys(current as object).length;
      return null;
    }
  }
}

export function getPath(root: unknown, path: string): unknown {
  const segments = parsePath(path);
  return getSegments(root, segments);
}

function isMap(val: unknown): val is Record<string, unknown> {
  return val !== null && typeof val === 'object' && !Array.isArray(val);
}

export function setPath(root: unknown, path: string, value: unknown): unknown {
  const segments = parsePath(path);
  if (segments.length === 0) return value;

  if (root === null || root === undefined) {
    root = {};
  }

  let current: unknown = root;

  for (let i = 0; i < segments.length - 1; i++) {
    const seg = segments[i];
    const next = segments[i + 1];

    if (seg.type === 'wildcard' || seg.type === 'length') {
      throw new Error(`Cannot use ${seg.type} segment in setPath`);
    }

    if (seg.type === 'key') {
      if (!isMap(current)) {
        throw new Error(`Expected object at key "${seg.value}", got ${typeof current}`);
      }
      const map = current as Record<string, unknown>;
      if (map[seg.value] === null || map[seg.value] === undefined) {
        map[seg.value] = next.type === 'index' ? [] : {};
      }
      current = map[seg.value];
    } else if (seg.type === 'index') {
      if (!Array.isArray(current)) {
        throw new Error(`Expected array at index [${seg.value}], got ${typeof current}`);
      }
      const arr = current as unknown[];
      const idx = seg.value < 0 ? arr.length + seg.value : seg.value;
      if (idx < 0) {
        throw new Error(`Negative index [${seg.value}] out of bounds for array of length ${arr.length}`);
      }
      while (arr.length <= idx) {
        arr.push(null);
      }
      if (arr[idx] === null || arr[idx] === undefined) {
        arr[idx] = next.type === 'index' ? [] : {};
      }
      current = arr[idx];
    }
  }

  const last = segments[segments.length - 1];
  if (last.type === 'wildcard' || last.type === 'length') {
    throw new Error(`Cannot use ${last.type} segment in setPath`);
  }

  if (last.type === 'key') {
    if (!isMap(current)) {
      throw new Error(`Expected object at key "${last.value}", got ${typeof current}`);
    }
    (current as Record<string, unknown>)[last.value] = value;
  } else if (last.type === 'index') {
    if (!Array.isArray(current)) {
      throw new Error(`Expected array at index [${last.value}], got ${typeof current}`);
    }
    const arr = current as unknown[];
    const idx = last.value < 0 ? arr.length + last.value : last.value;
    if (idx < 0) {
      throw new Error(`Negative index [${last.value}] out of bounds for array of length ${arr.length}`);
    }
    while (arr.length <= idx) {
      arr.push(null);
    }
    arr[idx] = value;
  }

  return root;
}

export function deletePath(root: unknown, path: string): boolean {
  const segments = parsePath(path);
  if (segments.length === 0) return false;

  let current: unknown = root;

  for (let i = 0; i < segments.length - 1; i++) {
    const seg = segments[i];

    if (seg.type === 'key') {
      if (!isMap(current)) return false;
      current = (current as Record<string, unknown>)[seg.value];
      if (current === null || current === undefined) return false;
    } else if (seg.type === 'index') {
      if (!Array.isArray(current)) return false;
      const idx = seg.value < 0 ? current.length + seg.value : seg.value;
      if (idx < 0 || idx >= current.length) return false;
      current = current[idx];
    } else {
      return false;
    }
  }

  const last = segments[segments.length - 1];

  if (last.type === 'key') {
    if (!isMap(current)) return false;
    const map = current as Record<string, unknown>;
    if (!(last.value in map)) return false;
    delete map[last.value];
    return true;
  } else if (last.type === 'index') {
    if (!Array.isArray(current)) return false;
    const arr = current as unknown[];
    const idx = last.value < 0 ? arr.length + last.value : last.value;
    if (idx < 0 || idx >= arr.length) return false;
    arr.splice(idx, 1);
    return true;
  }

  return false;
}
