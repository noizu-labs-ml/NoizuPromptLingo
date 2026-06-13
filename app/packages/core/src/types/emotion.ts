import { z } from "zod";

export interface VADVector {
  valence: number;   // -1.0 to 1.0
  arousal: number;   //  0.0 to 1.0
  dominance: number; //  0.0 to 1.0
}

export const VADVectorSchema = z.object({
  valence: z.number().min(-1).max(1),
  arousal: z.number().min(0).max(1),
  dominance: z.number().min(0).max(1),
});

export interface HormonalState {
  cortisol: number;
  dopamine: number;
  oxytocin: number;
  serotonin: number;
}

export const HormonalStateSchema = z.object({
  cortisol: z.number().min(0).max(1),
  dopamine: z.number().min(0).max(1),
  oxytocin: z.number().min(0).max(1),
  serotonin: z.number().min(0).max(1),
});

export type ConfidenceLevel = "high" | "medium" | "low";

export interface EmotionalMetadata {
  mood: VADVector;
  hormones: HormonalState;
  frustrationIndex: number;
  confidence: ConfidenceLevel;
  schemaVersion: number;
}

export const EmotionalMetadataSchema = z.object({
  mood: VADVectorSchema,
  hormones: HormonalStateSchema,
  frustrationIndex: z.number().min(0).max(1),
  confidence: z.enum(["high", "medium", "low"]),
  schemaVersion: z.number().int().positive(),
});

export const NEUTRAL_EMOTIONAL_STATE: EmotionalMetadata = {
  mood: { valence: 0.0, arousal: 0.3, dominance: 0.5 },
  hormones: { cortisol: 0.2, dopamine: 0.3, oxytocin: 0.3, serotonin: 0.5 },
  frustrationIndex: 0.0,
  confidence: "low",
  schemaVersion: 1,
};
