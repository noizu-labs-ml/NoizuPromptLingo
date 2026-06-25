// Chatrooms console descriptor (epic 8920d294). My surface. Built to yuki §6 (7e269bff).
// REST gate: listChatRooms/getChatRoom/createChatRoom/updateChatRoom all exist -> FULLY
// WIRABLE. (chat rooms PUT shipped by aniket 0c93ddd4 seq457; edits name+description only —
// ChatRoom.update_changeset casts those two, slug stays an immutable alias, ADR-013.)
import { api, type ChatRoom, type ChatRoomInput } from '@/lib/api';
import type { ConsoleDescriptor } from '../types';

export const chatroomsDescriptor: ConsoleDescriptor<ChatRoom, ChatRoomInput> = {
  domain: 'chatrooms',
  labels: { singular: 'Chatroom', plural: 'Chatrooms' },
  route: '/app/:org/chat',
  columns: [
    { key: 'name', label: 'Name', primary: true, sortable: true, width: '30%' },
    // slug rendered as the copyable mono chip (chat slug treatment); cell is the raw value.
    { key: 'slug', label: 'Slug', sortable: true, render: (r) => r.slug ?? '—' },
    { key: 'description', label: 'Topic', render: (r) => r.description ?? '—' },
    { key: 'project_id', label: 'Project', sortable: true, render: (r) => r.project_id ?? 'Org-level' },
    { key: 'inserted_at', label: 'Created', sortable: true, align: 'right' },
  ],
  filters: [
    { key: 'search', label: 'Search', type: 'search' },
    { key: 'projectId', label: 'Project', type: 'facet', dynamic: true },
  ],
  detail: {
    sections: [
      {
        title: 'Room',
        fields: [
          { key: 'name', label: 'Name' },
          { key: 'slug', label: 'Slug', render: (r) => r.slug ?? '—' },
          { key: 'description', label: 'Topic', span: true, render: (r) => r.description ?? '—' },
        ],
      },
      {
        title: 'Meta',
        fields: [
          { key: 'id', label: 'ID' },
          { key: 'project_id', label: 'Project', render: (r) => r.project_id ?? 'Org-level' },
          { key: 'session_id', label: 'Session', render: (r) => r.session_id ?? '—' },
          { key: 'inserted_at', label: 'Created' },
          { key: 'updated_at', label: 'Updated' },
        ],
      },
    ],
  },
  edit: {
    sections: [
      {
        title: 'Room',
        fields: [
          { key: 'name', label: 'Name', type: 'text', required: true },
          // slug is an IMMUTABLE resolution alias (ADR-013) — show read-only, never editable.
          { key: 'slug', label: 'Slug', type: 'slug', derivesFrom: 'name', readOnly: true, hint: 'Generated from name at creation; immutable.' },
          { key: 'description', label: 'Topic', type: 'textarea' },
          { key: 'project_id', label: 'Project', type: 'reference', referenceDomain: 'projects', dynamic: true, hint: 'Optional — scope to a project.' },
          { key: 'session_id', label: 'Session', type: 'reference', referenceDomain: 'sessions', dynamic: true, hint: 'Optional.' },
        ],
      },
    ],
  },
  // 'open' jumps to the live room view (thread/compose/reactions — ticket 0ab32676); a
  // custom ActionDef (domain nav), not a builtin CRUD row action. view/edit are builtins.
  actions: {
    rowActions: [
      {
        key: 'open',
        label: 'Open room',
        run: (room, ctx) => window.location.assign(`/app/${ctx.orgId}/chat/${room.id}`),
      },
      'view',
      'edit',
    ],
  },
  api: {
    list: (orgId, opts) => api.listChatRooms(orgId, opts as Parameters<typeof api.listChatRooms>[1]).then((r) => r.rooms),
    get: (orgId, id) => api.getChatRoom(orgId, id).then((r) => r.room),
    create: (orgId, input) => api.createChatRoom(orgId, input).then((r) => r.room),
    // 0c93ddd4 landed (aniket seq457): PUT {room:{name,description}}, slug immutable.
    update: (orgId, id, input) => api.updateChatRoom(orgId, id, input).then((r) => r.room),
  },
};
