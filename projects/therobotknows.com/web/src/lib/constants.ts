export const ENTRY_TYPES = [
  "character",
  "location",
  "event",
  "faction",
  "object",
  "concept",
  "rule",
] as const;

export type EntryType = (typeof ENTRY_TYPES)[number];

export const ENTRY_TYPE_LABELS: Record<EntryType, string> = {
  character: "Character",
  location: "Location",
  event: "Event",
  faction: "Faction",
  object: "Object",
  concept: "Concept",
  rule: "Rule",
};

export const ENTRY_TYPE_ICONS: Record<EntryType, string> = {
  character: "User",
  location: "MapPin",
  event: "Swords",
  faction: "Landmark",
  object: "Gem",
  concept: "Lightbulb",
  rule: "ScrollText",
};

export type EntryStatus = "canon" | "generated";

export type FlagSeverity = "error" | "warning" | "suggestion";

export const FLAG_SEVERITY_LABELS: Record<FlagSeverity, string> = {
  error: "Contradiction",
  warning: "Possible Conflict",
  suggestion: "Suggestion",
};
