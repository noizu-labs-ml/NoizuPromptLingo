export interface QueueStage {
  id: string;
  slug?: string;
  name: string;
  kind?: string;
  position?: number;
  wip_limit?: number | null;
}

export interface QueueBoard {
  id: string;
  name: string;
  slug?: string | null;
  description?: string | null;
  methodology?: string | null;
  scope?: string;
  stages?: QueueStage[];
}

export interface QueueTicket {
  id: string;
  key?: string | null;
  number?: number | null;
  title: string;
  status?: string | null;
  priority?: string | null;
  assignee?: string | null;
  tags?: string[];
  ticket_type?: string | null;
  queue_id?: string | null;
  stage_id?: string | null;
  updated_at?: string | null;
  custom_fields?: Record<string, unknown> | null;
}

export interface QueueBoardData {
  queues: QueueBoard[];
  items: QueueTicket[];
}

export interface QueueDataQuery {
  signal?: AbortSignal;
}

export type QueueDataProvider = (query?: QueueDataQuery) => Promise<QueueBoardData>;

export interface QueueCardActivateDetail {
  ticket: QueueTicket;
}

export interface QueueLoadErrorDetail {
  error: string;
}

declare global {
  interface HTMLElementEventMap {
    'card-activate': CustomEvent<QueueCardActivateDetail>;
    'queue-load-error': CustomEvent<QueueLoadErrorDetail>;
  }
}
