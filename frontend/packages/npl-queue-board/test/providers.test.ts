import {expect} from '@open-wc/testing';
import {createMockProvider} from '../src/providers/mock-provider.js';
import {createLockerProvider} from '../src/providers/locker-provider.js';
import {defaultFixture} from '../src/fixtures.js';
import type {QueueBoardData} from '../src/types.js';

describe('createMockProvider', () => {
  it('serves the default fixture', async () => {
    const data = await createMockProvider()();
    expect(data.queues).to.have.lengthOf(2);
    expect(data.items).to.have.lengthOf(9);
  });

  it('serves a custom fixture without sharing mutable state', async () => {
    const fixture: QueueBoardData = {queues: [], items: [{id: 'x', title: 'X'}]};
    const provider = createMockProvider({fixture});
    const first = await provider();
    first.items[0]!.title = 'mutated';
    const second = await provider();
    expect(second.items[0]?.title).to.equal('X');
  });

  it('rejects with AbortError when the signal is already aborted', async () => {
    const controller = new AbortController();
    controller.abort();
    let error: unknown;
    try {
      await createMockProvider()({signal: controller.signal});
    } catch (e) {
      error = e;
    }
    expect((error as DOMException).name).to.equal('AbortError');
  });

  it('honors abort during the artificial delay', async () => {
    const controller = new AbortController();
    const provider = createMockProvider({delayMs: 5000});
    const pending = provider({signal: controller.signal});
    setTimeout(() => controller.abort(), 10);
    let error: unknown;
    try {
      await pending;
    } catch (e) {
      error = e;
    }
    expect((error as DOMException).name).to.equal('AbortError');
  });
});

describe('createLockerProvider', () => {
  const boardsPayload = {boards: [{id: 'b1', name: 'B1'}]};
  const ticketsPayload = {tickets: [{id: 't1', title: 'T1', queue_id: 'b1'}]};

  interface FakeRoute {
    status: number;
    body: unknown;
  }

  function fakeFetch(routes: {boards: FakeRoute; tickets: FakeRoute}) {
    const calls: Array<{url: string; init: RequestInit}> = [];
    const impl = (async (url: RequestInfo | URL, init?: RequestInit) => {
      calls.push({url: String(url), init: init ?? {}});
      const route = String(url).includes('/boards') ? routes.boards : routes.tickets;
      return new Response(JSON.stringify(route.body), {
        status: route.status,
        headers: {'content-type': 'application/json'},
      });
    }) as typeof fetch;
    return {impl, calls};
  }

  const ok = {status: 200, body: {}};
  const boardsOk = {status: 200, body: boardsPayload};
  const ticketsOk = {status: 200, body: ticketsPayload};

  it('fetches boards and tickets and maps them onto the contract', async () => {
    const {impl, calls} = fakeFetch({boards: boardsOk, tickets: ticketsOk});
    const provider = createLockerProvider({
      baseUrl: 'https://npl.example.test',
      orgId: 'org-1',
      projectId: 'proj-9',
      fetchImpl: impl,
    });
    const data = await provider();
    expect(data).to.deep.equal({queues: [{id: 'b1', name: 'B1'}], items: [{id: 't1', title: 'T1', queue_id: 'b1'}]});
    expect(calls[0]?.url).to.equal(
      'https://npl.example.test/api/v1/organizations/org-1/boards?project_id=proj-9',
    );
    expect(calls[1]?.url).to.equal(
      'https://npl.example.test/api/v1/organizations/org-1/tickets?project_id=proj-9',
    );
  });

  it('omits project_id and the auth header when not configured', async () => {
    const {impl, calls} = fakeFetch({boards: ok, tickets: ok});
    const provider = createLockerProvider({baseUrl: '', orgId: 'org-1', fetchImpl: impl});
    await provider();
    expect(calls[0]?.url).to.not.include('?');
    const headers = calls[0]?.init.headers as Record<string, string>;
    expect(headers?.Authorization).to.equal(undefined);
  });

  it('sends the bearer token as a header when provided', async () => {
    const {impl, calls} = fakeFetch({boards: ok, tickets: ok});
    const provider = createLockerProvider({
      baseUrl: '',
      orgId: 'org-1',
      token: 'secret-token',
      fetchImpl: impl,
    });
    await provider();
    for (const call of calls) {
      expect((call.init.headers as Record<string, string>).Authorization).to.equal(
        'Bearer secret-token',
      );
    }
  });

  it('throws on non-2xx responses', async () => {
    const forbidden = {status: 403, body: {error: 'forbidden'}};
    const {impl} = fakeFetch({boards: forbidden, tickets: forbidden});
    const provider = createLockerProvider({baseUrl: '', orgId: 'org-1', fetchImpl: impl});
    let error: unknown;
    try {
      await provider();
    } catch (e) {
      error = e;
    }
    expect((error as Error).message).to.include('403');
  });

  it('tolerates missing collections in the payload', async () => {
    const {impl} = fakeFetch({boards: ok, tickets: ok});
    const provider = createLockerProvider({baseUrl: '', orgId: 'org-1', fetchImpl: impl});
    const data = await provider();
    expect(data).to.deep.equal({queues: [], items: []});
  });
});
