import { z } from "zod";
import type { EmotionalMetadata } from "./emotion.js";
import type { ContextualMetadata } from "./context.js";
import { EmotionalMetadataSchema } from "./emotion.js";
import { ContextualMetadataSchema } from "./context.js";

export type ContentType = "episodic" | "semantic" | "procedural";
export type LifecycleState = "active" | "consolidating" | "archived" | "quarantined" | "pruned";
export type Classification = "open" | "restricted" | "sealed";

export interface MemoryLifecycle {
  state: LifecycleState;
  decayWeight: number;
  lastRecalledAt: Date | null;
  recallCount: number;
  reinforcementCount: number;
  denforcementCount: number;
  consolidationIds: string[];
  prunedAt: Date | null;
}

export interface MemoryEntry {
  id: string;
  version: number;
  createdAt: Date;
  updatedAt: Date;
  sourceAgent: string;
  content: string;
  contentType: ContentType;
  summary: string;
  embedding: number[];
  emotionalMetadata: EmotionalMetadata;
  contextualMetadata: ContextualMetadata;
  lifecycle: MemoryLifecycle;
  compartment: string;
  classification: Classification;
  ownerAgent: string;
}

export const MemoryWriteRequestSchema = z.object({
  content: z.string().min(1).max(10000),
  contentType: z.enum(["episodic", "semantic", "procedural"]).default("episodic"),
  summary: z.string().max(500).optional(),
  emotionalMetadata: EmotionalMetadataSchema.optional(),
  contextualMetadata: ContextualMetadataSchema.optional(),
  compartment: z.string().default("default"),
  classification: z.enum(["open", "restricted", "sealed"]).default("open"),
  sourceAgent: z.string().default("external"),
});

export type MemoryWriteRequest = z.infer<typeof MemoryWriteRequestSchema>;
