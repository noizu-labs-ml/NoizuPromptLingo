import {defaultFixture} from '../fixtures.js';
import type {QueueBoardData, QueueDataProvider} from '../types.js';

export interface MockProviderOptions {
  fixture?: QueueBoardData;
  /** Artificial latency in ms to exercise the loading state. */
  delayMs?: number;
}

export function createMockProvider(options: MockProviderOptions = {}): QueueDataProvider {
  const fixture = options.fixture ?? defaultFixture();
  const delayMs = options.delayMs ?? 0;
  return async (query = {}): Promise<QueueBoardData> => {
    if (delayMs) {
      await new Promise<void>((resolve, reject) => {
        const timer = setTimeout(resolve, delayMs);
        query.signal?.addEventListener(
          'abort',
          () => {
            clearTimeout(timer);
            reject(new DOMException('Aborted', 'AbortError'));
          },
          {once: true},
        );
      });
    }
    if (query.signal?.aborted) {
      throw new DOMException('Aborted', 'AbortError');
    }
    return structuredClone(fixture);
  };
}
