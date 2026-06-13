import { z } from "zod";

export interface TemporalContext {
  timeOfDay: "morning" | "afternoon" | "evening" | "night";
  dayOfWeek: string;
  season: "spring" | "summer" | "autumn" | "winter";
  isWeekend: boolean;
}

export const TemporalContextSchema = z.object({
  timeOfDay: z.enum(["morning", "afternoon", "evening", "night"]),
  dayOfWeek: z.string(),
  season: z.enum(["spring", "summer", "autumn", "winter"]),
  isWeekend: z.boolean(),
});

export interface ContextualMetadata {
  collaborators: string[];
  taskDomain: string;
  sessionId: string | null;
  environment: string;
  temporal: TemporalContext;
}

export const ContextualMetadataSchema = z.object({
  collaborators: z.array(z.string()),
  taskDomain: z.string(),
  sessionId: z.string().nullable(),
  environment: z.string(),
  temporal: TemporalContextSchema,
});
