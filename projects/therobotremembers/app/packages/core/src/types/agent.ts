import type { VADVector, HormonalState } from "./emotion.js";

export interface AgentEvent {
  id: string;
  type: string;
  timestamp: Date;
  sourceAgent: string;
  payload: unknown;
}

export interface AgentAction {
  type: string;
  payload: unknown;
}

export interface EmotionalProfile {
  baselineMood: VADVector;
  baselineHormones: HormonalState;
  description: string;
}

export interface AgentState {
  id: string;
  name: string;
  status: "active" | "idle" | "error";
  lastProcessedEventId: string | null;
  emotionalProfile: EmotionalProfile;
  metrics: Record<string, number>;
}

export interface Agent {
  readonly id: string;
  readonly name: string;
  readonly emotionalProfile: EmotionalProfile;
  process(event: AgentEvent): Promise<AgentAction[]>;
  getState(): AgentState;
  shutdown(): Promise<void>;
}
