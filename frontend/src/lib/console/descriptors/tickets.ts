// Tickets console descriptor (epic 8920d294). Richest domain — exercises facets,
// project scope, status/priority/type, related children. Built to yuki §6 (7e269bff).
// REST gate: api.listTickets/getTicket/createTicket/updateTicket all exist -> fully wirable.
import { api, type Ticket, type TicketInput } from '@/lib/api';
import type { ConsoleDescriptor } from '../types';

const PRIORITIES = [
  { value: 'low', label: 'Low' },
  { value: 'medium', label: 'Medium' },
  { value: 'high', label: 'High' },
  { value: 'critical', label: 'Critical' },
];

// Ticket types + statuses are tri-scoped definitions (type-defs / status_workflow),
// so their facet + select options are resolved at runtime (dynamic), not hardcoded.
export const ticketsDescriptor: ConsoleDescriptor<Ticket, TicketInput> = {
  domain: 'tickets',
  labels: { singular: 'Ticket', plural: 'Tickets' },
  route: '/app/:org/tickets',
  columns: [
    { key: 'title', label: 'Title', primary: true, sortable: true, width: '34%' },
    { key: 'ticket_type', label: 'Type', sortable: true },
    { key: 'status', label: 'Status', sortable: true },
    { key: 'priority', label: 'Priority', sortable: true },
    { key: 'assignee', label: 'Assignee', sortable: true, render: (t) => t.assignee ?? '—' },
    { key: 'updated_at', label: 'Updated', sortable: true, align: 'right' },
  ],
  filters: [
    { key: 'search', label: 'Search', type: 'search' },
    // facet keys mirror api.listTickets opts so the primitive can pass them straight through.
    // status + type are MULTI-select (3c2d6bbe): FacetMultiSelect -> status[]/ticket_type[]
    // -> aniket's `= ANY` OR-within-facet (seq575). project stays single (it's the scope).
    { key: 'status', label: 'Status', type: 'facet', dynamic: true, multi: true },
    { key: 'priority', label: 'Priority', type: 'facet', options: PRIORITIES },
    { key: 'ticketType', label: 'Type', type: 'facet', dynamic: true, multi: true },
    { key: 'projectId', label: 'Project', type: 'facet', dynamic: true },
  ],
  detail: {
    sections: [
      {
        title: 'Overview',
        fields: [
          { key: 'title', label: 'Title' },
          { key: 'ticket_type', label: 'Type' },
          { key: 'status', label: 'Status' },
          { key: 'priority', label: 'Priority', render: (t) => t.priority ?? '—' },
          { key: 'assignee', label: 'Assignee', render: (t) => t.assignee ?? '—' },
          { key: 'reporter', label: 'Reporter', render: (t) => t.reporter ?? '—' },
        ],
      },
      {
        title: 'Description',
        fields: [{ key: 'description', label: 'Description', span: true, render: (t) => t.description ?? '—' }],
      },
      {
        title: 'Meta',
        fields: [
          { key: 'id', label: 'ID' },
          { key: 'project_id', label: 'Project' },
          { key: 'parent_id', label: 'Parent', render: (t) => t.parent_id ?? '—' },
          { key: 'queue_id', label: 'Queue', render: (t) => t.queue_id ?? '—' },
          { key: 'stage_id', label: 'Stage', render: (t) => t.stage_id ?? '—' },
          { key: 'iteration_id', label: 'Iteration', render: (t) => t.iteration_id ?? '—' },
          { key: 'inserted_at', label: 'Created' },
          { key: 'updated_at', label: 'Updated' },
        ],
      },
    ],
    // Child tickets (this ticket as parent) render as an embedded read-only mini-table.
    related: [{ title: 'Sub-tickets', domain: 'tickets', query: (t) => ({ parentId: t.id }) }],
  },
  edit: {
    sections: [
      {
        title: 'Ticket',
        fields: [
          { key: 'title', label: 'Title', type: 'text', required: true },
          { key: 'description', label: 'Description', type: 'textarea' },
          { key: 'ticket_type', label: 'Type', type: 'select', dynamic: true, required: true, hint: 'From the org/project ticket-type definitions.' },
          // status defaults to "open" on create (e995503e); options come from the type's status_workflow.
          { key: 'status', label: 'Status', type: 'select', dynamic: true },
          { key: 'priority', label: 'Priority', type: 'select', options: PRIORITIES },
          { key: 'assignee', label: 'Assignee', type: 'text', hint: 'Persona slug (optional).' },
          { key: 'project_id', label: 'Project', type: 'reference', referenceDomain: 'projects', dynamic: true, hint: 'Optional — scope to a project.' },
        ],
      },
    ],
  },
  actions: { rowActions: ['view', 'edit', 'delete'] },
  api: {
    list: (orgId, opts) => api.listTickets(orgId, opts as Parameters<typeof api.listTickets>[1]).then((r) => r.tickets),
    get: (orgId, id) => api.getTicket(orgId, id).then((r) => r.ticket),
    create: (orgId, input) => api.createTicket(orgId, input).then((r) => r.ticket),
    update: (orgId, id, input) => api.updateTicket(orgId, id, input).then((r) => r.ticket),
  },
};
