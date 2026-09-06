'use client';

import { useEffect, useMemo, useState } from 'react';
import { toast } from 'sonner';
import { api, type McpCustomGroup, type McpCustomScope } from '@/lib/api';
import {
  compactToolsetSpec,
  computeEffectiveTools,
  encodeToolsetParam,
  toolSelectionUrl,
  universeFromCatalog,
  type ToolsetParamSpec,
  type ToolsetParamWhiteEntry,
  type ToolsetUniverseEntry,
} from '@/lib/mcp-setup';

/**
 * Alacarte admin URL builder (WP9): compose a `?t=` tool-selection spec from
 * per-tool Include/Exclude + Visible/Hidden toggles and a default selector,
 * preview the effective toolset live (computeEffectiveTools — the TS mirror
 * of the backend compile), and emit the raw JSON, the base64url token, and
 * the full gateway URL for distribution.
 *
 * `?t=` is read once at MCP initialize (session snapshot): clients must
 * reconnect to pick up a changed URL.
 */

// Preview-side preset registry. Names mirror the backend `@presets` registry
// (core / full / basic_crud); `core` mirrors the backend named-subset policy.
// `full` expands to the endpoint catalog's group list at load time, so only
// unknown presets (e.g. basic_crud) resolve server-side and stay approximate.
const PREVIEW_PRESETS: Record<string, string[]> = {
  core: [
    'Organization_Overview',
    'Organization_Get',
    'Project_Overview',
    'Project_Get',
    'Session_Create',
    'Session_Overview',
    'Session_Manifest',
  ],
};

const DEFAULT_OPTIONS = [
  { value: 'true', label: 'Endpoint default (stored config)' },
  { value: 'basic_crud', label: 'basic_crud preset' },
  { value: 'core', label: 'core preset' },
  { value: 'full', label: 'full preset' },
] as const;

type DefaultMode = (typeof DEFAULT_OPTIONS)[number]['value'];

/**
 * Per-tool builder state — only tools the admin touched appear here.
 * `selection` distinguishes "never touched" from an explicit Exclude (Include
 * toggled off), so a Visible-only tweak never widens into a black-list entry.
 */
interface ToolRowState {
  selection: 'default' | 'included' | 'excluded';
  visible: boolean;
}

function canon(name: string): string {
  return name.replace(/\./g, '_');
}

function buildSpec(rows: Record<string, ToolRowState>, defaultMode: DefaultMode): ToolsetParamSpec {
  const white_list: ToolsetParamWhiteEntry[] = [];
  const black_list: string[] = [];
  const tools: Record<string, { visible?: boolean }> = {};

  for (const [name, row] of Object.entries(rows)) {
    if (row.selection === 'included') {
      white_list.push(row.visible ? name : { name, visible: false });
    } else if (row.selection === 'excluded') {
      black_list.push(name);
    }
    // Visibility for non-included tools rides the (lowest-precedence) tools
    // map; included tools carry the flag on their white-list entry. A disabled
    // (excluded) tool is unlisted anyway, so no flag is needed there.
    if (row.selection === 'default' && !row.visible) {
      tools[canon(name)] = { visible: false };
    }
  }

  return {
    // Kebab-case keys per the approved plan (backend decode mirrors them).
    ...(white_list.length > 0 ? { "white-list": white_list } : {}),
    ...(black_list.length > 0 ? { "black-list": black_list } : {}),
    ...(Object.keys(tools).length > 0 ? { tools } : {}),
    default: defaultMode === 'true' ? true : defaultMode,
  };
}

export interface ToolsetUrlBuilderProps {
  slug: string;
  onClose: () => void;
}

export default function ToolsetUrlBuilder({ slug, onClose }: ToolsetUrlBuilderProps) {
  const [scope, setScope] = useState<McpCustomScope | null>(null);
  const [catalog, setCatalog] = useState<McpCustomGroup[]>([]);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [rows, setRows] = useState<Record<string, ToolRowState>>({});
  const [defaultMode, setDefaultMode] = useState<DefaultMode>('true');
  const [copied, setCopied] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    setLoadError(null);
    Promise.all([api.adminGetMcpCustomScope(slug), api.adminMcpCustomScopeCatalog()])
      .then(([scopeRes, catalogRes]) => {
        if (cancelled) return;
        setScope(scopeRes.scope);
        setCatalog(catalogRes.groups ?? []);
      })
      .catch((err) => {
        if (!cancelled) setLoadError(err instanceof Error ? err.message : 'Failed to load endpoint');
      });
    return () => {
      cancelled = true;
    };
  }, [slug]);

  // Param power is bounded by the endpoint's included groups.
  const universe: ToolsetUniverseEntry[] = useMemo(
    () => (scope ? universeFromCatalog(catalog, scope.config) : []),
    [catalog, scope],
  );

  const spec = useMemo(() => buildSpec(rows, defaultMode), [rows, defaultMode]);
  const baseline = useMemo(
    () => (scope ? computeEffectiveTools(scope.config, universe, null) : {}),
    [scope, universe],
  );
  // `full` = every customizable group in the catalog (bounded by the endpoint's
  // included groups at compile time); core rides PREVIEW_PRESETS.
  const presets = useMemo(
    () => ({
      ...PREVIEW_PRESETS,
      ...(catalog.length > 0
        ? { full: catalog.flatMap((group) => group.tools.map((tool) => tool.name)) }
        : {}),
    }),
    [catalog],
  );
  const effective = useMemo(
    () => (scope ? computeEffectiveTools(scope.config, universe, spec, { presets }) : {}),
    [scope, universe, spec, presets],
  );

  const hasSelection =
    defaultMode !== 'true' ||
    Object.values(rows).some((row) => row.selection !== 'default' || !row.visible);
  const gatewayUrl = scope?.url || `https://tobor.locker/custom/${encodeURIComponent(slug)}/mcp`;
  const rawJson = JSON.stringify(compactToolsetSpec(spec));
  const token = encodeToolsetParam(spec);
  const fullUrl = toolSelectionUrl(gatewayUrl, spec);
  const tooLong = fullUrl.length > 2000;
  const presetApproximate = defaultMode !== 'true' && !(defaultMode in presets);

  const enabledCount = Object.values(effective).filter((flags) => flags.enabled).length;

  async function copy(text: string, id: string) {
    try {
      await navigator.clipboard.writeText(text);
      setCopied(id);
      setTimeout(() => setCopied(null), 2000);
      toast.success('Copied');
    } catch {
      toast.error('Copy failed — select and copy manually');
    }
  }

  function toggleInclude(name: string, include: boolean) {
    setRows((current) => {
      const prior = current[name] ?? {
        selection: 'default' as const,
        visible: baseline[canon(name)]?.visible ?? true,
      };
      return {
        ...current,
        [name]: { ...prior, selection: include ? ('included' as const) : ('excluded' as const) },
      };
    });
  }

  function toggleVisible(name: string, visible: boolean) {
    setRows((current) => {
      const prior = current[name] ?? {
        selection: 'default' as const,
        visible: baseline[canon(name)]?.visible ?? true,
      };
      return { ...current, [name]: { ...prior, visible } };
    });
  }

  const grouped = useMemo(() => {
    const byGroup = new Map<string, { label: string; tools: ToolsetUniverseEntry[] }>();
    for (const entry of universe) {
      const label = catalog.find((group) => group.id === entry.group)?.label ?? entry.group;
      const bucket = byGroup.get(entry.group) ?? { label, tools: [] };
      bucket.tools.push(entry);
      byGroup.set(entry.group, bucket);
    }
    return [...byGroup.values()];
  }, [universe, catalog]);

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-label="Tool selection URL builder"
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 900,
        display: 'flex',
        alignItems: 'flex-start',
        justifyContent: 'center',
        padding: '6vh 16px 16px',
        background: 'rgba(0,0,0,0.5)',
        overflowY: 'auto',
      }}
      onClick={(e) => {
        if (e.target === e.currentTarget) onClose();
      }}
    >
      <div
        className="dash-panel"
        style={{ width: '100%', maxWidth: 760, background: 'var(--bg-1, #fff)', padding: 16 }}
      >
        <div className="dash-panel__head">
          <h2 className="dash-panel__title">
            Tool selection URL{scope ? ` — ${scope.name}` : ''}
          </h2>
          <button type="button" className="sg-btn sg-btn--outline sg-btn--sm" onClick={onClose}>
            Close
          </button>
        </div>
        <p className="sg-page-intro" style={{ marginTop: 0 }}>
          Compose a per-client <span className="font-mono">?t=</span> tool selection for this
          endpoint&apos;s gateway URL. Power is bounded by the endpoint&apos;s included groups;
          ACL rules still apply last.
        </p>

        {loadError ? (
          <p role="alert" className="sg-page-intro">
            {loadError}
          </p>
        ) : !scope ? (
          <p className="sg-page-intro">Loading endpoint…</p>
        ) : (
          <div style={{ display: 'grid', gap: 16 }}>
            <div className="sg-field" style={{ marginBottom: 0 }}>
              <label htmlFor="toolset-default">Default set</label>
              <select
                id="toolset-default"
                value={defaultMode}
                onChange={(e) => setDefaultMode(e.target.value as DefaultMode)}
              >
                {DEFAULT_OPTIONS.map((option) => (
                  <option key={option.value} value={option.value}>
                    {option.label}
                  </option>
                ))}
              </select>
              <span className="sg-field__hint">
                What tools fall back to when the white-list does not mention them. The endpoint
                default is its stored config; presets resolve server-side at connect time.
              </span>
            </div>

            <div>
              <div style={{ fontSize: 13, fontWeight: 700, marginBottom: 6 }}>
                Per-tool selection
              </div>
              {universe.length === 0 ? (
                <p className="sg-page-intro" style={{ margin: 0 }}>
                  No tools available — include a group on the endpoint first.
                </p>
              ) : (
                <div style={{ display: 'grid', gap: 10 }}>
                  {grouped.map((group) => (
                    <section
                      key={group.label}
                      style={{
                        border: '1px solid var(--border, #e5e5e5)',
                        borderRadius: 8,
                        padding: '0.75rem',
                      }}
                    >
                      <div style={{ fontSize: 12, fontWeight: 700, marginBottom: 6 }}>
                        {group.label}
                      </div>
                      <div style={{ display: 'grid', gap: 4 }}>
                        {group.tools.map((entry) => {
                          const row = rows[entry.name];
                          const included = row?.selection === 'included';
                          const visible = row?.visible ?? baseline[canon(entry.name)]?.visible ?? true;
                          return (
                            <div
                              key={entry.name}
                              style={{
                                display: 'flex',
                                alignItems: 'center',
                                gap: 16,
                                flexWrap: 'wrap',
                                fontSize: 13,
                              }}
                            >
                              <span
                                className="font-mono"
                                style={{ minWidth: 220, fontSize: 12 }}
                                title={entry.name}
                              >
                                {entry.name}
                              </span>
                              <label style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
                                <input
                                  type="checkbox"
                                  checked={included}
                                  onChange={(e) => toggleInclude(entry.name, e.target.checked)}
                                />
                                Include
                              </label>
                              <label style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
                                <input
                                  type="checkbox"
                                  checked={visible}
                                  onChange={(e) => toggleVisible(entry.name, e.target.checked)}
                                />
                                Visible
                              </label>
                            </div>
                          );
                        })}
                      </div>
                    </section>
                  ))}
                </div>
              )}
            </div>

            <div>
              <div style={{ fontSize: 13, fontWeight: 700, marginBottom: 6 }}>
                Effective preview
              </div>
              {presetApproximate ? (
                <p className="sg-page-intro" style={{ marginTop: 0 }}>
                  Approximate: the <span className="font-mono">{defaultMode}</span> preset&apos;s
                  tools resolve from the server registry at connect time — the preview shows your
                  explicit selections plus the endpoint default.
                </p>
              ) : null}
              <p style={{ margin: '0 0 8px', fontSize: 12, color: 'var(--text-2)' }}>
                {enabledCount} of {Object.keys(effective).length} tools enabled for a client
                connecting with this URL.
              </p>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
                {Object.entries(effective).map(([name, flags]) => (
                  <span
                    key={name}
                    className="font-mono"
                    style={{
                      fontSize: 11,
                      padding: '2px 8px',
                      borderRadius: 999,
                      border: '1px solid var(--border)',
                      opacity: flags.enabled ? 1 : 0.45,
                      textDecoration: flags.enabled && flags.visible ? 'none' : 'line-through',
                    }}
                    title={`${name}: ${flags.enabled ? 'enabled' : 'disabled'}, ${
                      flags.visible ? 'visible' : 'hidden'
                    }`}
                  >
                    {name}
                  </span>
                ))}
              </div>
            </div>

            {hasSelection ? (
              <>
                <OutputRow
                  id="raw-json"
                  label="Raw JSON"
                  value={rawJson}
                  copied={copied}
                  onCopy={copy}
                />
                <OutputRow
                  id="token"
                  label="?t= token (base64url)"
                  value={token}
                  copied={copied}
                  onCopy={copy}
                />
                <OutputRow
                  id="full-url"
                  label="Gateway URL with selection"
                  value={fullUrl}
                  copied={copied}
                  onCopy={copy}
                />
                {tooLong ? (
                  <p role="alert" style={{ color: 'var(--text-3)', fontSize: 12, margin: 0 }}>
                    Warning: this URL is {fullUrl.length} characters — some MCP clients reject
                    URLs over 2000. Trim selections or use a preset default to shorten it.
                  </p>
                ) : null}
              </>
            ) : (
              <p className="sg-page-intro" style={{ margin: 0 }}>
                No overrides selected — the plain gateway URL already reflects the endpoint
                config.
              </p>
            )}

            <p className="sg-page-intro" style={{ margin: 0 }}>
              The <span className="font-mono">?t=</span> parameter takes effect at connect time —
              it is read once when the client initializes its session. Reconnect to apply a
              changed URL.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}

function OutputRow({
  id,
  label,
  value,
  copied,
  onCopy,
}: {
  id: string;
  label: string;
  value: string;
  copied: string | null;
  onCopy: (text: string, id: string) => void;
}) {
  return (
    <div className="authz-reveal">
      <div className="authz-reveal__label">{label}</div>
      <div className="authz-reveal__row">
        <code
          className="authz-reveal__key font-mono"
          style={{ whiteSpace: 'pre-wrap', wordBreak: 'break-all' }}
        >
          {value}
        </code>
        <button
          type="button"
          className="sg-btn sg-btn--outline sg-btn--sm"
          onClick={() => onCopy(value, id)}
        >
          {copied === id ? 'Copied!' : 'Copy'}
        </button>
      </div>
    </div>
  );
}
