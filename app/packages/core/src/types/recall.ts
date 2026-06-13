import type { VADVector } from "./emotion.js";
import type { EdgeType } from "./association.js";
import type { MemoryEntry } from "./memory.js";
import { z } from "zod";

export type RecallMode = "active" | "tangential";

export interface RecallRequest {
  query: string;
  mode: RecallMode;
  maxResults: number;
  emotionalFilter?: {
    matchCurrentMood: boolean;
    moodOverride?: Partial<VADVector>;
  };
  contextualFilter?: {
    domain?: string;
    timeOfDay?: string;
    season?: string;
    collaborators?: string[];
  };
  traversal?: {
    maxDepth: number;
    minEdgeWeight: number;
    edgeTypes?: EdgeType[];
  };
  requesterId: string;
  compartment?: string;
}

export const RecallRequestSchema = z.object({
  query: z.string().min(1),
  mode: z.enum(["active", "tangential"]).default("active"),
  maxResults: z.number().int().min(1).max(50).default(10),
  emotionalFilter: z.object({
    matchCurrentMood: z.boolean(),
    moodOverride: z.object({
      valence: z.number().min(-1).max(1),
      arousal: z.number().min(0).max(1),
      dominance: z.number().min(0).max(1),
    }).partial().optional(),
  }).optional(),
  contextualFilter: z.object({
    domain: z.string().optional(),
    timeOfDay: z.string().optional(),
    season: z.string().optional(),
    collaborators: z.array(z.string()).optional(),
  }).optional(),
  traversal: z.object({
    maxDepth: z.number().int().min(1).max(5).default(3),
    minEdgeWeight: z.number().min(0).max(1).default(0.2),
    edgeTypes: z.array(z.enum(["semantic", "emotional", "temporal", "causal", "co-occurrence", "synthetic"])).optional(),
  }).optional(),
  requesterId: z.string(),
  compartment: z.string().optional(),
});

export interface ScoredMemory {
  memory: MemoryEntry;
  relevanceScore: number;
  emotionalResonance: number;
  retrievalPath: string[];
  distanceFromQuery: number;
}

export interface RecallResult {
  mode: RecallMode;
  query: string;
  totalCandidates: number;
  results: ScoredMemory[];
  durationMs: number;
  hotIndexHit: boolean;
}
