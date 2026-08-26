'use client';

import Link from 'next/link';
import { useEffect, useMemo, useState } from 'react';
import { ChevronDownIcon } from '@heroicons/react/24/outline';
import { useSidebar } from '@/context/sidebar';
import { useAppNavSections } from '@/components/app-nav';

export function AppSidebar() {
  const { collapsed } = useSidebar();
  const sections = useAppNavSections();
  const activeSectionIds = useMemo(
    () => sections.filter((section) => section.active).map((section) => section.id).join('|'),
    [sections],
  );
  const [openSections, setOpenSections] = useState<Record<string, boolean>>({});

  useEffect(() => {
    if (!activeSectionIds) return;
    setOpenSections((current) => {
      const next = { ...current };
      let changed = false;
      for (const id of activeSectionIds.split('|')) {
        if (id && next[id] !== true) {
          next[id] = true;
          changed = true;
        }
      }
      return changed ? next : current;
    });
  }, [activeSectionIds]);

  function toggleSection(id: string, defaultOpen?: boolean) {
    setOpenSections((current) => ({
      ...current,
      [id]: !(current[id] ?? Boolean(defaultOpen)),
    }));
  }

  return (
    <nav className={`app-sidebar${collapsed ? ' is-collapsed' : ''}`} aria-label="Primary">
      <div className="app-sidebar__list">
        {sections.map((section) => {
          const isOpen = collapsed || (openSections[section.id] ?? Boolean(section.defaultOpen || section.active));
          return (
            <div key={section.id} className={`app-sidebar__group${section.active ? ' is-active' : ''}`}>
              {!collapsed && (
                <button
                  type="button"
                  className={`app-sidebar__section-toggle${isOpen ? ' is-open' : ''}${section.active ? ' is-active' : ''}`}
                  aria-expanded={isOpen}
                  onClick={() => toggleSection(section.id, section.defaultOpen || section.active)}
                >
                  <section.Icon className="app-sidebar__section-glyph" />
                  <span className="app-sidebar__section-label">{section.label}</span>
                  <ChevronDownIcon className="app-sidebar__chevron" />
                </button>
              )}
              {isOpen && (
                <div className="app-sidebar__section-items">
                  {section.items.map((item) => (
                    <Link
                      key={item.href}
                      href={item.href}
                      className={`app-sidebar__item app-sidebar__item--nested${item.active ? ' is-active' : ''}`}
                      aria-current={item.active ? 'page' : undefined}
                      aria-label={collapsed ? item.label : undefined}
                      title={collapsed ? item.label : undefined}
                    >
                      <item.Icon className="app-sidebar__glyph" />
                      <span className="app-sidebar__label">{item.label}</span>
                    </Link>
                  ))}
                </div>
              )}
            </div>
          );
        })}
      </div>
    </nav>
  );
}
