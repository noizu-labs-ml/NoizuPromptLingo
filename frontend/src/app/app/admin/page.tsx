'use client';

import Link from 'next/link';
import {
  UsersIcon,
  BuildingOfficeIcon,
  BookOpenIcon,
  CodeBracketIcon,
  CpuChipIcon,
  FilmIcon,
  KeyIcon,
  LinkIcon,
  MegaphoneIcon,
  WrenchScrewdriverIcon,
} from '@heroicons/react/24/outline';
import type { ComponentType, SVGProps } from 'react';
import { useOrg } from '@/context/org';

type Icon = ComponentType<SVGProps<SVGSVGElement>>;

interface Card {
  href: string;
  label: string;
  desc: string;
  Icon: Icon;
}

export default function AdminHomePage() {
  const { currentOrg } = useOrg();
  const orgSlug = currentOrg?.slug;

  const cards: Card[] = [
    { href: '/app/admin/llm-models', Icon: CpuChipIcon, label: 'LLM Catalog', desc: 'Edit the provider/model pairs available in the Mock MCP picker and ListModels.' },
    { href: '/app/admin/marketing', Icon: MegaphoneIcon, label: 'Marketing', desc: 'Landing-page signups: beta/promo caps, open/close switches, and the capture list.' },
    { href: '/app/admin/mcp-custom-scopes', Icon: WrenchScrewdriverIcon, label: 'MCP endpoints', desc: 'Edit the default Tobor Locker package every account gets, or add extra endpoints.' },
    { href: '/app/admin/mcp-entities', Icon: BookOpenIcon, label: 'MCP entities', desc: 'Versioned prompts plus resources/resource templates served over the prompts/resources MCP groups.' },
    { href: '/app/admin/media-providers', Icon: FilmIcon, label: 'Media Providers', desc: 'Per-org API keys, models, and toggles for image/voice/music asset generation.' },
    { href: '/app/admin/github', Icon: CodeBracketIcon, label: 'GitHub Config', desc: 'Org-scoped GitHub tokens, repos, and per-group repo access grants.' },
    ...(orgSlug
      ? [{ href: `/app/${orgSlug}/mock-mcp/llms`, Icon: LinkIcon as Icon, label: 'LLM Connections', desc: 'Reusable provider/model/endpoint/key connections each mock MCP can use.' }]
      : []),
    { href: '/app/admin/users', Icon: UsersIcon, label: 'Users', desc: 'System-wide user list and role assignment.' },
    { href: '/app/admin/orgs', Icon: BuildingOfficeIcon, label: 'Organizations', desc: 'Browse all organizations and their members.' },
    { href: '/app/admin/authz', Icon: KeyIcon, label: 'API Keys', desc: 'Mint and revoke long-lived MCP API keys, and build setup commands.' },
    { href: '/app/admin/oauth-clients', Icon: LinkIcon, label: 'OAuth Clients', desc: 'Registered MCP OAuth 2.1 clients (DCR + first-party) and pairing-grant revocation.' },
  ];

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">Admin</h1>
        </div>
        <p className="sg-page-intro">
          Configuration that drives mock MCPs, asset generation, and integrations. Available to
          admins and owners.
        </p>

        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))',
            gap: '1rem',
            marginTop: '1.25rem',
          }}
        >
          {cards.map((c) => (
            <Link
              key={c.href}
              href={c.href}
              style={{
                display: 'flex',
                gap: '0.75rem',
                padding: '1rem',
                border: '1px solid var(--border, #e5e5e5)',
                borderRadius: '10px',
                textDecoration: 'none',
                color: 'inherit',
                background: 'var(--surface, #fff)',
              }}
            >
              <c.Icon style={{ width: 24, height: 24, flex: '0 0 24px', opacity: 0.8 }} />
              <span>
                <span style={{ display: 'block', fontWeight: 600, marginBottom: '0.25rem' }}>{c.label}</span>
                <span style={{ display: 'block', fontSize: '0.8125rem', opacity: 0.7, lineHeight: 1.4 }}>{c.desc}</span>
              </span>
            </Link>
          ))}
        </div>
      </main>
    </div>
  );
}
