import Link from "next/link";
import { cn } from "@/lib/cn";
import type { Entry } from "@/types/entry";

interface SidebarEntryListProps {
  entries: Entry[];
  universeId: string;
  currentEntryId?: string;
}

export function SidebarEntryList({
  entries,
  universeId,
  currentEntryId,
}: SidebarEntryListProps) {
  if (entries.length === 0) {
    return (
      <p className="px-5 py-3 font-sans text-[13px] text-ink-tertiary italic">
        No entries yet
      </p>
    );
  }

  return (
    <ul className="py-1">
      {entries.map((entry) => {
        const isActive = entry.id === currentEntryId;
        const isCanon = entry.status === "canon";

        return (
          <li key={entry.id}>
            <Link
              href={`/${universeId}/entries/${entry.id}`}
              className={cn(
                "flex items-center gap-2 pl-8 pr-5 py-1.5 font-serif text-[14px] leading-snug transition-colors duration-200",
                isActive ? "text-accent font-semibold" : "text-ink-secondary hover:text-ink"
              )}
            >
              {/* Canon: solid dot · Generated: hollow dot */}
              <span
                title={isCanon ? "Canon" : "Generated"}
                className={cn(
                  "inline-block shrink-0 rounded-full border mt-px",
                  isCanon
                    ? "w-[7px] h-[7px] bg-canon border-canon"
                    : "w-[7px] h-[7px] bg-transparent border-generated"
                )}
              />
              <span className="truncate">{entry.title}</span>
            </Link>
          </li>
        );
      })}
    </ul>
  );
}
