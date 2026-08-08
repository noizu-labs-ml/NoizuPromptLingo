'use client';

import { useState, useEffect, useCallback, useMemo } from 'react';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import { api, type Project, TICKET_PRIORITIES } from '@/lib/api';
import { useOrg, useOrgId } from '@/context/org';
import { DataTable } from '@/components/console/DataTable';
import { ticketsDescriptor } from '@/lib/console/descriptors/tickets';
import { TICKET_TYPES, TICKET_TYPE_OPTIONS, TICKET_STATUS_OPTIONS } from '@/lib/console/options';

function TicketModal({
  orgId,
  projects,
  defaultProjectId,
  onClose,
  onSaved,
}: {
  orgId: string;
  projects: Project[];
  defaultProjectId?: string;
  onClose: () => void;
  onSaved: () => void;
}) {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [ticketType, setTicketType] = useState('task');
  const [priority, setPriority] = useState('');
  const [assignee, setAssignee] = useState('');
  const [projectId, setProjectId] = useState(defaultProjectId ?? '');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!title.trim()) return;
    setSaving(true);
    setError(null);
    try {
      await api.createTicket(orgId, {
        title: title.trim(),
        description: description.trim(),
        ticket_type: ticketType,
        // Send an explicit default status: the BE controller passes status through
        // verbatim, so omitting it sends NULL and overrides the schema default
        // ("open") -> NOT NULL violation -> 500 (ticket e995503e).
        status: 'open',
        priority: priority || null,
        assignee: assignee.trim() || undefined,
        project_id: projectId || null,
      });
      toast.success('Ticket created');
      onSaved();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Request failed');
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-card" onClick={(e) => e.stopPropagation()}>
        <h2 className="modal-title">Create Ticket</h2>
        <form onSubmit={handleSubmit}>
          <div className="sg-field">
            <label htmlFor="ticket-title">Title</label>
            <input
              id="ticket-title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Fix the thing"
              autoFocus
            />
          </div>
          <div className="sg-field">
            <label htmlFor="ticket-type">Type</label>
            <select id="ticket-type" value={ticketType} onChange={(e) => setTicketType(e.target.value)}>
              {TICKET_TYPES.map((t) => (
                <option key={t} value={t}>
                  {t}
                </option>
              ))}
            </select>
          </div>
          <div className="sg-field">
            <label htmlFor="ticket-priority">Priority</label>
            <select id="ticket-priority" value={priority} onChange={(e) => setPriority(e.target.value)}>
              <option value="">None</option>
              {TICKET_PRIORITIES.map((p) => (
                <option key={p} value={p}>
                  {p}
                </option>
              ))}
            </select>
          </div>
          <div className="sg-field">
            <label htmlFor="ticket-assignee">Assignee</label>
            <input
              id="ticket-assignee"
              value={assignee}
              onChange={(e) => setAssignee(e.target.value)}
              placeholder="persona slug (optional)"
            />
          </div>
          <div className="sg-field">
            <label htmlFor="ticket-description">Description</label>
            <textarea
              id="ticket-description"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Optional markdown description"
            />
          </div>
          <div className="sg-field">
            <label htmlFor="ticket-project">Project</label>
            <select id="ticket-project" value={projectId} onChange={(e) => setProjectId(e.target.value)}>
              <option value="">No project</option>
              {projects.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.name}
                </option>
              ))}
            </select>
            <span className="sg-field__hint">Optional — scope this ticket to a project.</span>
          </div>
          {error && <div className="sg-error">{error}</div>}
          <div className="modal-actions">
            <button type="button" className="sg-btn sg-btn--outline" onClick={onClose}>
              Cancel
            </button>
            <button type="submit" className="sg-btn sg-btn--black" disabled={saving || !title.trim()}>
              {saving ? 'Saving…' : 'Create'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default function TicketsPage() {
  // orgId = resolved UUID (api is UUID-keyed; DataTable ctx); orgSlug = canonical slug for routes.
  const { orgId, slug: orgSlug, loading: orgLoading } = useOrgId();
  const { currentProject, switchProject } = useOrg();
  const router = useRouter();
  const [projects, setProjects] = useState<Project[]>([]);
  const [showModal, setShowModal] = useState(false);
  // Bumped on create to remount <DataTable> so it refetches (it owns its own fetch).
  const [reloadKey, setReloadKey] = useState(0);

  const scopeProjectId = currentProject?.id;

  // Projects power the dynamic projectId facet options + the create modal.
  const fetchProjects = useCallback(async () => {
    if (!orgId) return;
    try {
      const { projects } = await api.listProjects(orgId);
      setProjects(projects ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load projects');
    }
  }, [orgId]);

  useEffect(() => {
    if (orgId) fetchProjects();
  }, [fetchProjects, orgId]);

  // Dynamic facet options (Mei #2 facetOptions prop, diego seq506): projectId from the
  // live project list, type/status from known sets. DataTable resolves `dynamic` facets
  // from this map — no descriptor cloning needed.
  const facetOptions = useMemo(
    () => ({
      projectId: projects.map((p) => ({ value: p.id, label: p.name })),
      ticketType: TICKET_TYPE_OPTIONS,
      status: TICKET_STATUS_OPTIONS,
    }),
    [projects],
  );

  // orgId (UUID) for api calls; orgSlug for route building (ConsoleContext, diego seq506).
  const ctx = useMemo(() => ({ orgId: orgId ?? '', orgSlug: orgSlug ?? '' }), [orgId, orgSlug]);
  const scope = useMemo(
    () => (scopeProjectId ? { projectId: scopeProjectId } : undefined),
    [scopeProjectId],
  );

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">Tickets</h1>
          {currentProject && (
            <span className="scope-chip">
              Project: <strong>{currentProject.name}</strong>
              <button
                type="button"
                className="scope-chip__clear"
                onClick={() => switchProject(null)}
                aria-label="Clear project scope"
                title="Show all projects"
              >
                ×
              </button>
            </span>
          )}
          <button className="sg-btn sg-btn--black" onClick={() => setShowModal(true)}>
            New Ticket
          </button>
        </div>
        <p className="sg-page-intro">
          {currentProject
            ? `Tickets in ${currentProject.name}.`
            : 'Tasks, bugs, and stories for this organization.'}
        </p>

        {orgLoading || !orgId ? (
          <p className="sg-page-intro">Loading…</p>
        ) : (
          <DataTable
            descriptor={ticketsDescriptor}
            ctx={ctx}
            scope={scope}
            facetOptions={facetOptions}
            refreshKey={reloadKey}
            onOpenRow={(t) => router.push(`/app/${orgSlug}/tickets/${t.id}`)}
            onEditRow={(t) => router.push(`/app/${orgSlug}/tickets/${t.id}?edit=1`)}
          />
        )}
      </main>

      {showModal && orgId && (
        <TicketModal
          orgId={orgId}
          projects={projects}
          defaultProjectId={scopeProjectId}
          onClose={() => setShowModal(false)}
          onSaved={() => {
            setShowModal(false);
            setReloadKey((k) => k + 1);
          }}
        />
      )}
    </div>
  );
}
