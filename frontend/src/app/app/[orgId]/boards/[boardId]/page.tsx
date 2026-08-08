'use client';

import { useState, useEffect, useCallback, useMemo } from 'react';
import { useParams } from 'next/navigation';
import Link from 'next/link';
import { toast } from 'sonner';
import { api, type Board, type BoardIteration, type Ticket, TICKET_PRIORITIES } from '@/lib/api';
import { useOrgId } from '@/context/org';

const TICKET_TYPES = ['task', 'bug', 'user_story', 'epic', 'prd', 'documentation', 'research', 'subtask'];
const NO_STAGE = '__none__';
const BACKLOG = '__backlog__';

// A board's *type* is its methodology; its *scope* (org vs project) is separate —
// keep them distinct so a board isn't mislabeled as a "project".
const titleCase = (s: string) => (s ? s.charAt(0).toUpperCase() + s.slice(1) : s);

function NewTicketModal({
  orgId,
  board,
  defaultStageId,
  iterationId,
  onClose,
  onSaved,
}: {
  orgId: string;
  board: Board;
  defaultStageId?: string;
  iterationId?: string | null;
  onClose: () => void;
  onSaved: () => void;
}) {
  const [title, setTitle] = useState('');
  const [ticketType, setTicketType] = useState('task');
  const [priority, setPriority] = useState('');
  const [stageId, setStageId] = useState(defaultStageId ?? board.stages?.[0]?.id ?? '');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!title.trim()) return;
    setSaving(true);
    setError(null);
    try {
      await api.createTicket(orgId, {
        title: title.trim(),
        // Send an explicit status: the BE overrides its schema default with an
        // explicit nil if status is absent -> NOT NULL violation -> 500 (mei
        // seq369, same gap as the tickets-page modal).
        status: 'open',
        ticket_type: ticketType,
        priority: priority || null,
        project_id: board.project_id ?? null,
        queue_id: board.id,
        stage_id: stageId || null,
        iteration_id: iterationId ?? null,
      });
      toast.success('Ticket created');
      onSaved();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Request failed');
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-card" onClick={(e) => e.stopPropagation()}>
        <h2 className="modal-title">New Ticket</h2>
        <form onSubmit={handleSubmit}>
          <div className="sg-field">
            <label htmlFor="nt-title">Title</label>
            <input id="nt-title" value={title} onChange={(e) => setTitle(e.target.value)} placeholder="Do the thing" autoFocus />
          </div>
          <div className="sg-field">
            <label htmlFor="nt-type">Type</label>
            <select id="nt-type" value={ticketType} onChange={(e) => setTicketType(e.target.value)}>
              {TICKET_TYPES.map((t) => (
                <option key={t} value={t}>
                  {t}
                </option>
              ))}
            </select>
          </div>
          <div className="sg-field">
            <label htmlFor="nt-priority">Priority</label>
            <select id="nt-priority" value={priority} onChange={(e) => setPriority(e.target.value)}>
              <option value="">None</option>
              {TICKET_PRIORITIES.map((p) => (
                <option key={p} value={p}>
                  {p}
                </option>
              ))}
            </select>
          </div>
          <div className="sg-field">
            <label htmlFor="nt-stage">Stage</label>
            <select id="nt-stage" value={stageId} onChange={(e) => setStageId(e.target.value)}>
              {board.stages?.map((s) => (
                <option key={s.id} value={s.id}>
                  {s.name}
                </option>
              ))}
            </select>
          </div>
          {error && <div className="sg-error">{error}</div>}
          <div className="modal-actions">
            <button type="button" className="sg-btn sg-btn--outline" onClick={onClose}>
              Cancel
            </button>
            <button type="submit" className="sg-btn sg-btn--black" disabled={saving || !title.trim()}>
              {saving ? 'Saving…' : 'Create'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default function BoardDetailPage() {
  const { orgId, slug, loading: orgLoading } = useOrgId();
  const params = useParams();
  const boardId = params.boardId as string;

  const [board, setBoard] = useState<Board | null>(null);
  const [tickets, setTickets] = useState<Ticket[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [iteration, setIteration] = useState<string>(BACKLOG); // selected sprint/cycle for scrum
  const [showNew, setShowNew] = useState(false);

  const isScrum = board?.methodology === 'scrum';

  const fetchBoard = useCallback(async () => {
    if (!orgId) return;
    try {
      const { board } = await api.getBoard(orgId, boardId);
      setBoard(board);
      setError(null);
    } catch (err) {
      const msg = err instanceof Error ? err.message : 'Failed to load board';
      // Surface a clean error state instead of an indefinite "Loading…": when the
      // board fetch throws, fetchTickets never runs (it needs a board), so nothing
      // else would clear `loading`.
      setError(msg);
      setLoading(false);
      toast.error(msg);
    }
  }, [orgId, boardId]);

  const fetchTickets = useCallback(async () => {
    if (!orgId || !board) return;
    try {
      // d4a8fd52 (c): a board surfaces its PROJECT's tickets as cards (per marcus —
      // "board view queries cards by board.project_id"). An org-level board (no
      // project) falls back to its own queue. Tickets with no stage land in the
      // "Unassigned" column.
      const opts: { projectId?: string; queueId?: string; iterationId?: string } =
        board.project_id ? { projectId: board.project_id } : { queueId: boardId };
      if (isScrum && iteration !== BACKLOG) opts.iterationId = iteration;
      const { tickets } = await api.listTickets(orgId, opts);
      // For scrum backlog view, show only tickets with no iteration.
      const filtered = isScrum && iteration === BACKLOG ? tickets.filter((t) => !t.iteration_id) : tickets;
      setTickets(filtered);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load tickets');
    } finally {
      setLoading(false);
    }
  }, [orgId, boardId, board, isScrum, iteration]);

  useEffect(() => {
    if (orgId) fetchBoard();
    else if (!orgLoading) setLoading(false);
  }, [fetchBoard, orgId, orgLoading]);

  useEffect(() => {
    if (orgId && board) fetchTickets();
  }, [fetchTickets, orgId, board]);

  const stages = useMemo(() => board?.stages ?? [], [board]);

  const byStage = useMemo(() => {
    const map = new Map<string, Ticket[]>();
    map.set(NO_STAGE, []);
    for (const s of stages) map.set(s.id, []);
    for (const t of tickets) {
      const key = t.stage_id && map.has(t.stage_id) ? t.stage_id : NO_STAGE;
      map.get(key)!.push(t);
    }
    return map;
  }, [stages, tickets]);

  async function moveTicket(t: Ticket, stageId: string) {
    if (!orgId) return;
    try {
      await api.updateTicket(orgId, t.id, { stage_id: stageId === NO_STAGE ? null : stageId });
      fetchTickets();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to move');
    }
  }

  async function addSprint() {
    if (!orgId || !board) return;
    const seq = (board.iterations?.length ?? 0) + 1;
    try {
      const { iteration } = await api.addBoardIteration(orgId, board.id, { name: `Sprint ${seq}`, sequence: seq, status: 'planned' });
      toast.success(`${iteration.name} created`);
      await fetchBoard();
      setIteration(iteration.id);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to add sprint');
    }
  }

  const noStageCol = byStage.get(NO_STAGE) ?? [];
  const showNoStage = noStageCol.length > 0;

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">{board?.name ?? 'Board'}</h1>
          {board && (
            <span className="scope-chip">
              {titleCase(String(board.methodology))} board · {board.scope === 'project' ? 'Project' : 'Org-level'}
            </span>
          )}
        </div>
        <p className="sg-page-intro">
          <Link href={`/app/${slug}/boards`} className="sg-link">
            ← All boards
          </Link>
        </p>

        {isScrum && board && (
          <div className="board-toolbar">
            <label htmlFor="sprint-sel">Iteration:</label>
            <select id="sprint-sel" value={iteration} onChange={(e) => setIteration(e.target.value)}>
              <option value={BACKLOG}>Backlog</option>
              {(board.iterations ?? []).map((it: BoardIteration) => (
                <option key={it.id} value={it.id}>
                  {it.name} ({it.status})
                </option>
              ))}
            </select>
            <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={addSprint}>
              + Sprint
            </button>
          </div>
        )}

        {error ? (
          <div className="projects-empty">
            <p className="projects-empty__text">Couldn’t load this board: {error}</p>
            <button className="sg-btn sg-btn--outline" onClick={() => { setError(null); setLoading(true); fetchBoard(); }}>
              Retry
            </button>
          </div>
        ) : loading || !board ? (
          <p className="sg-page-intro">Loading…</p>
        ) : (
          <div className="board">
            {showNoStage && (
              <BoardColumn name="Unassigned" tickets={noStageCol} stages={stages} currentStageId={NO_STAGE} onMove={moveTicket} />
            )}
            {stages.map((s) => (
              <BoardColumn
                key={s.id}
                name={s.name}
                wip={s.wip_limit ?? undefined}
                tickets={byStage.get(s.id) ?? []}
                stages={stages}
                currentStageId={s.id}
                onMove={moveTicket}
              />
            ))}
          </div>
        )}
      </main>

      {showNew && orgId && board && (
        <NewTicketModal
          orgId={orgId}
          board={board}
          iterationId={isScrum && iteration !== BACKLOG ? iteration : null}
          onClose={() => setShowNew(false)}
          onSaved={() => {
            setShowNew(false);
            fetchTickets();
          }}
        />
      )}

      {board && (
        <button className="fab" onClick={() => setShowNew(true)} aria-label="New ticket" title="New ticket">
          +
        </button>
      )}
    </div>
  );
}

function BoardColumn({
  name,
  wip,
  tickets,
  stages,
  currentStageId,
  onMove,
}: {
  name: string;
  wip?: number;
  tickets: Ticket[];
  stages: { id: string; name: string }[];
  currentStageId: string;
  onMove: (t: Ticket, stageId: string) => void;
}) {
  const over = wip != null && tickets.length > wip;
  return (
    <div className="board__col">
      <div className="board__col-head">
        <span className="board__col-name">{name}</span>
        <span className={`board__col-count${over ? ' board__col-count--over' : ''}`}>
          {tickets.length}
          {wip != null ? ` / ${wip}` : ''}
        </span>
      </div>
      <div className="board__col-body">
        {tickets.map((t) => (
          <div key={t.id} className="board__card">
            <div className="board__card-title">{t.title}</div>
            <div className="board__card-meta">
              <span className="board__card-type">{t.ticket_type}</span>
              {t.priority && <span className="board__card-prio">{t.priority}</span>}
            </div>
            <select
              className="board__card-move"
              value={currentStageId}
              onChange={(e) => onMove(t, e.target.value)}
              aria-label="Move ticket"
            >
              {stages.map((s) => (
                <option key={s.id} value={s.id}>
                  → {s.name}
                </option>
              ))}
            </select>
          </div>
        ))}
        {tickets.length === 0 && <div className="board__col-empty">—</div>}
      </div>
    </div>
  );
}
