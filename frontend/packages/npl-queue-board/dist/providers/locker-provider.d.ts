import type { QueueDataProvider } from '../types.js';
export interface LockerProviderOptions {
    /** Base URL of the NPL API host, e.g. https://tobor.locker.noizu.com */
    baseUrl: string;
    /** Organization id (uuid) or slug. */
    orgId: string;
    /** Optional project id to scope boards/tickets. */
    projectId?: string | null;
    /** Bearer token; embed-key auth wiring lands in a later integration task. */
    token?: string | null;
    /** Injectable fetch for tests and custom clients. */
    fetchImpl?: typeof fetch;
}
export declare function createLockerProvider(options: LockerProviderOptions): QueueDataProvider;
