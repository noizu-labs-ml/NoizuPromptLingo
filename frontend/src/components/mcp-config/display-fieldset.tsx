'use client';

import { useRef, useState } from 'react';
import { toast } from 'sonner';
import { api, ENDPOINT_IMAGE_TYPES, type McpScopeDisplay } from '@/lib/api';
import { parseMediaRef } from '@/lib/mcp-setup';

/**
 * Alacarte endpoint display editor — the reserved `config.display` key
 * ({image, emoji, color}). Image uploads go through the media domain
 * (presign → S3 PUT → register, via api.uploadEndpointImage) and preview as
 * the same 48px thumb the endpoint lists render; emoji and color are the
 * fallback glyphs when no image is set.
 */
export interface DisplayFieldsetProps {
  value: McpScopeDisplay | null | undefined;
  onChange: (next: McpScopeDisplay | null) => void;
  /** Owning org id — org uploads register "org" visibility so every org
   * member's <img> render resolves; null registers private. */
  ownerOrgId?: string | null;
  disabled?: boolean;
  idPrefix?: string;
}

export default function DisplayFieldset({
  value,
  onChange,
  ownerOrgId = null,
  disabled = false,
  idPrefix = 'display',
}: DisplayFieldsetProps) {
  const fileRef = useRef<HTMLInputElement>(null);
  const [uploading, setUploading] = useState(false);

  const thumb = parseMediaRef(value?.image).thumb;
  const emoji = value?.emoji ?? '';
  const color = value?.color ?? '';
  // input[type=color] only accepts #rrggbb; stored CSS names / #rgb fall back
  // for the picker while the text field keeps the real value.
  const pickerColor = /^#[0-9a-fA-F]{6}$/.test(color) ? color : '#7c3aed';

  function patch(next: Partial<McpScopeDisplay>) {
    const merged: McpScopeDisplay = { ...(value ?? {}), ...next };
    const pruned: McpScopeDisplay = {};
    if (merged.image) pruned.image = merged.image;
    if (merged.emoji) pruned.emoji = merged.emoji;
    if (merged.color) pruned.color = merged.color;
    onChange(Object.keys(pruned).length > 0 ? pruned : null);
  }

  async function onFile(event: React.ChangeEvent<HTMLInputElement>) {
    const file = event.target.files?.[0];
    event.target.value = '';
    if (!file) return;
    setUploading(true);
    try {
      const shortId = await api.uploadEndpointImage(file, { organizationId: ownerOrgId });
      patch({ image: shortId });
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Image upload failed');
    } finally {
      setUploading(false);
    }
  }

  return (
    <div style={{ display: 'grid', gap: 10 }}>
      <div style={{ display: 'flex', gap: 10, alignItems: 'center', flexWrap: 'wrap' }}>
        {thumb ? (
          <img
            src={thumb}
            alt="Endpoint image"
            width={48}
            height={48}
            style={{
              borderRadius: 8,
              objectFit: 'cover',
              border: '1px solid var(--border)',
              flexShrink: 0,
            }}
          />
        ) : (
          <div
            aria-hidden
            style={{
              width: 48,
              height: 48,
              borderRadius: 8,
              border: '1px dashed var(--border)',
              background: color || 'var(--bg-3, #fafafa)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: emoji ? 22 : 16,
              color: color ? '#fff' : 'var(--text-3)',
              flexShrink: 0,
            }}
          >
            {emoji || (value?.image ? '' : '—')}
          </div>
        )}
        <input
          ref={fileRef}
          type="file"
          accept={ENDPOINT_IMAGE_TYPES.join(',')}
          onChange={onFile}
          hidden
        />
        <button
          type="button"
          className="sg-btn sg-btn--outline sg-btn--sm"
          disabled={disabled || uploading}
          onClick={() => fileRef.current?.click()}
        >
          {uploading ? 'Uploading…' : thumb ? 'Replace image' : 'Upload image'}
        </button>
        {thumb ? (
          <button
            type="button"
            className="sg-btn sg-btn--outline sg-btn--sm"
            disabled={disabled || uploading}
            onClick={() => patch({ image: undefined })}
          >
            Remove
          </button>
        ) : null}
      </div>
      <span className="sg-field__hint">
        PNG, JPEG, WebP, or GIF up to 2 MB — shown as a 48px avatar in endpoint lists.
      </span>

      <div style={{ display: 'flex', gap: 16, flexWrap: 'wrap' }}>
        <div className="sg-field" style={{ marginBottom: 0 }}>
          <label htmlFor={`${idPrefix}-emoji`}>Emoji</label>
          <input
            id={`${idPrefix}-emoji`}
            value={emoji}
            maxLength={4}
            placeholder="One emoji"
            disabled={disabled}
            onChange={(e) => patch({ emoji: e.target.value })}
            style={{ width: 110 }}
          />
        </div>

        <div className="sg-field" style={{ marginBottom: 0 }}>
          <label htmlFor={`${idPrefix}-color`}>Color</label>
          <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
            <input
              id={`${idPrefix}-color-picker`}
              type="color"
              value={pickerColor}
              disabled={disabled}
              onChange={(e) => patch({ color: e.target.value })}
              aria-label="Pick a color"
              style={{
                width: 36,
                height: 30,
                padding: 0,
                border: '1px solid var(--border)',
                borderRadius: 6,
                background: 'none',
                cursor: disabled ? 'default' : 'pointer',
              }}
            />
            <input
              className="gh-add-form__input font-mono"
              value={color}
              maxLength={32}
              placeholder="#7c3aed"
              disabled={disabled}
              aria-label="Color hex or CSS name"
              onChange={(e) => patch({ color: e.target.value })}
              style={{ width: 120 }}
            />
          </div>
          <span className="sg-field__hint">Backdrop for the emoji / initial.</span>
        </div>
      </div>
    </div>
  );
}
