'use client';

import { useState } from 'react';
import { TrashIcon, PlusIcon } from '@heroicons/react/24/outline';
import { kitBtnSm, kitFieldLabel, kitInput } from './shared';

/**
 * ACL shapes bind against the F1 acl-core contract: subject and resource are
 * opaque ERP ref strings (`{:ref, Type, id}` serialized), effect is allow/deny,
 * scope is a free-form string supplied by the host. This component knows
 * nothing about backend code — the host owns persistence.
 */

export type AclEffect = 'allow' | 'deny';

export interface AclRule {
  /** Client-side id (host-assigned or generated). */
  id: string;
  /** Opaque ERP ref string, e.g. subject user/org/group ref. */
  subject: string;
  /** Opaque ERP ref string for the protected entity. */
  resource: string;
  effect: AclEffect;
  /** Permission scope label (e.g. "read", "write", "admin"). */
  scope: string;
}

export interface AclGroup {
  id: string;
  name: string;
  /** Member subject refs (opaque ERP ref strings). */
  members: string[];
}

export interface AclState {
  rules: AclRule[];
  groups: AclGroup[];
}

interface ACLEditorProps {
  value: AclState;
  onChange: (next: AclState) => void;
  /** Suggested subject refs for datalist autocomplete. */
  subjectSuggestions?: string[];
  /** Suggested resource refs for datalist autocomplete. */
  resourceSuggestions?: string[];
  /** Allowed scope labels (free-form when omitted). */
  scopeOptions?: string[];
  readOnly?: boolean;
}

let seq = 0;
function localId() {
  seq += 1;
  return `acl-${Date.now()}-${seq}`;
}

/**
 * Grant/deny rule editor with named permission groups. Pure controlled
 * component: emits the full next state via onChange; never mutates props.
 * Accessible: labeled inputs, datalist suggestions, aria-labels on icon buttons.
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

  function updateRules(next: AclRule[]) {
    onChange({ rules: next, groups });
  }

  function updateGroups(next: AclGroup[]) {
    onChange({ rules, groups: next });
  }

  function addRule() {
    updateRules([
      ...rules,
      { id: localId(), subject: '', resource: '', effect: 'allow', scope: scopeOptions[0] ?? 'read' },
    ]);
  }

  function patchRule(id: string, patch: Partial<AclRule>) {
    updateRules(rules.map((r) => (r.id === id ? { ...r, ...patch } : r)));
  }

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
            {rules.map((rule, idx) => (
              <div
                key={rule.id}
                role="group"
                aria-label={`Rule ${idx + 1}`}
                style={{
                  display: 'grid',
                  gridTemplateColumns: 'auto 1fr 1fr auto 1fr auto',
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
                    <option value="allow">allow</option>
                    <option value="deny">deny</option>
                  </select>
                </div>
                <div>
                  <label htmlFor={`acl-subject-${rule.id}`} style={kitFieldLabel}>Subject ref</label>
                  <input
                    id={`acl-subject-${rule.id}`}
                    list="acl-subject-suggestions"
                    value={rule.subject}
                    readOnly={readOnly}
                    placeholder="user/org/group ref"
                    onChange={(e) => patchRule(rule.id, { subject: e.target.value })}
                    style={{ ...kitInput, width: '100%', fontFamily: 'monospace' }}
                  />
                </div>
                <div>
                  <label htmlFor={`acl-resource-${rule.id}`} style={kitFieldLabel}>Resource ref</label>
                  <input
                    id={`acl-resource-${rule.id}`}
                    list="acl-resource-suggestions"
                    value={rule.resource}
                    readOnly={readOnly}
                    placeholder="entity ref"
                    onChange={(e) => patchRule(rule.id, { resource: e.target.value })}
                    style={{ ...kitInput, width: '100%', fontFamily: 'monospace' }}
                  />
                </div>
                <div>
                  <label htmlFor={`acl-scope-${rule.id}`} style={kitFieldLabel}>Scope</label>
                  {scopeOptions.length > 0 ? (
                    <select
                      id={`acl-scope-${rule.id}`}
                      value={rule.scope}
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
                      value={rule.scope}
                      readOnly={readOnly}
                      onChange={(e) => patchRule(rule.id, { scope: e.target.value })}
                      style={{ ...kitInput, width: '100%' }}
                    />
                  )}
                </div>
                <span style={{ fontSize: 10, color: 'var(--text-3)', paddingBottom: 6 }}>
                  {rule.effect === 'deny' ? 'blocks' : 'grants'} access
                </span>
                {!readOnly ? (
                  <button
                    type="button"
                    onClick={() => updateRules(rules.filter((r) => r.id !== rule.id))}
                    style={{ ...kitBtnSm, border: 0, background: 'transparent', color: 'var(--red, #ef4444)', paddingBottom: 4 }}
                    aria-label={`Delete rule ${idx + 1}`}
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
        <datalist id="acl-subject-suggestions">
          {subjectSuggestions.map((s) => <option key={s} value={s} />)}
        </datalist>
        <datalist id="acl-resource-suggestions">
          {resourceSuggestions.map((s) => <option key={s} value={s} />)}
        </datalist>
      </section>

      {/* Groups */}
      <section aria-label="Permission groups">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
          <h4 style={{ margin: 0, fontSize: 12, fontWeight: 600, color: 'var(--text-0)' }}>Permission groups</h4>
          {!readOnly ? (
            <button
              type="button"
              onClick={() => updateGroups([...groups, { id: localId(), name: `group-${groups.length + 1}`, members: [] }])}
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
            {groups.map((group, gIdx) => (
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
                    group.members.map((m, mIdx) => (
                      <span
                        key={m}
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
                        {m}
                        {!readOnly ? (
                          <button
                            type="button"
                            aria-label={`Remove member ${m} from group ${group.name}`}
                            onClick={() =>
                              updateGroups(
                                groups.map((g) =>
                                  g.id === group.id
                                    ? { ...g, members: g.members.filter((_, i) => i !== mIdx) }
                                    : g,
                                ),
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
                      placeholder="add member ref…"
                      aria-label={`Add member to group ${group.name}`}
                      onChange={(e) => setNewGroupMembers((prev) => ({ ...prev, [group.id]: e.target.value }))}
                      onKeyDown={(e) => {
                        if (e.key === 'Enter') {
                          e.preventDefault();
                          const member = (newGroupMembers[group.id] ?? '').trim();
                          if (!member) return;
                          updateGroups(
                            groups.map((g) =>
                              g.id === group.id && !g.members.includes(member)
                                ? { ...g, members: [...g.members, member] }
                                : g,
                            ),
                          );
                          setNewGroupMembers((prev) => ({ ...prev, [group.id]: '' }));
                        }
                      }}
                      style={{ ...kitInput, flex: 1, fontFamily: 'monospace' }}
                    />
                    <button
                      type="button"
                      onClick={() => {
                        const member = (newGroupMembers[group.id] ?? '').trim();
                        if (!member) return;
                        updateGroups(
                          groups.map((g) =>
                            g.id === group.id && !g.members.includes(member)
                              ? { ...g, members: [...g.members, member] }
                              : g,
                          ),
                        );
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
