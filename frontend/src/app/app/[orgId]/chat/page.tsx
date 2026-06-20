'use client';

import { useState, useEffect, useCallback } from 'react';
import { toast } from 'sonner';
import { PlusIcon } from '@heroicons/react/24/outline';
import { api, type ChatRoom, type Project } from '@/lib/api';
import { useOrg, useOrgId } from '@/context/org';

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

function RoomModal({
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
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [projectId, setProjectId] = useState(defaultProjectId ?? '');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim()) return;
    setSaving(true);
    setError(null);
    try {
      await api.createChatRoom(orgId, {
        name: name.trim(),
        description: description.trim(),
        project_id: projectId || null,
      });
      toast.success('Room created');
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
        <h2 className="modal-title">Create Room</h2>
        <form onSubmit={handleSubmit}>
          <div className="sg-field">
            <label htmlFor="room-name">Name</label>
            <input
              id="room-name"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="general"
              autoFocus
            />
          </div>
          <div className="sg-field">
            <label htmlFor="room-description">Description</label>
            <textarea
              id="room-description"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Optional topic"
            />
          </div>
          <div className="sg-field">
            <label htmlFor="room-project">Project</label>
            <select id="room-project" value={projectId} onChange={(e) => setProjectId(e.target.value)}>
              <option value="">No project</option>
              {projects.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.name}
                </option>
              ))}
            </select>
            <span className="sg-field__hint">Optional — scope this room to a project.</span>
          </div>
          {error && <div className="sg-error">{error}</div>}
          <div className="modal-actions">
            <button type="button" className="sg-btn sg-btn--outline" onClick={onClose}>
              Cancel
            </button>
            <button type="submit" className="sg-btn sg-btn--black" disabled={saving || !name.trim()}>
              {saving ? 'Saving…' : 'Create'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default function ChatroomsPage() {
  const { orgId, loading: orgLoading } = useOrgId();
  const { currentProject, switchProject } = useOrg();
  const [rooms, setRooms] = useState<ChatRoom[]>([]);
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);

  const scopeProjectId = currentProject?.id;

  const fetchData = useCallback(async () => {
    if (!orgId) return;
    try {
      const [roomData, projectData] = await Promise.all([
        api.listChatRooms(orgId, scopeProjectId ? { projectId: scopeProjectId } : undefined),
        api.listProjects(orgId),
      ]);
      setRooms(roomData.rooms ?? []);
      setProjects(projectData.projects ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load rooms');
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
          <h1 className="sg-page-title">Chatrooms</h1>
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
            ? `Rooms in ${currentProject.name}.`
            : 'Rooms, messages, and notifications for this organization.'}
        </p>

        {loading ? (
          <p className="sg-page-intro">Loading…</p>
        ) : rooms.length === 0 ? (
          <div className="projects-empty">
            <p className="projects-empty__text">No rooms yet. Create one to get started.</p>
            <button className="sg-btn sg-btn--black" onClick={() => setShowModal(true)}>
              Create Room
            </button>
          </div>
        ) : (
          <div className="projects-grid">
            {rooms.map((r) => (
              <div key={r.id} className="project-card">
                <div className="project-card__header">
                  {projectName(r.project_id) && (
                    <div className="project-card__org">{projectName(r.project_id)}</div>
                  )}
                  <div className="project-card__name">{r.name}</div>
                </div>
                <div className="project-card__body">
                  <dl className="project-card__fields">
                    {r.description && (
                      <div className="project-card__field">
                        <dt>Topic:</dt>
                        <dd>{r.description}</dd>
                      </div>
                    )}
                  </dl>
                  <div className="project-card__meta">
                    <span className="project-card__time">{timeAgo(r.inserted_at)}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </main>

      {showModal && orgId && (
        <RoomModal
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

      {!loading && rooms.length > 0 && (
        <button className="fab" onClick={() => setShowModal(true)} aria-label="New room" title="New room">
          <PlusIcon />
        </button>
      )}
    </div>
  );
}
