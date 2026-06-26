'use client';

import Link from 'next/link';
import { useSidebar } from '@/context/sidebar';
import { useAppNav } from '@/components/app-nav';

export function AppSidebar() {
  const { collapsed } = useSidebar();
  const items = useAppNav();

  return (
    <nav className={`app-sidebar${collapsed ? ' is-collapsed' : ''}`} aria-label="Primary">
      <div className="app-sidebar__list">
        {items.map((item, i) => {
          const firstAdmin = item.admin && !items[i - 1]?.admin;
          return (
            <div key={item.label} style={{ display: 'contents' }}>
              {firstAdmin && (
                <div className="app-sidebar__section" aria-hidden={collapsed}>
                  <span className="app-sidebar__section-label">Admin</span>
                </div>
              )}
              <Link
                href={item.href}
                className={`app-sidebar__item${item.active ? ' is-active' : ''}`}
                title={collapsed ? item.label : undefined}
              >
                <item.Icon className="app-sidebar__glyph" />
                <span className="app-sidebar__label">{item.label}</span>
              </Link>
            </div>
          );
        })}
      </div>
    </nav>
  );
}
