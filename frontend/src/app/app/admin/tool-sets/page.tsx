'use client';

/**
 * /app/admin/tool-sets (WP5 of the MCP UX cleanup) — tool sets get their own
 * admin page instead of riding below the scopes list. Hosts the extracted
 * ToolSetsSection; editing happens on /app/admin/mcp-config/tool-set/:slug.
 */
import Link from 'next/link';

import ToolSetsSection from '@/components/mcp-config/tool-sets-section';

export default function AdminToolSetsPage() {
  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">Tool sets</h1>
        </div>
        <p className="sg-page-intro">
          Durable tool sets and built-in capability profiles for the current organization.{' '}
          <Link href="/app/admin/mcp-config?tab=tool-sets">← MCP Config</Link>
        </p>

        <ToolSetsSection />
      </main>
    </div>
  );
}
