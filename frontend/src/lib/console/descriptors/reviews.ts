// Reviews console descriptor (epic 8920d294). Flat (org-required, project-optional).
// yuki §6 (7e269bff). ava-frontend lane.
// REST gate: list/get/create present; NO update (soren f73f4cd2 gap) and no delete ->
// EDIT IS STUBBED (api.update omitted -> ConsoleDetailPage shows no Edit; the detail is
// read-only). Create stays the bespoke ReviewModal (artifact/revision/persona pickers),
// so api.create is omitted here too. When updateReview lands, add api.update + editable
// fields + the 'edit' row action.
import { api, type Review, type ReviewInput } from '@/lib/api';
import type { ConsoleDescriptor } from '../types';

const reviewTitle = (r: Review) => r.title || `Review by ${r.reviewer_persona}`;

export const reviewsDescriptor: ConsoleDescriptor<Review, ReviewInput> = {
  domain: 'reviews',
  labels: { singular: 'Review', plural: 'Reviews' },
  route: '/app/:org/reviews',
  columns: [
    { key: 'title', label: 'Review', primary: true, sortable: true, render: reviewTitle },
    { key: 'reviewer_persona', label: 'Reviewer', sortable: true },
    { key: 'status', label: 'Status', sortable: true, render: 'statusChip' },
    { key: 'verdict', label: 'Verdict', render: (r) => r.verdict ?? '—' },
    { key: 'updated_at', label: 'Updated', sortable: true, align: 'right', render: 'relativeDate' },
  ],
  filters: [{ key: 'search', label: 'Search', type: 'search' }],
  detail: {
    sections: [
      {
        title: 'Review',
        fields: [
          { key: 'title', label: 'Title', render: reviewTitle },
          { key: 'reviewer_persona', label: 'Reviewer' },
          { key: 'status', label: 'Status', render: 'statusChip' },
          { key: 'verdict', label: 'Verdict', render: (r) => r.verdict ?? '—' },
          { key: 'id', label: 'ID', render: 'idChip' },
        ],
      },
      { title: 'Summary', fields: [{ key: 'summary', label: 'Summary', span: true, render: (r) => r.summary ?? '—' }] },
      {
        title: 'Target',
        fields: [
          { key: 'artifact_id', label: 'Artifact', render: 'idChip' },
          { key: 'revision_id', label: 'Revision', render: 'idChip' },
        ],
      },
    ],
  },
  edit: { sections: [] }, // stubbed: no updateReview yet (f73f4cd2)
  actions: { rowActions: ['view'] },
  api: {
    list: (orgId, opts) => api.listReviews(orgId, opts as Parameters<typeof api.listReviews>[1]).then((r) => r.reviews),
    get: (orgId, id) => api.getReview(orgId, id).then((r) => r.review),
  },
};
