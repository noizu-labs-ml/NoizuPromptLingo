import type { QueueBoardData, QueueDataProvider } from '../types.js';
export interface MockProviderOptions {
    fixture?: QueueBoardData;
    /** Artificial latency in ms to exercise the loading state. */
    delayMs?: number;
}
export declare function createMockProvider(options?: MockProviderOptions): QueueDataProvider;
