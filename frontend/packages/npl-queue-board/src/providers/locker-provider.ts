import type {QueueBoardData, QueueDataProvider, QueueDataQuery} from '../types.js';

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

export function createLockerProvider(options: LockerProviderOptions): QueueDataProvider {
  const {baseUrl, orgId, projectId = null, token = null, fetchImpl = fetch} = options;
  return async (query: QueueDataQuery = {}): Promise<QueueBoardData> => {
    const orgPath = `/api/v1/organizations/${encodeURIComponent(orgId)}`;
    const search = new URLSearchParams();
    if (projectId) search.set('project_id', projectId);
    const qs = search.toString();
    const headers: HeadersInit = token ? {Authorization: `Bearer ${token}`} : {};
    const [boardsRes, ticketsRes] = await Promise.all([
      fetchImpl(`${baseUrl}${orgPath}/boards${qs ? `?${qs}` : ''}`, {
        headers,
        signal: query.signal,
      }),
      fetchImpl(`${baseUrl}${orgPath}/tickets${qs ? `?${qs}` : ''}`, {
        headers,
        signal: query.signal,
      }),
    ]);
    if (!boardsRes.ok) {
      throw new Error(`Boards request failed: ${boardsRes.status} ${boardsRes.statusText}`);
    }
    if (!ticketsRes.ok) {
      throw new Error(`Tickets request failed: ${ticketsRes.status} ${ticketsRes.statusText}`);
    }
    const boardsBody = (await boardsRes.json()) as {boards?: QueueBoardData['queues']};
    const ticketsBody = (await ticketsRes.json()) as {tickets?: QueueBoardData['items']};
    return {queues: boardsBody.boards ?? [], items: ticketsBody.tickets ?? []};
  };
}
