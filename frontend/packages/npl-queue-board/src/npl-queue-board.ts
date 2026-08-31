import {LitElement, html, nothing, type PropertyValues} from 'lit';
import {css} from 'lit';
import {customElement, property, state} from 'lit/decorators.js';
import {classMap} from 'lit/directives/class-map.js';
import {repeat} from 'lit/directives/repeat.js';
import {queueBoardTokens} from './tokens.js';
import {
  groupBoards,
  initials,
  priorityKind,
  statusKind,
  ticketTags,
  type BoardColumn,
  type BoardGroup,
} from './grouping.js';
import type {QueueBoardData, QueueDataProvider, QueueTicket} from './types.js';

const UNSTAGED_KEY = '__unstaged__';

@customElement('npl-queue-board')
export class NplQueueBoard extends LitElement {
  static styles = [
    queueBoardTokens,
    css`
      :host {
        border-radius: var(--nqb-radius);
      }
      .board-region {
        display: block;
        padding: var(--nqb-pad);
      }
      .heading {
        margin: 0 0 var(--nqb-gap);
        font-size: 1.05rem;
        font-weight: 650;
      }
      .board + .board {
        margin-top: 24px;
      }
      .board-header {
        display: flex;
        align-items: baseline;
        gap: 10px;
        margin: 0 0 var(--nqb-gap);
      }
      .board-name {
        margin: 0;
        font-size: 0.95rem;
        font-weight: 650;
      }
      .methodology {
        font-size: 0.7rem;
        text-transform: uppercase;
        letter-spacing: 0.06em;
        color: var(--nqb-text-muted);
        background: var(--nqb-surface-raised);
        border: 1px solid var(--nqb-border);
        border-radius: 999px;
        padding: 2px 8px;
      }
      .board-count {
        font-size: 0.78rem;
        color: var(--nqb-text-muted);
      }
      .columns {
        display: grid;
        grid-auto-flow: column;
        grid-auto-columns: clamp(230px, 34vw, var(--nqb-column-width));
        gap: var(--nqb-gap);
        align-items: start;
        overflow-x: auto;
        padding-bottom: 6px;
      }
      .column {
        background: var(--nqb-surface);
        border: 1px solid var(--nqb-border);
        border-radius: var(--nqb-radius);
        min-width: 0;
      }
      .column-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 8px;
        padding: 10px 12px;
        border-bottom: 1px solid var(--nqb-border);
      }
      .column-title {
        margin: 0;
        font-size: 0.82rem;
        font-weight: 650;
        color: var(--nqb-text);
      }
      .column-count {
        font-size: 0.75rem;
        color: var(--nqb-text-muted);
        font-family: var(--nqb-mono);
        white-space: nowrap;
      }
      .column-count.over {
        color: var(--nqb-danger);
        font-weight: 700;
      }
      .cards {
        list-style: none;
        margin: 0;
        padding: 10px;
        display: flex;
        flex-direction: column;
        gap: 8px;
      }
      .cards-empty {
        padding: 6px 12px 12px;
        font-size: 0.78rem;
        color: var(--nqb-text-muted);
      }
      .card {
        display: block;
        width: 100%;
        text-align: left;
        background: var(--nqb-surface);
        border: 1px solid var(--nqb-border);
        border-radius: var(--nqb-radius-sm);
        padding: 10px 12px;
        font: inherit;
        color: inherit;
        cursor: pointer;
        transition: border-color 120ms ease, background 120ms ease;
      }
      .card:hover {
        border-color: var(--nqb-accent);
      }
      .card:focus-visible {
        outline: 2px solid var(--nqb-accent);
        outline-offset: 2px;
      }
      .card-top {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 8px;
        margin-bottom: 4px;
      }
      .key {
        font-family: var(--nqb-mono);
        font-size: 0.72rem;
        color: var(--nqb-accent);
        font-weight: 600;
      }
      .type {
        font-size: 0.68rem;
        color: var(--nqb-text-muted);
        text-transform: uppercase;
        letter-spacing: 0.05em;
      }
      .title {
        display: block;
        font-size: 0.86rem;
        font-weight: 550;
        line-height: 1.35;
        margin-bottom: 8px;
      }
      .meta {
        display: flex;
        align-items: center;
        flex-wrap: wrap;
        gap: 6px;
        margin-bottom: 8px;
      }
      .status {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        font-size: 0.73rem;
        color: var(--nqb-text-muted);
      }
      .dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: var(--nqb-text-muted);
      }
      .status--done .dot { background: var(--nqb-ok); }
      .status--active .dot { background: var(--nqb-accent); }
      .status--blocked .dot { background: var(--nqb-danger); }
      .chip {
        font-size: 0.68rem;
        font-weight: 600;
        border-radius: 999px;
        padding: 1px 7px;
        background: var(--nqb-chip-bg);
        color: var(--nqb-text-muted);
      }
      .chip--high { background: var(--nqb-danger); color: var(--nqb-surface); }
      .chip--medium { background: var(--nqb-warn); color: var(--nqb-surface); }
      .tags {
        display: flex;
        flex-wrap: wrap;
        gap: 4px;
        margin-bottom: 8px;
      }
      .tag {
        font-size: 0.68rem;
        background: var(--nqb-surface-raised);
        border: 1px solid var(--nqb-border);
        color: var(--nqb-text-muted);
        border-radius: 999px;
        padding: 1px 7px;
      }
      .assignee {
        display: flex;
        align-items: center;
        gap: 6px;
        font-size: 0.75rem;
        color: var(--nqb-text-muted);
      }
      .avatar {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 18px;
        height: 18px;
        border-radius: 50%;
        background: var(--nqb-accent);
        color: var(--nqb-accent-contrast);
        font-size: 0.6rem;
        font-weight: 700;
      }
      .state {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 10px;
        padding: 32px 16px;
        color: var(--nqb-text-muted);
        font-size: 0.9rem;
        text-align: center;
      }
      .state--error {
        color: var(--nqb-danger);
      }
      .spinner {
        width: 22px;
        height: 22px;
        border: 3px solid var(--nqb-border);
        border-top-color: var(--nqb-accent);
        border-radius: 50%;
        animation: nqb-spin 0.8s linear infinite;
      }
      @keyframes nqb-spin {
        to { transform: rotate(360deg); }
      }
      .retry {
        font: inherit;
        font-size: 0.82rem;
        padding: 6px 14px;
        border-radius: var(--nqb-radius-sm);
        border: 1px solid var(--nqb-accent);
        background: var(--nqb-accent);
        color: var(--nqb-accent-contrast);
        cursor: pointer;
      }
      .retry:focus-visible {
        outline: 2px solid var(--nqb-accent);
        outline-offset: 2px;
      }
    `,
  ];

  @property({attribute: false})
  dataProvider: QueueDataProvider | null = null;

  @property()
  boardId = '';

  @property()
  heading = '';

  @property({reflect: true})
  theme: 'auto' | 'light' | 'dark' = 'auto';

  @property({type: Boolean, attribute: 'hide-empty-stages'})
  hideEmptyStages = false;

  @state() private _loading = false;
  @state() private _error: string | null = null;
  @state() private _data: QueueBoardData | null = null;

  private _loadSeq = 0;
  private _abort: AbortController | null = null;

  refresh(): Promise<void> {
    return this._load();
  }

  protected willUpdate(changed: PropertyValues<this>): void {
    if (changed.has('dataProvider') || changed.has('boardId')) {
      void this._load();
    }
  }

  private async _load(): Promise<void> {
    const provider = this.dataProvider;
    this._abort?.abort();
    this._abort = null;
    this._loadSeq++;
    if (!provider) {
      this._data = null;
      this._error = null;
      this._loading = false;
      return;
    }
    const seq = this._loadSeq;
    const abort = new AbortController();
    this._abort = abort;
    this._loading = true;
    this._error = null;
    try {
      const data = await provider({signal: abort.signal});
      if (seq !== this._loadSeq) return;
      this._data =
        data && Array.isArray(data.queues) && Array.isArray(data.items)
          ? data
          : {queues: [], items: []};
      this._loading = false;
    } catch (error) {
      if (seq !== this._loadSeq) return;
      this._loading = false;
      this._error = error instanceof Error ? error.message : String(error);
      this.dispatchEvent(
        new CustomEvent('queue-load-error', {
          detail: {error: this._error},
          bubbles: true,
          composed: true,
        }),
      );
    }
  }

  private _activate(ticket: QueueTicket): void {
    this.dispatchEvent(
      new CustomEvent('card-activate', {
        detail: {ticket},
        bubbles: true,
        composed: true,
      }),
    );
  }

  render() {
    return html`
      <section
        class="board-region"
        role="region"
        aria-label=${this.heading || 'Ticket queues'}
        aria-busy=${this._loading ? 'true' : 'false'}
      >
        ${this.heading ? html`<h2 class="heading">${this.heading}</h2>` : nothing}
        ${this._loading ? this._renderLoading() : nothing}
        ${this._error ? this._renderError() : nothing}
        ${!this._loading && !this._error ? this._renderBoards() : nothing}
      </section>
    `;
  }

  private _renderLoading() {
    return html`
      <div class="state" role="status">
        <span class="spinner" aria-hidden="true"></span>
        <span>Loading queues…</span>
      </div>
    `;
  }

  private _renderError() {
    return html`
      <div class="state state--error" role="alert">
        <strong>Failed to load queues.</strong>
        <p>${this._error}</p>
        <button type="button" class="retry" @click=${() => void this._load()}>Retry</button>
      </div>
    `;
  }

  private _renderBoards() {
    if (!this._data) {
      return html`
        <div class="state" role="status">
          <span>No queues to display.</span>
        </div>
      `;
    }
    const groups = groupBoards(this._data, this.boardId || undefined);
    if (!groups.length) {
      return html`
        <div class="state" role="status">
          <span>No queues to display.</span>
        </div>
      `;
    }
    return html`
      ${repeat(
        groups,
        g => g.board.id,
        g => this._renderBoard(g),
      )}
    `;
  }

  private _renderBoard(group: BoardGroup) {
    const visible = group.columns.filter(
      c => !(this.hideEmptyStages && c.tickets.length === 0),
    );
    return html`
      <section class="board" aria-label=${group.board.name}>
        <header class="board-header">
          <h3 class="board-name">${group.board.name}</h3>
          ${group.board.methodology
            ? html`<span class="methodology">${group.board.methodology}</span>`
            : nothing}
          <span class="board-count">${group.totalCount} ${group.totalCount === 1 ? 'item' : 'items'}</span>
        </header>
        ${visible.length
          ? html`
              <div class="columns">
                ${repeat(
                  visible,
                  c => c.stage?.id ?? UNSTAGED_KEY,
                  c => this._renderColumn(c),
                )}
              </div>
            `
          : html`<p class="cards-empty">No stages configured.</p>`}
      </section>
    `;
  }

  private _renderColumn(column: BoardColumn) {
    const name = column.stage?.name ?? 'Unstaged';
    const wip = column.stage?.wip_limit ?? null;
    const over = wip != null && column.tickets.length > wip;
    return html`
      <div class="column" role="group" aria-label=${`${name} (${column.tickets.length})`}>
        <header class="column-header">
          <h4 class="column-title">${name}</h4>
          <span class=${classMap({'column-count': true, over})}
            >${column.tickets.length}${wip != null ? `/${wip}` : ''}</span
          >
        </header>
        ${column.tickets.length
          ? html`
              <ul class="cards">
                ${repeat(
                  column.tickets,
                  t => t.id,
                  t => html`<li>${this._renderCard(t)}</li>`,
                )}
              </ul>
            `
          : html`<p class="cards-empty">Nothing here.</p>`}
      </div>
    `;
  }

  private _renderCard(ticket: QueueTicket) {
    const kind = statusKind(ticket.status);
    const prio = priorityKind(ticket.priority);
    const tags = ticketTags(ticket);
    return html`
      <button type="button" class="card" @click=${() => this._activate(ticket)}>
        <span class="card-top">
          ${ticket.key ? html`<span class="key">${ticket.key}</span>` : nothing}
          ${ticket.ticket_type ? html`<span class="type">${ticket.ticket_type}</span>` : nothing}
        </span>
        <span class="title">${ticket.title}</span>
        <span class="meta">
          <span class=${`status status--${kind}`}>
            <span class="dot" aria-hidden="true"></span>${(ticket.status ?? 'unknown').replace(/_/g, ' ')}
          </span>
          ${prio ? html`<span class=${`chip chip--${prio}`}>${ticket.priority}</span>` : nothing}
        </span>
        ${tags.length
          ? html`
              <span class="tags">
                ${tags.map(tag => html`<span class="tag">${tag}</span>`)}
              </span>
            `
          : nothing}
        <span class="assignee">
          ${ticket.assignee
            ? html`<span class="avatar" aria-hidden="true">${initials(ticket.assignee)}</span>`
            : nothing}
          <span>${ticket.assignee || 'Unassigned'}</span>
        </span>
      </button>
    `;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'npl-queue-board': NplQueueBoard;
  }
}
