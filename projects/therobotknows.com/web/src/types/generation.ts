import type { EntryType, EntryStatus } from "@/lib/constants";

export interface Generation {
  id: string;
  prompt: string;
  entryType: EntryType;
  status: "pending" | "complete" | "promoted" | "discarded";
  outputTitle?: string;
  outputBody?: string;
  sourceEntryIds: string[];
  createdAt: string;
}
