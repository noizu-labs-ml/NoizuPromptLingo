'use client';

// ConsoleDetailPage — the detail/edit analog of DataTable (ticket 0f8453f5, diego).
// One shared wrapper so each domain's app/[orgId]/<domain>/[id]/page.tsx is a THIN
// instantiation (descriptor + ctx + id), not a bespoke page (priya seq521 — same
// anti-divergence discipline as the canonical descriptor type). Fetches the entity,
// renders DetailView, toggles to EditForm on edit, and saves via descriptor.api.update
// (which a domain can adapt — e.g. artifacts' edit = append-revision). back-with-state
// via the router so the list's scroll/filter survive a round-trip.
import { useState, useEffect, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import type { ConsoleContext, FacetOption } from '@/lib/console/types';
import { getDescriptor, type AnyDescriptor } from '@/lib/console/registry';
import { DetailView } from './DetailView';
import { EditForm } from './EditForm';

export interface ConsoleDetailPageProps {
  ctx: ConsoleContext;
  id: string;
  /** The domain's descriptor; if omitted, resolved from `domain` via registry.ts. */
  descriptor?: AnyDescriptor;
  /** Domain key — used to resolve the descriptor when `descriptor` isn't passed. */
  domain?: string;
  /** Resolved options for EditForm's dynamic select/reference fields. */
  referenceOptions?: Record<string, FacetOption[]>;
  /** Back affordance; defaults to router.back() (preserves list state). */
  onBack?: () => void;
  /** Start in edit mode (e.g. an /edit route). Default 'view'. */
  initialMode?: 'view' | 'edit';
}

export function ConsoleDetailPage({
  ctx,
  id,
  descriptor,
  domain,
  referenceOptions,
  onBack,
  initialMode = 'view',
}: ConsoleDetailPageProps) {
  const router = useRouter();
  const d = descriptor ?? (domain ? getDescriptor(domain) : undefined);

  const [row, setRow] = useState<Record<string, unknown> | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [mode, setMode] = useState<'view' | 'edit'>(initialMode);

  const fetchRow = useCallback(() => {
    if (!d) return;
    setLoading(true);
    setError(null);
    d.api
      .get(ctx.orgId, id)
      .then((r: Record<string, unknown>) => setRow(r))
      .catch((e: unknown) => setError(e instanceof Error ? e.message : 'Failed to load'))
      .finally(() => setLoading(false));
  }, [d, ctx.orgId, id]);

  useEffect(() => {
    fetchRow();
  }, [fetchRow]);

  const back = onBack ?? (() => router.back());

  if (!d) return <p className="console-state console-state--error" role="alert">Unknown domain “{domain}”.</p>;
  if (loading) return <p className="console-state" role="status">Loading {d.labels.singular.toLowerCase()}…</p>;
  if (error || !row)
    return (
      <div className="console-state console-state--error" role="alert">
        {error ?? `${d.labels.singular} not found.`}
        <button type="button" className="sg-btn" onClick={fetchRow}>
          Retry
        </button>
      </div>
    );

  if (mode === 'edit') {
    return (
      <EditForm
        descriptor={d}
        ctx={ctx}
        mode="edit"
        initial={row}
        referenceOptions={referenceOptions}
        onSubmit={async (values) => {
          if (!d.api.update) throw new Error(`${d.labels.singular} is not editable`);
          // update may throw → EditForm keeps the input + surfaces the error.
          await d.api.update(ctx.orgId, id, values);
          setMode('view');
          // refresh in the background; a refetch error must not look like a save error.
          d.api.get(ctx.orgId, id).then(setRow).catch(() => {});
        }}
        onCancel={() => setMode('view')}
      />
    );
  }

  return (
    <DetailView
      descriptor={d}
      row={row}
      ctx={ctx}
      onBack={back}
      onEdit={d.api.update ? () => setMode('edit') : undefined}
    />
  );
}
