import {
  pgTable,
  text,
  boolean,
  timestamp,
  integer,
  index,
  uniqueIndex,
  check,
  jsonb
} from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';

export const users = pgTable(
  'users',
  {
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    email: text('email').notNull(),
    emailVerified: boolean('email_verified').default(false).notNull(),
    handle: text('handle'),
    id: text('id').primaryKey(),
    image: text('image'),
    name: text('name'),
    updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull()
  },
  (table) => [
    uniqueIndex('idx_users_email').on(table.email),
    uniqueIndex('idx_users_handle').on(table.handle)
  ]
);

export const accounts = pgTable(
  'accounts',
  {
    accessToken: text('access_token'),
    accessTokenExpiresAt: timestamp('access_token_expires_at', { withTimezone: true }),
    accountId: text('account_id').notNull(),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    expiresAt: timestamp('expires_at', { withTimezone: true }),
    id: text('id').primaryKey(),
    idToken: text('id_token'),
    password: text('password'),
    providerId: text('provider_id').notNull(),
    refreshToken: text('refresh_token'),
    refreshTokenExpiresAt: timestamp('refresh_token_expires_at', { withTimezone: true }),
    scope: text('scope'),
    tokenType: text('token_type'),
    updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
    userId: text('user_id')
      .notNull()
      .references(() => users.id, { onDelete: 'cascade' })
  },
  (table) => [index('idx_accounts_user_id').on(table.userId)]
);

export const sessions = pgTable(
  'sessions',
  {
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    expiresAt: timestamp('expires_at', { withTimezone: true }).notNull(),
    id: text('id').primaryKey(),
    ipAddress: text('ip_address'),
    token: text('token').notNull(),
    updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
    userAgent: text('user_agent'),
    userId: text('user_id')
      .notNull()
      .references(() => users.id, { onDelete: 'cascade' })
  },
  (table) => [
    uniqueIndex('idx_sessions_token').on(table.token),
    index('idx_sessions_user_id').on(table.userId)
  ]
);

export const verifications = pgTable(
  'verifications',
  {
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    expiresAt: timestamp('expires_at', { withTimezone: true }).notNull(),
    id: text('id').primaryKey(),
    identifier: text('identifier').notNull(),
    updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
    value: text('value').notNull()
  },
  (table) => [index('idx_verifications_identifier').on(table.identifier)]
);

// ─── Invite tokens ────────────────────────────────────────────────────────

export const inviteTokens = pgTable(
  'invite_tokens',
  {
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    createdBy: text('created_by'),
    expiresAt: timestamp('expires_at', { withTimezone: true }),
    id: text('id').primaryKey(),
    maxUses: integer('max_uses').default(1).notNull(),
    token: text('token').notNull(),
    useCount: integer('use_count').default(0).notNull(),
    usedAt: timestamp('used_at', { withTimezone: true }),
    usedBy: text('used_by')
  },
  (table) => [uniqueIndex('idx_invite_tokens_token').on(table.token)]
);

// ─── Diagram persistence (Phase 1) ─────────────────────────────────────────

export const folders = pgTable(
  'folders',
  {
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    id: text('id').primaryKey(),
    name: text('name').notNull(),
    parentId: text('parent_id').references((): unknown => folders.id, { onDelete: 'set null' }),
    updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
    userId: text('user_id')
      .notNull()
      .references(() => users.id, { onDelete: 'cascade' })
  },
  (table) => [
    index('idx_folders_user_id').on(table.userId),
    index('idx_folders_parent_id').on(table.parentId)
  ]
);

export const diagrams = pgTable(
  'diagrams',
  {
    activeBranchId: text('active_branch_id'),
    code: text('code').notNull(),
    config: text('config'),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    description: text('description'),
    folderId: text('folder_id').references(() => folders.id, { onDelete: 'set null' }),
    id: text('id').primaryKey(),
    starred: boolean('starred').notNull().default(false),
    tags: jsonb('tags')
      .$type<string[]>()
      .default(sql`'[]'::jsonb`)
      .notNull(),
    thumbnail: text('thumbnail'),
    title: text('title'),
    updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
    userId: text('user_id').references(() => users.id, { onDelete: 'set null' }),
    visibility: text('visibility').notNull().default('private')
  },
  (table) => [
    index('idx_diagrams_user_updated').on(table.userId, sql`updated_at DESC`),
    index('idx_diagrams_folder_id').on(table.folderId),
    index('idx_diagrams_visibility').on(table.visibility),
    index('idx_diagrams_starred').using('btree', table.userId, table.starred),
    index('idx_diagrams_tags').using('gin', table.tags),
    check('chk_visibility', sql`visibility IN ('private', 'unlisted', 'public')`),
    check('chk_diagrams_tags_array', sql`jsonb_typeof(tags) = 'array'`)
  ]
);

// ─── Organizations & sharing (Phase 2 — schema defined early) ───────────────

export const organizations = pgTable(
  'organizations',
  {
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    id: text('id').primaryKey(),
    name: text('name').notNull(),
    slug: text('slug').notNull(),
    updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull()
  },
  (table) => [uniqueIndex('idx_organizations_slug').on(table.slug)]
);

export const orgMembers = pgTable(
  'org_members',
  {
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    id: text('id').primaryKey(),
    orgId: text('org_id')
      .notNull()
      .references(() => organizations.id, { onDelete: 'cascade' }),
    role: text('role').notNull().default('member'),
    userId: text('user_id')
      .notNull()
      .references(() => users.id, { onDelete: 'cascade' })
  },
  (table) => [
    uniqueIndex('idx_org_members_unique').on(table.orgId, table.userId),
    index('idx_org_members_user_id').on(table.userId)
  ]
);

export const diagramShares = pgTable(
  'diagram_shares',
  {
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    diagramId: text('diagram_id')
      .notNull()
      .references(() => diagrams.id, { onDelete: 'cascade' }),
    id: text('id').primaryKey(),
    permission: text('permission').notNull().default('view'),
    sharedWithOrgId: text('shared_with_org_id').references(() => organizations.id, {
      onDelete: 'cascade'
    }),
    sharedWithUserId: text('shared_with_user_id').references(() => users.id, {
      onDelete: 'cascade'
    })
  },
  (table) => [
    index('idx_diagram_shares_diagram').on(table.diagramId),
    index('idx_diagram_shares_user').on(table.sharedWithUserId),
    index('idx_diagram_shares_org').on(table.sharedWithOrgId),
    check(
      'chk_share_target',
      sql`shared_with_user_id IS NOT NULL OR shared_with_org_id IS NOT NULL`
    )
  ]
);

// ─── Projects (diagram collections) ──────────────────────────────────────────

export const projects = pgTable(
  'projects',
  {
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    description: text('description'),
    id: text('id').primaryKey(),
    name: text('name').notNull(),
    ownerId: text('owner_id')
      .notNull()
      .references(() => users.id, { onDelete: 'cascade' }),
    updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
    visibility: text('visibility').notNull().default('private')
  },
  (table) => [
    index('idx_projects_owner_id').on(table.ownerId),
    check('chk_projects_visibility', sql`visibility IN ('private', 'unlisted', 'public')`)
  ]
);

export const projectDiagrams = pgTable(
  'project_diagrams',
  {
    addedAt: timestamp('added_at', { withTimezone: true }).defaultNow().notNull(),
    diagramId: text('diagram_id')
      .notNull()
      .references(() => diagrams.id, { onDelete: 'cascade' }),
    id: text('id').primaryKey(),
    position: integer('position').notNull().default(0),
    projectId: text('project_id')
      .notNull()
      .references(() => projects.id, { onDelete: 'cascade' })
  },
  (table) => [
    uniqueIndex('idx_project_diagrams_unique').on(table.projectId, table.diagramId),
    index('idx_project_diagrams_diagram_id').on(table.diagramId)
  ]
);

// ─── Diagram forks ────────────────────────────────────────────────────────────

export const diagramForks = pgTable(
  'diagram_forks',
  {
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    forkedBy: text('forked_by').references(() => users.id, { onDelete: 'set null' }),
    forkedDiagramId: text('forked_diagram_id')
      .notNull()
      .references(() => diagrams.id, { onDelete: 'cascade' }),
    id: text('id').primaryKey(),
    sourceDiagramId: text('source_diagram_id').references(() => diagrams.id, {
      onDelete: 'set null'
    })
  },
  (table) => [
    index('idx_diagram_forks_source').on(table.sourceDiagramId),
    index('idx_diagram_forks_forked').on(table.forkedDiagramId),
    uniqueIndex('idx_diagram_forks_unique').on(table.sourceDiagramId, table.forkedDiagramId)
  ]
);

// ─── Diagram pull requests ────────────────────────────────────────────────────

export const diagramPullRequests = pgTable(
  'diagram_pull_requests',
  {
    closedAt: timestamp('closed_at', { withTimezone: true }),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    createdBy: text('created_by').references(() => users.id, { onDelete: 'set null' }),
    description: text('description'),
    id: text('id').primaryKey(),
    sourceDiagramId: text('source_diagram_id').references(() => diagrams.id, {
      onDelete: 'set null'
    }),
    status: text('status').notNull().default('open'),
    targetDiagramId: text('target_diagram_id')
      .notNull()
      .references(() => diagrams.id, { onDelete: 'cascade' }),
    title: text('title').notNull(),
    updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull()
  },
  (table) => [
    index('idx_diagram_pull_requests_source').on(table.sourceDiagramId),
    index('idx_diagram_pull_requests_target').on(table.targetDiagramId),
    index('idx_diagram_pull_requests_created_by').on(table.createdBy),
    index('idx_diagram_pull_requests_status').on(table.status),
    check('chk_diagram_pull_requests_status', sql`status IN ('open', 'merged', 'closed')`)
  ]
);

// ─── Version control (branches & commits) ─────────────────────────────────────

export const diagramBranches = pgTable(
  'diagram_branches',
  {
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    createdBy: text('created_by').references(() => users.id, { onDelete: 'set null' }),
    diagramId: text('diagram_id')
      .notNull()
      .references(() => diagrams.id, { onDelete: 'cascade' }),
    id: text('id').primaryKey(),
    name: text('name').notNull(),
    updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull()
  },
  (table) => [
    uniqueIndex('idx_diagram_branches_unique').on(table.diagramId, table.name),
    index('idx_diagram_branches_diagram_id').on(table.diagramId)
  ]
);

export const diagramCommits = pgTable(
  'diagram_commits',
  {
    branchId: text('branch_id')
      .notNull()
      .references(() => diagramBranches.id, { onDelete: 'cascade' }),
    code: text('code').notNull(),
    committedBy: text('committed_by').references(() => users.id, { onDelete: 'set null' }),
    config: text('config'),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    id: text('id').primaryKey(),
    message: text('message'),
    parentCommitId: text('parent_commit_id').references((): unknown => diagramCommits.id, {
      onDelete: 'set null'
    })
  },
  (table) => [
    index('idx_diagram_commits_branch_id').on(table.branchId),
    index('idx_diagram_commits_parent').on(table.parentCommitId)
  ]
);
