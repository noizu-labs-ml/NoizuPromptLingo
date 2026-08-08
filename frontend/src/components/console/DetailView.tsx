'use client';

// DetailView — config-driven console detail primitive (ticket 0f8453f5, diego-frontend).
// Renders a descriptor's detail.sections (field grid) + detail.related as embedded
// read-only mini DataTables, with a back-with-state affordance and an Edit entry.
// a11y: a labelled <article>, section <h2>s, a real back button, and the same
// reserved focus channel as the rest of the console.
import type { ReactNode } from 'react';
import type { ConsoleDescriptor, ConsoleContext, DetailFieldDef } from '@/lib/console/types';
import { renderField } from '@/lib/console/render-hints';
import { getDescriptor } from '@/lib/console/registry';
import { DataTable } from './DataTable';

export interface DetailViewProps<T, TInput> {
  descriptor: ConsoleDescriptor<T, TInput>;
  row: T;
  ctx: ConsoleContext;
  /** Back-with-state: the page owns history/scroll restoration. */
  onBack?: () => void;
  /** Open the edit form for this row (omit when not editable). */
  onEdit?: (row: T) => void;
}

export function DetailView<T, TInput>({ descriptor, row, ctx, onBack, onEdit }: DetailViewProps<T, TInput>) {
  const { detail, labels, columns, idKey = 'id' } = descriptor;
  const r = row as Record<string, unknown>;

  // Title = the primary column's value (name/title), falling back to the id.
  const primaryKey = columns.find((c) => c.primary)?.key ?? 'name';
  const title = String(r[primaryKey] ?? r[idKey] ?? labels.singular);

  function field(f: DetailFieldDef<T>): ReactNode {
    return renderField(f.render, f.key, row);
  }

  return (
    <article className="console-detail" aria-label={`${labels.singular} detail`}>
      <header className="console-detail__header">
        {onBack && (
          <button type="button" className="sg-link console-detail__back" onClick={onBack}>
            ← {labels.plural}
          </button>
        )}
        <div className="console-detail__title-row">
          <h1 className="sg-page-title">{title}</h1>
          {descriptor.api.update && onEdit && (
            <button type="button" className="sg-btn" onClick={() => onEdit(row)}>
              Edit
            </button>
          )}
        </div>
      </header>

      {detail.sections.map((section) => (
        <section key={section.title} className="console-detail__section">
          <h2 className="console-detail__section-title">{section.title}</h2>
          <dl className="console-detail__fields">
            {section.fields.map((f) => (
              <div key={f.key} className={`console-detail__field${f.span ? ' console-detail__field--span' : ''}`}>
                <dt>{f.label}</dt>
                <dd>{field(f)}</dd>
              </div>
            ))}
          </dl>
        </section>
      ))}

      {detail.related?.map((rel) => {
        const relDescriptor = getDescriptor(rel.domain);
        return (
          <section key={rel.title} className="console-detail__section">
            <h2 className="console-detail__section-title">{rel.title}</h2>
            {relDescriptor ? (
              <DataTable
                descriptor={relDescriptor}
                ctx={ctx}
                embedded
                scope={rel.query(r)}
                density="compact"
              />
            ) : (
              <p className="console-muted">No “{rel.domain}” view registered yet.</p>
            )}
          </section>
        );
      })}
    </article>
  );
}
