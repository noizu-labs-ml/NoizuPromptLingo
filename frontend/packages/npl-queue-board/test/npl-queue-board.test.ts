import {fixture, html, expect, waitUntil} from '@open-wc/testing';
import '../src/npl-queue-board.js';
import type {NplQueueBoard} from '../src/npl-queue-board.js';
import {createMockProvider} from '../src/providers/mock-provider.js';
import {defaultFixture} from '../src/fixtures.js';
import type {QueueBoardData, QueueDataProvider} from '../src/types.js';

const mini: QueueBoardData = {
  queues: [
    {
      id: 'b1',
      name: 'Mini Board',
      methodology: 'kanban',
      stages: [
        {id: 's1', name: 'Open', kind: 'todo', position: 0},
        {id: 's2', name: 'Closed', kind: 'done', position: 1},
      ],
    },
  ],
  items: [
    {
      id: 't1',
      key: 'M-1',
      title: 'First ticket',
      status: 'open',
      priority: 'high',
      assignee: 'Ada Lovelace',
      tags: ['alpha'],
      queue_id: 'b1',
      stage_id: 's1',
    },
    {
      id: 't2',
      title: 'Orphan ticket',
      status: 'open',
      queue_id: 'b1',
      stage_id: null,
    },
  ],
};

function rejectingProvider(message = 'boom'): QueueDataProvider {
  return async () => {
    throw new Error(message);
  };
}

async function loadedBoard(el: NplQueueBoard): Promise<void> {
  await waitUntil(() => el.shadowRoot?.querySelector('.board'), 'boards rendered', {
    timeout: 2000,
  });
}

describe('npl-queue-board', () => {
  it('renders a loading state before data arrives', async () => {
    const el = await fixture<NplQueueBoard>(
      html`<npl-queue-board></npl-queue-board>`,
    );
    el.dataProvider = createMockProvider({delayMs: 60});
    await el.updateComplete;
    expect(el.shadowRoot?.querySelector('[role="status"]')).to.exist;
    expect(el.shadowRoot?.textContent).to.include('Loading queues');
  });

  it('renders boards, columns, and cards from the provider', async () => {
    const el = await fixture<NplQueueBoard>(
      html`<npl-queue-board></npl-queue-board>`,
    );
    el.dataProvider = createMockProvider();
    await loadedBoard(el);
    expect(el.shadowRoot?.textContent).to.include('Release Ops');
    expect(el.shadowRoot?.textContent).to.include('Agent Tools Sprint');
    expect(el.shadowRoot?.querySelectorAll('.column').length).to.be.greaterThan(4);
    expect(el.shadowRoot?.querySelectorAll('.card').length).to.equal(9);
    expect(el.shadowRoot?.textContent).to.include('NPL-101');
  });

  it('groups tickets by stage with an Unstaged fallback', async () => {
    const el = await fixture<NplQueueBoard>(
      html`<npl-queue-board .dataProvider=${createMockProvider({fixture: mini})}></npl-queue-board>`,
    );
    await loadedBoard(el);
    const titles = [...el.shadowRoot!.querySelectorAll('.column-title')].map(
      n => n.textContent?.trim(),
    );
    expect(titles).to.deep.equal(['Open', 'Closed', 'Unstaged']);
    const unstaged = el.shadowRoot!.textContent!;
    expect(unstaged).to.include('Orphan ticket');
    expect(unstaged).to.include('First ticket');
  });

  it('renders card metadata: key, priority, tags, assignee', async () => {
    const el = await fixture<NplQueueBoard>(
      html`<npl-queue-board .dataProvider=${createMockProvider({fixture: mini})}></npl-queue-board>`,
    );
    await loadedBoard(el);
    const text = el.shadowRoot!.textContent!;
    expect(text).to.include('M-1');
    expect(text).to.include('high');
    expect(text).to.include('alpha');
    expect(text).to.include('Ada Lovelace');
    expect(text).to.include('Unassigned');
  });

  it('emits card-activate with the ticket when a card is clicked', async () => {
    const el = await fixture<NplQueueBoard>(
      html`<npl-queue-board .dataProvider=${createMockProvider({fixture: mini})}></npl-queue-board>`,
    );
    await loadedBoard(el);
    let detail: unknown;
    el.addEventListener('card-activate', (e: CustomEvent) => {
      detail = e.detail;
    });
    (el.shadowRoot!.querySelector('.card') as HTMLButtonElement).click();
    expect((detail as {ticket: {id: string}}).ticket.id).to.equal('t1');
  });

  it('shows an error state and fires queue-load-error', async () => {
    const el = await fixture<NplQueueBoard>(
      html`<npl-queue-board></npl-queue-board>`,
    );
    let errorDetail: unknown;
    el.addEventListener('queue-load-error', (e: CustomEvent) => {
      errorDetail = e.detail;
    });
    el.dataProvider = rejectingProvider('socket down');
    await waitUntil(() => el.shadowRoot?.querySelector('[role="alert"]'), 'error shown', {
      timeout: 2000,
    });
    expect(el.shadowRoot?.textContent).to.include('socket down');
    expect(el.shadowRoot?.querySelector('.retry')).to.exist;
    expect((errorDetail as {error: string}).error).to.equal('socket down');
  });

  it('recovers via the Retry button', async () => {
    let fail = true;
    const flaky: QueueDataProvider = async () => {
      if (fail) {
        throw new Error('flaky');
      }
      return mini;
    };
    const el = await fixture<NplQueueBoard>(
      html`<npl-queue-board .dataProvider=${flaky}></npl-queue-board>`,
    );
    await waitUntil(() => el.shadowRoot?.querySelector('.retry'), 'retry shown', {
      timeout: 2000,
    });
    fail = false;
    (el.shadowRoot!.querySelector('.retry') as HTMLButtonElement).click();
    await loadedBoard(el);
    expect(el.shadowRoot?.textContent).to.include('Mini Board');
  });

  it('renders an empty state when the provider returns nothing', async () => {
    const el = await fixture<NplQueueBoard>(
      html`<npl-queue-board
        .dataProvider=${createMockProvider({fixture: {queues: [], items: []}})}
      ></npl-queue-board>`,
    );
    await waitUntil(
      () => el.shadowRoot?.textContent?.includes('No queues to display'),
      'empty state',
      {timeout: 2000},
    );
  });

  it('filters to a single board via boardId', async () => {
    const el = await fixture<NplQueueBoard>(
      html`<npl-queue-board boardId="board-agent-tools"></npl-queue-board>`,
    );
    el.dataProvider = createMockProvider();
    await loadedBoard(el);
    expect(el.shadowRoot?.textContent).to.include('Agent Tools Sprint');
    expect(el.shadowRoot?.textContent).to.not.include('Release Ops');
    expect(el.shadowRoot?.querySelectorAll('.card').length).to.equal(3);
  });

  it('respects hide-empty-stages', async () => {
    const el = await fixture<NplQueueBoard>(
      html`<npl-queue-board
        boardId="board-agent-tools"
        hide-empty-stages
      ></npl-queue-board>`,
    );
    el.dataProvider = createMockProvider();
    await loadedBoard(el);
    const titles = [...el.shadowRoot!.querySelectorAll('.column-title')].map(
      n => n.textContent?.trim(),
    );
    expect(titles).to.not.include('In Review');
  });

  it('shows columns with zero tickets by default', async () => {
    const el = await fixture<NplQueueBoard>(
      html`<npl-queue-board boardId="board-agent-tools"></npl-queue-board>`,
    );
    el.dataProvider = createMockProvider();
    await loadedBoard(el);
    expect(el.shadowRoot?.textContent).to.include('Nothing here');
  });

  it('ignores a stale response from a replaced provider', async () => {
    const slow: QueueDataProvider = () =>
      new Promise(resolve => setTimeout(() => resolve(mini), 300));
    const el = await fixture<NplQueueBoard>(
      html`<npl-queue-board .dataProvider=${slow}></npl-queue-board>`,
    );
    el.dataProvider = createMockProvider({fixture: mini});
    await loadedBoard(el);
    expect(el.shadowRoot?.textContent).to.include('Mini Board');
    await new Promise(resolve => setTimeout(resolve, 350));
    expect(el.shadowRoot?.querySelectorAll('.board').length).to.equal(1);
  });

  it('refresh() re-invokes the provider', async () => {
    let calls = 0;
    const counting: QueueDataProvider = async () => {
      calls++;
      return mini;
    };
    const el = await fixture<NplQueueBoard>(
      html`<npl-queue-board .dataProvider=${counting}></npl-queue-board>`,
    );
    await loadedBoard(el);
    expect(calls).to.equal(1);
    await el.refresh();
    await el.updateComplete;
    expect(calls).to.equal(2);
  });

  it('passes an AbortSignal to the provider', async () => {
    let seen: unknown;
    const capture: QueueDataProvider = async query => {
      seen = query?.signal;
      return mini;
    };
    const el = await fixture<NplQueueBoard>(
      html`<npl-queue-board .dataProvider=${capture}></npl-queue-board>`,
    );
    await loadedBoard(el);
    expect(seen).to.be.instanceOf(AbortSignal);
  });

  it('renders a placeholder region without a provider', async () => {
    const el = await fixture<NplQueueBoard>(
      html`<npl-queue-board heading="Empty shell"></npl-queue-board>`,
    );
    await el.updateComplete;
    expect(el.shadowRoot?.textContent).to.include('No queues to display');
  });

  it('is accessible when loaded', async () => {
    const el = await fixture<NplQueueBoard>(
      html`<npl-queue-board .dataProvider=${createMockProvider({fixture: mini})}></npl-queue-board>`,
    );
    await loadedBoard(el);
    await expect(el).to.be.accessible();
  });

  it('is accessible while loading and in the error state', async () => {
    const el = await fixture<NplQueueBoard>(
      html`<npl-queue-board></npl-queue-board>`,
    );
    el.dataProvider = createMockProvider({delayMs: 50});
    await el.updateComplete;
    await expect(el).to.be.accessible();
    el.dataProvider = rejectingProvider();
    await waitUntil(() => el.shadowRoot?.querySelector('[role="alert"]'), 'error shown', {
      timeout: 2000,
    });
    await expect(el).to.be.accessible();
  });

  it('renders the full default fixture accessibly', async () => {
    const el = await fixture<NplQueueBoard>(
      html`<npl-queue-board .dataProvider=${createMockProvider()}></npl-queue-board>`,
    );
    await loadedBoard(el);
    expect(defaultFixture().items.length).to.equal(9);
    await expect(el).to.be.accessible();
  });
});
