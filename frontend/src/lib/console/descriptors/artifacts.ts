// Artifacts console descriptor (ticket c0f97e6b, diego-frontend lane). The viewer:
// list -> DataTable, detail -> DetailView with SAFE-markdown render (sofia's XSS rule:
// the shared <Markdown> parses + DOMPurify-sanitizes, never dangerouslySetInnerHTML on
// RAW), edit -> append-revision (history-preserving, aniket 693842f9), create stays in
// the page's richer modal. yuki §6 (7e269bff).
import { createElement } from 'react';
import { api, type Artifact, type ArtifactInput, type ArtifactKind } from '@/lib/api';
import { Markdown } from '@/components/markdown';
import type { ConsoleDescriptor } from '../types';

const KINDS: ArtifactKind[] = ['code', 'document', 'image', 'wiki', 'config', 'binary'];
const KIND_OPTIONS = KINDS.map((k) => ({ value: k, label: k }));

// Edit input = append-revision shape (content + optional note); not ArtifactInput.
type ArtifactFormInput = ArtifactInput & { note?: string };

// Render artifact content safely: code/config as a <pre> block, everything else
// through the sanitizing Markdown renderer. (createElement keeps this a .ts file.)
function renderContent(a: Artifact) {
  const content = a.content ?? '';
  if (a.kind === 'code' || a.kind === 'config') {
    return createElement('pre', { className: 'console-artifact__code' }, content);
  }
  if (a.kind === 'binary') {
    return createElement('span', { className: 'console-muted' }, 'Binary artifact — open the raw revision to download.');
  }
  return createElement(Markdown, { content });
}

export const artifactsDescriptor: ConsoleDescriptor<Artifact, ArtifactFormInput> = {
  domain: 'artifacts',
  labels: { singular: 'Artifact', plural: 'Artifacts' },
  route: '/app/:org/artifacts',
  columns: [
    { key: 'title', label: 'Title', primary: true, sortable: true, width: '34%' },
    { key: 'kind', label: 'Kind', sortable: true, render: 'statusChip' },
    { key: 'mime_type', label: 'Type', render: (a) => a.mime_type ?? '—' },
    { key: 'revision_number', label: 'Rev', align: 'right', render: (a) => (a.revision_number != null ? `v${a.revision_number}` : '—') },
    { key: 'updated_at', label: 'Updated', sortable: true, align: 'right', render: 'relativeDate' },
  ],
  filters: [
    { key: 'search', label: 'Search', type: 'search' },
    { key: 'kind', label: 'Kind', type: 'facet', options: KIND_OPTIONS },
    { key: 'projectId', label: 'Project', type: 'facet', dynamic: true },
  ],
  detail: {
    sections: [
      {
        title: 'Identity',
        fields: [
          { key: 'title', label: 'Title' },
          { key: 'kind', label: 'Kind', render: 'statusChip' },
          { key: 'id', label: 'ID', render: 'idChip' },
          { key: 'mime_type', label: 'MIME type', render: (a) => a.mime_type ?? '—' },
          { key: 'revision_number', label: 'Revision', render: (a) => (a.revision_number != null ? `v${a.revision_number}` : '—') },
          { key: 'updated_at', label: 'Updated', render: 'relativeDate' },
        ],
      },
      {
        title: 'Content',
        fields: [{ key: 'content', label: 'Content', span: true, render: renderContent }],
      },
    ],
  },
  // Edit appends a new revision (content + optional note); title/kind/mime are
  // creation-time (set in the create modal), so they are NOT edit fields here.
  edit: {
    sections: [
      {
        title: 'New revision',
        fields: [
          { key: 'content', label: 'Content', type: 'textarea', required: true },
          { key: 'note', label: 'Revision note', type: 'text', hint: 'Optional — describes this revision.' },
        ],
      },
    ],
  },
  actions: { rowActions: ['view', 'edit'] },
  api: {
    list: (orgId, opts) => api.listArtifacts(orgId, opts as Parameters<typeof api.listArtifacts>[1]).then((r) => r.artifacts),
    get: (orgId, id) => api.getArtifact(orgId, id).then((r) => r.artifact),
    create: (orgId, input) => {
      const { note: _note, ...artifact } = input;
      return api.createArtifact(orgId, artifact).then((r) => r.artifact);
    },
    // Edit path: append a revision with the new content (+ note); never a destructive PUT.
    update: (orgId, id, input) =>
      api.addArtifactRevision(orgId, id, { content: String(input.content ?? ''), note: input.note }).then((r) => r.artifact),
  },
};
