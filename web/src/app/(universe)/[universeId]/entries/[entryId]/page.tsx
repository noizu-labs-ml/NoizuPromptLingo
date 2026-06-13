import { notFound } from "next/navigation";
import { EntryDetail } from "@/components/entries/entry-detail";
import {
  MOCK_ENTRIES,
  ENTRIES_BY_ID,
  getConnectionsForEntry,
  KAEL_FLAGS,
} from "@/lib/mock-data";

interface EntryDetailPageProps {
  params: Promise<{ universeId: string; entryId: string }>;
}

export function generateStaticParams() {
  // All mock entries currently belong to ashward-chronicles
  return MOCK_ENTRIES.map((e) => ({
    universeId: "ashward-chronicles",
    entryId: e.id,
  }));
}

export default async function EntryDetailPage({ params }: EntryDetailPageProps) {
  const { universeId, entryId } = await params;

  // In production: fetch entry + connections from DB, scoped to universeId.
  const entry = ENTRIES_BY_ID[entryId];
  if (!entry) notFound();

  const connections = getConnectionsForEntry(entryId);

  // Flags are entry-specific. In production, fetched alongside the entry.
  const flags = entryId === "kael-ashward" ? KAEL_FLAGS : [];

  return (
    <EntryDetail
      entry={entry}
      connections={connections}
      entriesById={ENTRIES_BY_ID}
      flags={flags}
      universeId={universeId}
    />
  );
}
