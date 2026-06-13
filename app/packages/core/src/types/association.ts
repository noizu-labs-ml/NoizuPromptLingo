import { z } from "zod";

export type EdgeType = "semantic" | "emotional" | "temporal" | "causal" | "co-occurrence" | "synthetic";

export interface AssociationEdge {
  id: string;
  sourceMemoryId: string;
  targetMemoryId: string;
  weight: number;
  edgeType: EdgeType;
  createdAt: Date;
  updatedAt: Date;
  createdBy: string;
  reinforcementCount: number;
  denforcementCount: number;
  metadata: {
    reason: string;
    emotionalSimilarity: number;
    temporalProximity: number;
  };
}

export const AssociationEdgeSchema = z.object({
  sourceMemoryId: z.string().uuid(),
  targetMemoryId: z.string().uuid(),
  weight: z.number().min(0).max(1),
  edgeType: z.enum(["semantic", "emotional", "temporal", "causal", "co-occurrence", "synthetic"]),
  createdBy: z.string(),
  metadata: z.object({
    reason: z.string(),
    emotionalSimilarity: z.number().min(0).max(1),
    temporalProximity: z.number().min(0).max(1),
  }),
});
