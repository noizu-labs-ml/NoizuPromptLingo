import type { QueueBoard, QueueBoardData, QueueStage, QueueTicket } from './types.js';
export interface BoardColumn {
    stage: QueueStage | null;
    tickets: QueueTicket[];
}
export interface BoardGroup {
    board: QueueBoard;
    columns: BoardColumn[];
    totalCount: number;
}
export declare function ticketTags(ticket: QueueTicket): string[];
export declare function groupBoards(data: QueueBoardData, boardId?: string): BoardGroup[];
export declare function statusKind(status?: string | null): 'done' | 'active' | 'blocked' | 'open';
export declare function priorityKind(p?: string | null): 'high' | 'medium' | 'low' | null;
export declare function initials(name: string): string;
