function isMap(val: unknown): val is Record<string, unknown> {
  return val !== null && typeof val === 'object' && !Array.isArray(val);
}

function hasTombstone(val: unknown): boolean {
  return isMap(val) && (val as Record<string, unknown>)['_dc_pruned'] === true;
}

function stripTombstones(val: unknown): unknown {
  if (isMap(val)) {
    if (hasTombstone(val)) return undefined;
    const result: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(val as Record<string, unknown>)) {
      const stripped = stripTombstones(v);
      if (stripped !== undefined) {
        result[k] = stripped;
      }
    }
    return result;
  }
  if (Array.isArray(val)) {
    return val.map((v) => stripTombstones(v)).filter((v) => v !== undefined);
  }
  return val;
}

export function deepMerge(base: unknown, overlay: unknown): unknown {
  if (isMap(base) && isMap(overlay)) {
    const result: Record<string, unknown> = { ...base };
    for (const [k, v] of Object.entries(overlay)) {
      if (k in result) {
        result[k] = deepMerge(result[k], v);
      } else {
        result[k] = v;
      }
    }
    return stripTombstones(result);
  }

  // Arrays and scalars: overlay replaces base entirely
  return stripTombstones(overlay);
}

export function deepMergeMulti(layers: unknown[]): unknown {
  if (layers.length === 0) return null;
  if (layers.length === 1) return stripTombstones(layers[0]);

  let result = layers[0];
  for (let i = 1; i < layers.length; i++) {
    result = deepMerge(result, layers[i]);
  }
  return result;
}
