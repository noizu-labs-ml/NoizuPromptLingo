'use client';

import { useState, useEffect, useCallback } from 'react';
import { toast } from 'sonner';
import { PlusIcon } from '@heroicons/react/24/outline';
import { api, type Ticket, type Project, TICKET_PRIORITIES } from '@/lib/api';
import { useOrg, useOrgId } from '@/context/org';

const TICKET_TYPES = ['task', 'bug', 'user_story', 'epic', 'prd', 'documentation', 'research', 'subtask'];

function timeAgo(dt?: string) {
  if (!dt) return '';
  const diff = Date.now() - new Date(dt).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return 'just now';
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  return `${Math.floor(hrs / 24)}d ago`;
}

function priorityClass(p?: string | null) {
  if (p === 'critical' || p === 'high') return 'project-card__status--archived';
  return '';
}

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
  const { orgId, loading: orgLoading } = useOrgId();
  const { currentProject, switchProject } = useOrg();
  const [tickets, setTickets] = useState<Ticket[]>([]);
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);

  const scopeProjectId = currentProject?.id;

  const fetchData = useCallback(async () => {
    if (!orgId) return;
    try {
      const [ticketData, projectData] = await Promise.all([
        api.listTickets(orgId, scopeProjectId ? { projectId: scopeProjectId } : undefined),
        api.listProjects(orgId),
      ]);
      setTickets(ticketData.tickets ?? []);
      setProjects(projectData.projects ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load tickets');
    } finally {
      setLoading(false);
    }
  }, [orgId, scopeProjectId]);

  useEffect(() => {
    if (orgId) {
      fetchData();
    } else if (!orgLoading) {
      setLoading(false);
    }
  }, [fetchData, orgId, orgLoading]);

  const projectName = (id?: string | null) =>
    id ? projects.find((p) => p.id === id)?.name ?? '—' : null;

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
        </div>
        <p className="sg-page-intro">
          {currentProject
            ? `Tickets in ${currentProject.name}.`
            : 'Tasks, bugs, and stories for this organization.'}
        </p>

        {loading ? (
          <p className="sg-page-intro">Loading…</p>
        ) : tickets.length === 0 ? (
          <div className="projects-empty">
            <p className="projects-empty__text">No tickets yet. Create one to get started.</p>
            <button className="sg-btn sg-btn--black" onClick={() => setShowModal(true)}>
              Create Ticket
            </button>
          </div>
        ) : (
          <div className="projects-grid">
            {tickets.map((t) => (
              <div key={t.id} className="project-card">
                <div className="project-card__header">
                  {projectName(t.project_id) && (
                    <div className="project-card__org">{projectName(t.project_id)}</div>
                  )}
                  <div className="project-card__name">{t.title}</div>
                </div>
                <div className="project-card__body">
                  <dl className="project-card__fields">
                    <div className="project-card__field">
                      <dt>Type:</dt>
                      <dd>{t.ticket_type}</dd>
                    </div>
                    {t.assignee && (
                      <div className="project-card__field">
                        <dt>Assignee:</dt>
                        <dd>{t.assignee}</dd>
                      </div>
                    )}
                    {t.priority && (
                      <div className="project-card__field">
                        <dt>Priority:</dt>
                        <dd>{t.priority}</dd>
                      </div>
                    )}
                  </dl>
                  <div className="project-card__meta">
                    <span className={`project-card__status ${priorityClass(t.priority)}`}>{t.status}</span>
                    <span className="project-card__time">{timeAgo(t.inserted_at)}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
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
            fetchData();
          }}
        />
      )}

      {!loading && tickets.length > 0 && (
        <button className="fab" onClick={() => setShowModal(true)} aria-label="New ticket" title="New ticket">
          <PlusIcon />
        </button>
      )}
    </div>
  );
}
