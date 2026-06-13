import Link from "next/link";
import type { Connection, Entry } from "@/types/entry";
import { EntryTypeIcon } from "./entry-type-icon";

interface EntryConnectionsProps {
  connections: Connection[];
  entriesById: Record<string, Entry>;
  universeId: string;
  currentEntryId: string;
}

export function EntryConnections({
  connections,
  entriesById,
  universeId,
  currentEntryId,
}: EntryConnectionsProps) {
  if (connections.length === 0) {
    return (
      <p className="font-sans text-[14px] text-ink-tertiary italic">
        No connections recorded.
      </p>
    );
  }

  return (
    <ul className="space-y-3">
      {connections.map((conn) => {
        // The "other" entry is whichever end isn't the current entry
        const otherId =
          conn.sourceId === currentEntryId ? conn.targetId : conn.sourceId;
        const other = entriesById[otherId];

        if (!other) return null;

        return (
          <li key={conn.id} className="flex items-start gap-3">
            {/* Arrow glyph */}
            <span className="font-mono text-[12px] text-ink-tertiary mt-[3px] flex-shrink-0 select-none">
              →
            </span>

            <div className="flex items-start gap-2 min-w-0">
              {/* Type icon */}
              <span className="mt-[2px] flex-shrink-0">
                <EntryTypeIcon type={other.type} size={15} />
              </span>

              {/* Entry name (link) + relationship label */}
              <div className="min-w-0">
                <Link
                  href={`/${universeId}/entries/${other.id}`}
                  className="font-serif text-[16px] text-link hover:text-link-hover transition-colors duration-200 leading-snug"
                >
                  {other.title}
                </Link>
                <span className="font-sans text-[13px] text-ink-tertiary ml-2">
                  — {conn.relationship}
                </span>
              </div>
            </div>
          </li>
        );
      })}
    </ul>
  );
}
