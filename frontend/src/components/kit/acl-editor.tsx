'use client';

import { useId, useState } from 'react';
import { TrashIcon, PlusIcon } from '@heroicons/react/24/outline';
import { kitBtnSm, kitFieldLabel, kitInput } from './shared';
import { newRowId } from './ids';
import {
  addGroupMember,
  addRule as addRuleToState,
  patchResource,
  patchRule as patchRuleInState,
  removeGroupMember,
  removeRule as removeRuleFromState,
} from './acl-state';
import type { AclEffect, AclGroup, AclRule, AclState, EntityRef } from '@/types/tool-state';

/** Human label for a ref in aria-labels / chips: "label (kind:id)" or "kind:id". */
export function refLabel(r: EntityRef): string {
  const base = `${r.kind}:${r.id}`;
  return r.label ? `${r.label} (${base})` : base;
}

/** Parse "kind:id" (or bare "id" → kind "any") into an EntityRef. */
export function parseRef(input: string): EntityRef | null {
  const trimmed = input.trim();
  if (!trimmed) return null;
  const sep = trimmed.indexOf(':');
  if (sep === -1) return { kind: 'any', id: trimmed };
  const kind = trimmed.slice(0, sep).trim();
  const id = trimmed.slice(sep + 1).trim();
  return kind && id ? { kind, id } : null;
}

interface ACLEditorProps {
  value: AclState;
  onChange: (next: AclState) => void;
  /** Suggested subject refs for datalist autocomplete. */
  subjectSuggestions?: EntityRef[];
  /** Suggested resource refs for datalist autocomplete. */
  resourceSuggestions?: EntityRef[];
  /** Allowed scope labels (free-form when omitted). */
  scopeOptions?: string[];
  readOnly?: boolean;
}

/** Deny rules sort before allow rules for display (stable within effect). */
export function denyFirst(rules: AclRule[]): AclRule[] {
  return [...rules].sort(
    (a, b) => (a.effect === 'deny' ? 0 : 1) - (b.effect === 'deny' ? 0 : 1),
  );
}

/**
 * Grant/deny rule editor with named permission groups. Pure controlled
 * component: emits the full next state via onChange; never mutates props.
 * Binds the shared F4 tool-state contract (`AclState` from
 * `@/types/tool-state`) — subjects/resources are F1 ERP refs (kind + id),
 * not opaque strings. Rules render deny-before-allow regardless of stored
 * order (deny wins under F1 evaluation).
 * Accessible: labeled inputs, datalist suggestions, subject-named aria-labels
 * on icon buttons.
 */
export default function ACLEditor({
  value,
  onChange,
  subjectSuggestions = [],
  resourceSuggestions = [],
  scopeOptions = [],
  readOnly = false,
}: ACLEditorProps) {
  const { rules, groups } = value;
  const [newGroupMembers, setNewGroupMembers] = useState<Record<string, string>>({});
  const uid = useId();
  const subjectListId = `${uid}-subject-suggestions`;
  const resourceListId = `${uid}-resource-suggestions`;
  const kindListId = `${uid}-kind-suggestions`;

  function updateGroups(next: AclGroup[]) {
    onChange({ rules, groups: next });
  }

  function addRule() {
    onChange(addRuleToState(value, scopeOptions[0] ?? 'read'));
  }

  function patchRule(id: string, patch: Partial<AclRule>) {
    onChange(patchRuleInState(value, id, patch));
  }

  const kindSuggestions = [
    ...new Set([
      ...subjectSuggestions.map((s) => s.kind),
      ...resourceSuggestions.map((s) => s.kind),
    ]),
  ];

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
      {/* Rules */}
      <section aria-label="ACL rules">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
          <h4 style={{ margin: 0, fontSize: 12, fontWeight: 600, color: 'var(--text-0)' }}>Rules</h4>
          {!readOnly ? (
            <button type="button" onClick={addRule} style={kitBtnSm}>
              <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
                <PlusIcon style={{ width: 12, height: 12 }} aria-hidden="true" /> Add rule
              </span>
            </button>
          ) : null}
        </div>
        {rules.length === 0 ? (
          <p style={{ fontSize: 11, color: 'var(--text-3)', margin: 0 }}>No rules — access falls through to defaults.</p>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            {denyFirst(rules).map((rule) => (
              <div
                key={rule.id}
                role="group"
                aria-label={`${rule.effect} rule for ${refLabel(rule.subject)}`}
                style={{
                  display: 'grid',
                  gridTemplateColumns: 'auto 1fr 1fr 1fr 64px auto',
                  gap: 6,
                  alignItems: 'end',
                  padding: 8,
                  borderRadius: 6,
                  background: 'var(--bg-3)',
                  border: '1px solid var(--border)',
                }}
              >
                <div>
                  <label htmlFor={`acl-effect-${rule.id}`} style={kitFieldLabel}>Effect</label>
                  <select
                    id={`acl-effect-${rule.id}`}
                    value={rule.effect}
                    disabled={readOnly}
                    onChange={(e) => patchRule(rule.id, { effect: e.target.value as AclEffect })}
                    style={{
                      ...kitInput,
                      color: rule.effect === 'deny' ? 'var(--red, #ef4444)' : 'var(--green, #22c55e)',
                      fontWeight: 600,
                    }}
                  >
                    <option value="deny">deny</option>
                    <option value="allow">allow</option>
                  </select>
                </div>
                <div>
                  <label htmlFor={`acl-subject-${rule.id}`} style={kitFieldLabel}>Subject ref</label>
                  <div style={{ display: 'flex', gap: 4 }}>
                    <input
                      id={`acl-subject-kind-${rule.id}`}
                      list={kindListId}
                      aria-label={`Subject kind for ${refLabel(rule.subject)}`}
                      value={rule.subject.kind}
                      readOnly={readOnly}
                      placeholder="kind"
                      onChange={(e) => patchRule(rule.id, { subject: { ...rule.subject, kind: e.target.value } })}
                      style={{ ...kitInput, width: 84, fontFamily: 'monospace' }}
                    />
                    <input
                      id={`acl-subject-${rule.id}`}
                      list={subjectListId}
                      aria-label={`Subject id for ${refLabel(rule.subject)}`}
                      value={rule.subject.id}
                      readOnly={readOnly}
                      placeholder="subject id"
                      onChange={(e) => patchRule(rule.id, { subject: { ...rule.subject, id: e.target.value } })}
                      style={{ ...kitInput, width: '100%', fontFamily: 'monospace' }}
                    />
                  </div>
                </div>
                <div>
                  <label htmlFor={`acl-resource-${rule.id}`} style={kitFieldLabel}>Resource ref</label>
                  <div style={{ display: 'flex', gap: 4 }}>
                    <input
                      id={`acl-resource-kind-${rule.id}`}
                      list={kindListId}
                      aria-label={`Resource kind${rule.resource ? ` for ${refLabel(rule.resource)}` : ''}`}
                      value={rule.resource?.kind ?? ''}
                      readOnly={readOnly}
                      placeholder="kind"
                      onChange={(e) =>
                        patchRule(rule.id, { resource: patchResource(rule, { kind: e.target.value }).resource })
                      }
                      style={{ ...kitInput, width: 84, fontFamily: 'monospace' }}
                    />
                    <input
                      id={`acl-resource-${rule.id}`}
                      list={resourceListId}
                      aria-label={`Resource id${rule.resource ? ` for ${refLabel(rule.resource)}` : ''}`}
                      value={rule.resource?.id ?? ''}
                      readOnly={readOnly}
                      placeholder="entity id"
                      onChange={(e) =>
                        patchRule(rule.id, { resource: patchResource(rule, { id: e.target.value }).resource })
                      }
                      style={{ ...kitInput, width: '100%', fontFamily: 'monospace' }}
                    />
                  </div>
                </div>
                <div>
                  <label htmlFor={`acl-scope-${rule.id}`} style={kitFieldLabel}>Scope</label>
                  {scopeOptions.length > 0 ? (
                    <select
                      id={`acl-scope-${rule.id}`}
                      value={rule.scope ?? ''}
                      disabled={readOnly}
                      onChange={(e) => patchRule(rule.id, { scope: e.target.value })}
                      style={{ ...kitInput, width: '100%' }}
                    >
                      {scopeOptions.map((s) => (
                        <option key={s} value={s}>{s}</option>
                      ))}
                    </select>
                  ) : (
                    <input
                      id={`acl-scope-${rule.id}`}
                      value={rule.scope ?? ''}
                      readOnly={readOnly}
                      onChange={(e) => patchRule(rule.id, { scope: e.target.value })}
                      style={{ ...kitInput, width: '100%' }}
                    />
                  )}
                </div>
                <div>
                  <label htmlFor={`acl-priority-${rule.id}`} style={kitFieldLabel}>Prio</label>
                  <input
                    id={`acl-priority-${rule.id}`}
                    type="number"
                    step={1}
                    value={rule.priority}
                    readOnly={readOnly}
                    aria-label={`Priority for ${rule.effect} rule on ${refLabel(rule.subject)}`}
                    onChange={(e) => patchRule(rule.id, { priority: Math.floor(Number(e.target.value)) || 0 })}
                    style={{ ...kitInput, width: '100%' }}
                  />
                </div>
                <span style={{ fontSize: 10, color: 'var(--text-3)', paddingBottom: 6 }}>
                  {rule.effect === 'deny' ? 'blocks' : 'grants'} access
                </span>
                {!readOnly ? (
                  <button
                    type="button"
                    onClick={() => onChange(removeRuleFromState(value, rule.id))}
                    style={{ ...kitBtnSm, border: 0, background: 'transparent', color: 'var(--red, #ef4444)', paddingBottom: 4 }}
                    aria-label={`Delete ${rule.effect} rule for ${refLabel(rule.subject)}`}
                  >
                    <TrashIcon style={{ width: 14, height: 14 }} aria-hidden="true" />
                  </button>
                ) : (
                  <span />
                )}
              </div>
            ))}
          </div>
        )}
        <datalist id={subjectListId}>
          {subjectSuggestions.map((s) => (
            <option key={`${s.kind}:${s.id}`} value={s.id}>{s.label ?? `${s.kind}:${s.id}`}</option>
          ))}
        </datalist>
        <datalist id={resourceListId}>
          {resourceSuggestions.map((s) => (
            <option key={`${s.kind}:${s.id}`} value={s.id}>{s.label ?? `${s.kind}:${s.id}`}</option>
          ))}
        </datalist>
        <datalist id={kindListId}>
          {kindSuggestions.map((k) => <option key={k} value={k} />)}
        </datalist>
      </section>

      {/* Groups */}
      <section aria-label="Permission groups">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
          <h4 style={{ margin: 0, fontSize: 12, fontWeight: 600, color: 'var(--text-0)' }}>Permission groups</h4>
          {!readOnly ? (
            <button
              type="button"
              onClick={() => updateGroups([...groups, { id: newRowId('acl'), name: `group-${groups.length + 1}`, members: [] }])}
              style={kitBtnSm}
            >
              <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
                <PlusIcon style={{ width: 12, height: 12 }} aria-hidden="true" /> Add group
              </span>
            </button>
          ) : null}
        </div>
        {groups.length === 0 ? (
          <p style={{ fontSize: 11, color: 'var(--text-3)', margin: 0 }}>No groups defined.</p>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {groups.map((group) => (
              <div
                key={group.id}
                style={{
                  padding: 10,
                  borderRadius: 6,
                  background: 'var(--bg-3)',
                  border: '1px solid var(--border)',
                }}
              >
                <div style={{ display: 'flex', gap: 6, alignItems: 'center', marginBottom: 8 }}>
                  <label htmlFor={`acl-group-name-${group.id}`} style={{ ...kitFieldLabel, marginBottom: 0 }}>
                    Name
                  </label>
                  <input
                    id={`acl-group-name-${group.id}`}
                    value={group.name}
                    readOnly={readOnly}
                    onChange={(e) =>
                      updateGroups(groups.map((g) => (g.id === group.id ? { ...g, name: e.target.value } : g)))
                    }
                    style={{ ...kitInput, flex: 1 }}
                  />
                  {!readOnly ? (
                    <button
                      type="button"
                      onClick={() => updateGroups(groups.filter((g) => g.id !== group.id))}
                      style={{ ...kitBtnSm, border: 0, background: 'transparent', color: 'var(--red, #ef4444)' }}
                      aria-label={`Delete group ${group.name}`}
                    >
                      <TrashIcon style={{ width: 14, height: 14 }} aria-hidden="true" />
                    </button>
                  ) : null}
                </div>
                <div style={{ display: 'flex', flexWrap: 'wrap', gap: 4, marginBottom: 6 }}>
                  {group.members.length === 0 ? (
                    <span style={{ fontSize: 11, color: 'var(--text-3)' }}>No members.</span>
                  ) : (
                    group.members.map((m) => (
                      <span
                        key={`${m.kind}:${m.id}`}
                        style={{
                          display: 'inline-flex',
                          alignItems: 'center',
                          gap: 4,
                          fontSize: 10,
                          fontFamily: 'monospace',
                          padding: '2px 6px',
                          borderRadius: 999,
                          background: 'var(--accent-dim, var(--bg-2))',
                          border: '1px solid var(--border)',
                          color: 'var(--text-1)',
                        }}
                      >
                        {m.label ?? `${m.kind}:${m.id}`}
                        {!readOnly ? (
                          <button
                            type="button"
                            aria-label={`Remove member ${refLabel(m)} from group ${group.name}`}
                            onClick={() =>
                              updateGroups(
                                groups.map((g) => (g.id === group.id ? removeGroupMember(g, m) : g)),
                              )
                            }
                            style={{ border: 0, background: 'transparent', cursor: 'pointer', color: 'var(--text-3)', padding: 0 }}
                          >
                            ✕
                          </button>
                        ) : null}
                      </span>
                    ))
                  )}
                </div>
                {!readOnly ? (
                  <div style={{ display: 'flex', gap: 6 }}>
                    <input
                      value={newGroupMembers[group.id] ?? ''}
                      placeholder="add member as kind:id…"
                      aria-label={`Add member to group ${group.name}`}
                      onChange={(e) => setNewGroupMembers((prev) => ({ ...prev, [group.id]: e.target.value }))}
                      onKeyDown={(e) => {
                        if (e.key === 'Enter') {
                          e.preventDefault();
                          const member = parseRef(newGroupMembers[group.id] ?? '');
                          if (!member) return;
                          updateGroups(groups.map((g) => (g.id === group.id ? addGroupMember(g, member) : g)));
                          setNewGroupMembers((prev) => ({ ...prev, [group.id]: '' }));
                        }
                      }}
                      style={{ ...kitInput, flex: 1, fontFamily: 'monospace' }}
                    />
                    <button
                      type="button"
                      onClick={() => {
                        const member = parseRef(newGroupMembers[group.id] ?? '');
                        if (!member) return;
                        updateGroups(groups.map((g) => (g.id === group.id ? addGroupMember(g, member) : g)));
                        setNewGroupMembers((prev) => ({ ...prev, [group.id]: '' }));
                      }}
                      style={kitBtnSm}
                    >
                      Add
                    </button>
                  </div>
                ) : null}
              </div>
            ))}
          </div>
        )}
      </section>
    </div>
  );
}
