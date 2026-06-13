import type { FlagSeverity } from "@/lib/constants";

export interface Flag {
  id: string;
  severity: FlagSeverity;
  title: string;
  detail: string;
  entryIds: string[];
  resolved: boolean;
}
