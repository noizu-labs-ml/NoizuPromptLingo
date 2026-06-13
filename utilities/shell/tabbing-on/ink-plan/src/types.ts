export type AppPhase =
  | 'idle'
  | 'recording'
  | 'transcribing'
  | 'reviewing_transcript'
  | 'generating_ticket'
  | 'previewing_ticket'
  | 'saving'
  | 'done'
  | 'error';

export type TicketType = 'user-story' | 'bug' | 'task';
export type Priority = 'P0' | 'P1' | 'P2' | 'P3';

export interface TicketMetadata {
  id: string;
  title: string;
  issue_type: TicketType;
  slug: string;
  status: 'draft';
  priority: Priority;
  category: string;
  labels: string[];
  created_at: string;
}

export interface Ticket {
  metadata: TicketMetadata;
  body: string;
}

export interface AppConfig {
  project?: string;
  ticketType?: TicketType;
  apiUrl: string;
  apiKey: string;
  model: string;
  whisperModel: string;
  outputDir?: string;
  noTabbing: boolean;
}

export type AppAction =
  | { type: 'START_RECORDING' }
  | { type: 'STOP_RECORDING'; audioBuffer: Buffer }
  | { type: 'TRANSCRIPTION_COMPLETE'; transcript: string }
  | { type: 'TRANSCRIPT_EDITED'; transcript: string }
  | { type: 'GENERATION_COMPLETE'; ticket: Ticket }
  | { type: 'METADATA_UPDATED'; metadata: Partial<TicketMetadata> }
  | { type: 'SAVE_COMPLETE'; path: string }
  | { type: 'ERROR'; error: string }
  | { type: 'RE_RECORD' }
  | { type: 'NEW_TICKET' }
  | { type: 'CANCEL' };

export interface AppState {
  phase: AppPhase;
  audioBuffer: Buffer | null;
  transcript: string;
  ticket: Ticket | null;
  savedPath: string | null;
  error: string | null;
}
