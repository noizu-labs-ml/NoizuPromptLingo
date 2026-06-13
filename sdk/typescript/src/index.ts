export { DcClient } from './client.js';
export type { DcMode, DcClientOptions, Backend } from './types.js';
export { parsePath, getPath, setPath, deletePath } from './path.js';
export { stateDir, pathToHash, storePath, findCurrentStore, ensureStore, ensureConfig, layerPath, activePath } from './store.js';
export { readVersion, watchVersion, bumpVersion } from './version.js';
export { deepMerge, deepMergeMulti } from './merge.js';
export { resolveActive } from './resolve.js';
export { NativeBackend } from './native.js';
export { CliBackend } from './cli.js';
