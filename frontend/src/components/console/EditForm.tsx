'use client';

// EditForm — config-driven console create/edit primitive (ticket 0f8453f5, diego).
// Renders a descriptor's edit.sections through a field-type registry with inline
// validation, a dirty-guard on cancel, and KEEP-INPUT-ON-FAILURE (the chat composer
// pattern: a failed submit keeps every value + surfaces the error, never clears).
// a11y: every field is labelled, required fields announce, errors wire via
// aria-invalid + aria-describedby, submit error is role=alert, reserved focus ring.
import { useId, useMemo, useState } from 'react';
import type { ConsoleDescriptor, ConsoleContext, EditFieldDef, FacetOption } from '@/lib/console/types';

export interface EditFormProps<T, TInput> {
  descriptor: ConsoleDescriptor<T, TInput>;
  ctx: ConsoleContext;
  mode: 'create' | 'edit';
  /** Edit mode: the current row's values. Create: omit (fields start empty). */
  initial?: Record<string, unknown>;
  /** Resolved options for `dynamic` select/reference fields, keyed by field key. */
  referenceOptions?: Record<string, FacetOption[]>;
  /** The page wires this to descriptor.api.create/update + a refresh. May throw to
   *  trigger keep-input-on-failure. */
  onSubmit: (values: Record<string, unknown>) => Promise<void>;
  onCancel: () => void;
}

function slugify(s: string): string {
  return s
    .toLowerCase()
    .normalize('NFKD')
    .replace(/[̀-ͯ]/g, '') // strip combining marks (diacritic fold)
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

function defaultFor(f: EditFieldDef): unknown {
  if (f.type === 'toggle') return false;
  if (f.type === 'multiselect') return [];
  return '';
}

export function EditForm<T, TInput>({
  descriptor,
  mode,
  initial,
  referenceOptions,
  onSubmit,
  onCancel,
}: EditFormProps<T, TInput>) {
  const fields = useMemo(() => descriptor.edit.sections.flatMap((s) => s.fields), [descriptor.edit.sections]);

  const initialValues = useMemo(() => {
    const v: Record<string, unknown> = {};
    for (const f of fields) v[f.key] = initial?.[f.key] ?? defaultFor(f);
    return v;
  }, [fields, initial]);

  const [values, setValues] = useState<Record<string, unknown>>(initialValues);
  const [touched, setTouched] = useState<Set<string>>(new Set());
  const [submitAttempted, setSubmitAttempted] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);
  // slug fields auto-derive from their source until the user edits the slug directly.
  const [slugDirty, setSlugDirty] = useState<Set<string>>(new Set());
  const baseId = useId();

  const dirty = useMemo(() => JSON.stringify(values) !== JSON.stringify(initialValues), [values, initialValues]);

  function errorFor(f: EditFieldDef): string | null {
    if (!f.required) return null;
    const v = values[f.key];
    const empty = v == null || v === '' || (Array.isArray(v) && v.length === 0);
    return empty ? `${f.label} is required` : null;
  }
  const firstError = fields.map(errorFor).find(Boolean) ?? null;

  function setValue(f: EditFieldDef, value: unknown) {
    setValues((prev) => {
      const next = { ...prev, [f.key]: value };
      // Auto-derive any slug field that sources from THIS field (unless slug edited).
      for (const sf of fields) {
        if (sf.type === 'slug' && sf.derivesFrom === f.key && !slugDirty.has(sf.key)) {
          next[sf.key] = slugify(String(value ?? ''));
        }
      }
      return next;
    });
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSubmitAttempted(true);
    if (firstError) return; // inline errors now visible
    setSubmitting(true);
    setSubmitError(null);
    try {
      await onSubmit(values);
      // success: the page closes/navigates. Keep values otherwise.
    } catch (err) {
      // keep-input-on-failure: values stay, surface the error.
      setSubmitError(err instanceof Error ? err.message : 'Save failed');
    } finally {
      setSubmitting(false);
    }
  }

  function handleCancel() {
    if (dirty && !window.confirm('Discard unsaved changes?')) return;
    onCancel();
  }

  function fieldId(key: string) {
    return `${baseId}-${key}`;
  }

  function options(f: EditFieldDef): FacetOption[] {
    return (f.dynamic ? referenceOptions?.[f.key] : f.options) ?? [];
  }

  function renderControl(f: EditFieldDef) {
    const id = fieldId(f.key);
    const err = (touched.has(f.key) || submitAttempted) && errorFor(f);
    const invalid = err ? true : undefined;
    const describedBy = err ? `${id}-err` : f.hint ? `${id}-hint` : undefined;
    const common = {
      id,
      'aria-invalid': invalid,
      'aria-describedby': describedBy,
      disabled: f.readOnly || submitting,
      onBlur: () => setTouched((t) => new Set(t).add(f.key)),
    } as const;

    switch (f.type) {
      case 'textarea':
        return (
          <textarea
            {...common}
            className="console-field__input"
            rows={3}
            value={String(values[f.key] ?? '')}
            onChange={(e) => setValue(f, e.target.value)}
          />
        );
      case 'select':
      case 'reference':
        return (
          <select
            {...common}
            className="console-field__input"
            value={String(values[f.key] ?? '')}
            onChange={(e) => setValue(f, e.target.value)}
          >
            <option value="">{f.required ? `Select ${f.label.toLowerCase()}…` : '—'}</option>
            {options(f).map((o) => (
              <option key={o.value} value={o.value}>
                {o.label}
              </option>
            ))}
          </select>
        );
      case 'multiselect': {
        const arr = Array.isArray(values[f.key]) ? (values[f.key] as string[]) : [];
        return (
          <div className="console-field__checks" role="group" aria-labelledby={`${id}-label`}>
            {options(f).map((o) => (
              <label key={o.value} className="console-field__check">
                <input
                  type="checkbox"
                  checked={arr.includes(o.value)}
                  disabled={f.readOnly || submitting}
                  onChange={(e) =>
                    setValue(f, e.target.checked ? [...arr, o.value] : arr.filter((x) => x !== o.value))
                  }
                />
                {o.label}
              </label>
            ))}
          </div>
        );
      }
      case 'toggle':
        return (
          <input
            {...common}
            type="checkbox"
            className="console-field__toggle"
            checked={Boolean(values[f.key])}
            onChange={(e) => setValue(f, e.target.checked)}
          />
        );
      case 'date':
        return (
          <input
            {...common}
            type="date"
            className="console-field__input"
            value={String(values[f.key] ?? '')}
            onChange={(e) => setValue(f, e.target.value)}
          />
        );
      case 'number':
        return (
          <input
            {...common}
            type="number"
            className="console-field__input"
            value={String(values[f.key] ?? '')}
            onChange={(e) => setValue(f, e.target.value === '' ? '' : Number(e.target.value))}
          />
        );
      case 'slug':
        return (
          <input
            {...common}
            className="console-field__input console-field__input--mono"
            value={String(values[f.key] ?? '')}
            onChange={(e) => {
              setSlugDirty((s) => new Set(s).add(f.key));
              setValues((prev) => ({ ...prev, [f.key]: e.target.value }));
            }}
          />
        );
      case 'text':
      default:
        return (
          <input
            {...common}
            className="console-field__input"
            value={String(values[f.key] ?? '')}
            onChange={(e) => setValue(f, e.target.value)}
          />
        );
    }
  }

  return (
    <form className="console-form" onSubmit={handleSubmit} noValidate>
      {submitError && (
        <p className="console-form__error" role="alert">
          {submitError}
        </p>
      )}
      {descriptor.edit.sections.map((section) => (
        <fieldset key={section.title} className="console-form__section" disabled={submitting}>
          <legend className="console-form__legend">{section.title}</legend>
          {section.fields.map((f) => {
            const id = fieldId(f.key);
            const err = (touched.has(f.key) || submitAttempted) && errorFor(f);
            return (
              <div key={f.key} className="console-field">
                <label id={`${id}-label`} htmlFor={id} className="console-field__label">
                  {f.label}
                  {f.required && <span aria-hidden className="console-field__req"> *</span>}
                </label>
                {renderControl(f)}
                {f.hint && !err && (
                  <p id={`${id}-hint`} className="console-field__hint">
                    {f.hint}
                  </p>
                )}
                {err && (
                  <p id={`${id}-err`} className="console-field__err" role="alert">
                    {err}
                  </p>
                )}
              </div>
            );
          })}
        </fieldset>
      ))}
      <div className="console-form__actions">
        <button type="button" className="sg-btn" onClick={handleCancel} disabled={submitting}>
          Cancel
        </button>
        <button type="submit" className="sg-btn sg-btn--black" disabled={submitting}>
          {submitting ? 'Saving…' : mode === 'create' ? `Create ${descriptor.labels.singular}` : 'Save changes'}
        </button>
      </div>
    </form>
  );
}
