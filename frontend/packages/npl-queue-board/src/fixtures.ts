import type {QueueBoard, QueueBoardData, QueueTicket} from './types.js';

export function defaultFixture(): QueueBoardData {
  const releaseOps: QueueBoard = {
    id: 'board-release-ops',
    name: 'Release Ops',
    slug: 'release-ops',
    methodology: 'kanban',
    scope: 'org',
    stages: [
      {id: 'st-ro-todo', slug: 'todo', name: 'To Do', kind: 'todo', position: 0, wip_limit: null},
      {id: 'st-ro-wip', slug: 'in_progress', name: 'In Progress', kind: 'in_progress', position: 1, wip_limit: 3},
      {id: 'st-ro-review', slug: 'in_review', name: 'In Review', kind: 'in_review', position: 2, wip_limit: null},
      {id: 'st-ro-done', slug: 'done', name: 'Done', kind: 'done', position: 3, wip_limit: null},
    ],
  };

  const agentTools: QueueBoard = {
    id: 'board-agent-tools',
    name: 'Agent Tools Sprint',
    slug: 'agent-tools-sprint',
    methodology: 'scrum',
    scope: 'project',
    stages: [
      {id: 'st-at-todo', slug: 'todo', name: 'To Do', kind: 'todo', position: 0, wip_limit: null},
      {id: 'st-at-wip', slug: 'in_progress', name: 'In Progress', kind: 'in_progress', position: 1, wip_limit: 2},
      {id: 'st-at-review', slug: 'in_review', name: 'In Review', kind: 'in_review', position: 2, wip_limit: null},
      {id: 'st-at-done', slug: 'done', name: 'Done', kind: 'done', position: 3, wip_limit: null},
    ],
  };

  const items: QueueTicket[] = [
    {
      id: 't-ro-101', key: 'NPL-101', number: 101, title: 'Harden ticket key generation',
      status: 'done', priority: 'high', assignee: 'Keith Brings', tags: ['tickets', 'stability'],
      ticket_type: 'task', queue_id: releaseOps.id, stage_id: 'st-ro-done',
      updated_at: '2026-08-30T14:12:00Z',
    },
    {
      id: 't-ro-102', key: 'NPL-102', number: 102, title: 'Board stage reorder API',
      status: 'in_progress', priority: 'medium', assignee: 'Ana Okafor', tags: ['boards'],
      ticket_type: 'feature', queue_id: releaseOps.id, stage_id: 'st-ro-wip',
      updated_at: '2026-08-30T10:02:00Z',
    },
    {
      id: 't-ro-103', key: 'NPL-103', number: 103, title: 'Rate-limit ticket feed polling',
      status: 'in_review', priority: 'low', assignee: null, tags: ['mcp', 'perf'],
      ticket_type: 'task', queue_id: releaseOps.id, stage_id: 'st-ro-review',
      updated_at: '2026-08-29T18:40:00Z',
    },
    {
      id: 't-ro-104', key: 'NPL-104', number: 104, title: 'Queue web component spike',
      status: 'open', priority: 'high', assignee: 'Priya Nair',
      ticket_type: 'spike', queue_id: releaseOps.id, stage_id: null,
      custom_fields: {tags: ['lit', 'frontend']},
      updated_at: '2026-08-31T08:15:00Z',
    },
    {
      id: 't-ro-105', key: null, number: null, title: 'Investigate flaky seed job',
      status: 'open', priority: null, assignee: null, tags: [],
      ticket_type: 'bug', queue_id: releaseOps.id, stage_id: 'st-ro-todo',
      updated_at: '2026-08-28T09:30:00Z',
    },
    {
      id: 't-ro-106', key: 'NPL-106', number: 106, title: 'Document board token contract',
      status: 'blocked', priority: 'medium', assignee: 'Ana Okafor', tags: ['docs'],
      ticket_type: 'documentation', queue_id: releaseOps.id, stage_id: 'st-ro-todo',
      updated_at: '2026-08-30T16:55:00Z',
    },
    {
      id: 't-at-201', key: 'TRP-201', number: 201, title: 'Embed queue board in plans dashboard',
      status: 'in_progress', priority: 'high', assignee: 'Priya Nair', tags: ['trp', 'embed'],
      ticket_type: 'feature', queue_id: agentTools.id, stage_id: 'st-at-wip',
      updated_at: '2026-08-31T07:05:00Z',
    },
    {
      id: 't-at-202', key: 'TRP-202', number: 202, title: 'Per-key toolset registry seam',
      status: 'open', priority: 'medium', assignee: 'Keith Brings', tags: ['registry'],
      ticket_type: 'task', queue_id: agentTools.id, stage_id: 'st-at-todo',
      updated_at: '2026-08-30T12:20:00Z',
    },
    {
      id: 't-at-203', key: 'TRP-203', number: 203, title: 'Ship shared component bundle',
      status: 'done', priority: 'low', assignee: 'Sam Ruiz', tags: ['ci'],
      ticket_type: 'chore', queue_id: agentTools.id, stage_id: 'st-at-done',
      updated_at: '2026-08-27T11:00:00Z',
    },
  ];

  return {queues: [releaseOps, agentTools], items};
}
