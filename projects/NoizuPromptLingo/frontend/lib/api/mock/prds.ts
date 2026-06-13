/**
 * Mock PRD data for offline development and static builds.
 */

import type { PRDSummary, PRDDetail, FRDocument, ATDocument } from "../types";

export const PRD_SUMMARIES: PRDSummary[] = [
  {
    id: "PRD-001-database-infrastructure",
    number: 1,
    title: "PRD-001: Database Infrastructure",
    status: "Implemented",
    has_frs: true,
    has_ats: true,
    path: "project-management/PRDs/PRD-001-database-infrastructure",
  },
  {
    id: "PRD-002-artifact-management",
    number: 2,
    title: "PRD-002: Artifact Management",
    status: "Documented",
    has_frs: true,
    has_ats: true,
    path: "project-management/PRDs/PRD-002-artifact-management",
  },
  {
    id: "PRD-003-review-system",
    number: 3,
    title: "PRD-003: Review System",
    status: "Documented",
    has_frs: true,
    has_ats: true,
    path: "project-management/PRDs/PRD-003-review-system",
  },
  {
    id: "PRD-004-chat-and-sessions",
    number: 4,
    title: "PRD-004: Chat and Sessions",
    status: "Documented",
    has_frs: true,
    has_ats: true,
    path: "project-management/PRDs/PRD-004-chat-and-sessions",
  },
  {
    id: "PRD-005-task-queue-system",
    number: 5,
    title: "PRD-005: Task Queue System",
    status: "Documented",
    has_frs: false,
    has_ats: false,
    path: "project-management/PRDs/PRD-005-task-queue-system.md",
  },
  {
    id: "PRD-006-browser-automation",
    number: 6,
    title: "PRD-006: Browser Automation",
    status: "Documented",
    has_frs: true,
    has_ats: true,
    path: "project-management/PRDs/PRD-006-browser-automation",
  },
  {
    id: "PRD-007-web-interface",
    number: 7,
    title: "PRD-007: Web Interface",
    status: "Implemented",
    has_frs: true,
    has_ats: true,
    path: "project-management/PRDs/PRD-007-web-interface",
  },
  {
    id: "PRD-015-npl-loading-extension",
    number: 15,
    title: "PRD-015: NPL Advanced Loading Extension",
    status: "Draft",
    has_frs: false,
    has_ats: false,
    path: "project-management/PRDs/PRD-015-npl-loading-extension.md",
  },
  {
    id: "PRD-016-skill-validator-tool",
    number: 16,
    title: "PRD-016: Skill Validator Tool",
    status: "Draft",
    has_frs: true,
    has_ats: false,
    path: "project-management/PRDs/PRD-016-skill-validator-tool",
  },
  {
    id: "PRD-017-pm-mcp-tools",
    number: 17,
    title: "PRD-017: PM MCP Tools",
    status: "Documented",
    has_frs: true,
    has_ats: true,
    path: "project-management/PRDs/PRD-017-pm-mcp-tools",
  },
];

const MOCK_BODY = (id: string, title: string) => `# ${title}

**Version**: 1.0
**Status**: Documented
**Author**: npl-prd-editor

## Overview

This is the mock body for ${id}. In production, the real markdown content from the PRD README.md will be shown here.

## Goals

1. Provide a working demo of the PRD browser
2. Allow static builds without filesystem access
3. Mirror the real API shape exactly

## Non-Goals

- Replacing real PRD content
- Full offline editing
`;

export const MOCK_FRS: FRDocument[] = [
  {
    id: "FR-001",
    title: "FR-001: Core Functionality",
    body: "# FR-001: Core Functionality\n\n**Status**: Completed\n\n## Description\n\nCore functional requirement description goes here.\n",
  },
  {
    id: "FR-002",
    title: "FR-002: Extended Features",
    body: "# FR-002: Extended Features\n\n**Status**: In Progress\n\n## Description\n\nExtended feature requirement description goes here.\n",
  },
];

export const MOCK_ATS: ATDocument[] = [
  {
    id: "AT-001",
    title: "AT-001: Basic Acceptance Test",
    body: "# AT-001: Basic Acceptance Test\n\n**Category**: Integration\n**Status**: Passing\n\n## Test Steps\n\n1. Given the system is running\n2. When the feature is invoked\n3. Then the expected output is produced\n",
  },
];

export const PRD_DETAILS: PRDDetail[] = PRD_SUMMARIES.map((s) => ({
  ...s,
  body: MOCK_BODY(s.id, s.title),
  functional_requirements: s.has_frs ? MOCK_FRS.map(({ id, title }) => ({ id, title })) : [],
  acceptance_tests: s.has_ats ? MOCK_ATS.map(({ id, title }) => ({ id, title })) : [],
}));
