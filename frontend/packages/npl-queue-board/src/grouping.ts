import type {QueueBoard, QueueBoardData, QueueStage, QueueTicket} from './types.js';

export interface BoardColumn {
  stage: QueueStage | null;
  tickets: QueueTicket[];
}

export interface BoardGroup {
  board: QueueBoard;
  columns: BoardColumn[];
  totalCount: number;
}

export function ticketTags(ticket: QueueTicket): string[] {
  if (Array.isArray(ticket.tags)) {
    return ticket.tags.filter((t): t is string => typeof t === 'string');
  }
  const fromCf = ticket.custom_fields?.['tags'];
  return Array.isArray(fromCf)
    ? fromCf.filter((t): t is string => typeof t === 'string')
    : [];
}

export function groupBoards(data: QueueBoardData, boardId?: string): BoardGroup[] {
  const queues = boardId ? data.queues.filter(b => b.id === boardId) : data.queues;
  return queues.map(board => {
    const stages = [...(board.stages ?? [])].sort(
      (a, b) => (a.position ?? 0) - (b.position ?? 0),
    );
    const items = data.items.filter(t => t.queue_id === board.id);
    const columns: BoardColumn[] = stages.map(stage => ({
      stage,
      tickets: items.filter(t => t.stage_id === stage.id),
    }));
    const stagedIds = new Set(stages.map(s => s.id));
    const unstaged = items.filter(t => !t.stage_id || !stagedIds.has(t.stage_id));
    if (unstaged.length) {
      columns.push({stage: null, tickets: unstaged});
    }
    return {board, columns, totalCount: items.length};
  });
}

export function statusKind(status?: string | null): 'done' | 'active' | 'blocked' | 'open' {
  const s = (status ?? '').toLowerCase();
  if (/done|complete|closed|shipped/.test(s)) return 'done';
  if (/progress|review|active|start/.test(s)) return 'active';
  if (/block|wait|hold/.test(s)) return 'blocked';
  return 'open';
}

export function priorityKind(p?: string | null): 'high' | 'medium' | 'low' | null {
  const s = (p ?? '').toLowerCase();
  if (!s || s === 'none' || s === 'unset') return null;
  if (/high|urgent|critical|hot/.test(s)) return 'high';
  if (/low|minor/.test(s)) return 'low';
  return 'medium';
}

export function initials(name: string): string {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  return ((parts[0]?.[0] ?? '?') + (parts[1]?.[0] ?? '')).toUpperCase();
}
