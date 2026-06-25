// Shared option sets for the tickets console domain — used by BOTH the list page
// (facetOptions) and the detail/edit route (EditForm referenceOptions) so the two
// can't drift. Provisional: ticket types + statuses are really tri-scoped definitions
// (type-def status_workflow); a runtime resolver from the type-defs API is a follow-on.
export const TICKET_TYPES = [
  'task',
  'bug',
  'user_story',
  'epic',
  'prd',
  'documentation',
  'research',
  'subtask',
];

export const TICKET_TYPE_OPTIONS = TICKET_TYPES.map((t) => ({ value: t, label: t }));

export const TICKET_STATUS_OPTIONS = [
  { value: 'open', label: 'Open' },
  { value: 'in_progress', label: 'In progress' },
  { value: 'blocked', label: 'Blocked' },
  { value: 'in_review', label: 'In review' },
  { value: 'done', label: 'Done' },
  { value: 'closed', label: 'Closed' },
];
