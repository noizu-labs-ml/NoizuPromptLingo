import { EntryCard } from "@/components/entries/entry-card";
import { EntryFilters } from "@/components/entries/entry-filters";
import { MOCK_ENTRIES } from "@/lib/mock-data";

interface EntriesPageProps {
  params: Promise<{ universeId: string }>;
}

export default async function EntriesPage({ params }: EntriesPageProps) {
  const { universeId } = await params;

  // In production: fetch entries from the database filtered by universeId.
  // For now, all mock entries belong to this universe.
  const entries = MOCK_ENTRIES;
  const entryCount = entries.length;

  return (
    <div className="min-h-screen bg-page">
      <div className="max-w-[1100px] mx-auto px-6 py-10 sm:px-10">

        {/* Page header */}
        <div className="flex items-baseline justify-between mb-8">
          <div>
            <h1 className="font-serif text-[32px] font-bold leading-tight text-ink">
              Entries
            </h1>
            <p className="font-mono text-[12px] text-ink-tertiary mt-1 tracking-[0.02em]">
              {entryCount} {entryCount === 1 ? "entry" : "entries"}
            </p>
          </div>

          {/* Placeholder for future "New Entry" button */}
          <button
            className="inline-flex items-center gap-1.5 font-sans text-[14px] font-semibold
                       text-white bg-accent hover:bg-accent-hover transition-colors duration-200
                       px-4 py-2 rounded-sm"
          >
            <span className="text-[16px] leading-none">+</span>
            New Entry
          </button>
        </div>

        {/* Filter bar */}
        <div className="mb-8">
          <EntryFilters />
        </div>

        {/* Entry grid */}
        {entries.length > 0 ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
            {entries.map((entry) => (
              <EntryCard key={entry.id} entry={entry} universeId={universeId} />
            ))}
          </div>
        ) : (
          <div className="text-center py-24">
            <p className="font-serif text-[20px] text-ink-secondary mb-2">
              No entries yet.
            </p>
            <p className="font-sans text-[14px] text-ink-tertiary">
              Create your first entry to begin building this universe.
            </p>
          </div>
        )}

        {/* Footer metadata bar */}
        <div className="mt-12 pt-6 border-t border-rule-subtle">
          <div className="flex flex-wrap gap-4 font-mono text-[11px] text-ink-tertiary">
            <span>
              {entries.filter((e) => e.status === "canon").length} canon
            </span>
            <span className="opacity-40 select-none">·</span>
            <span>
              {entries.filter((e) => e.status === "generated").length} generated
            </span>
            <span className="opacity-40 select-none">·</span>
            <span>
              {entries.reduce((sum, e) => sum + e.connectionIds.length, 0)}{" "}
              connections
            </span>
          </div>
        </div>
      </div>
    </div>
  );
}
