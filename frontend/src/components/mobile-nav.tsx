'use client';

import Link from 'next/link';
import { useEffect, useState } from 'react';
import { Menu, MenuButton, MenuItems, MenuItem } from '@headlessui/react';
import { Bars3Icon, ChevronDownIcon } from '@heroicons/react/24/outline';
import { useAppNavSections, type ResolvedNavSection } from '@/components/app-nav';

export function MobileNav() {
  const sections = useAppNavSections();

  return (
    <Menu>
      <MenuButton className="nav-mobile-trigger nav-mobile-btn" aria-label="Open navigation">
        <Bars3Icon className="nav-mobile-btn__icon" />
        <span>Menu</span>
      </MenuButton>
      <MenuItems anchor="bottom end" className="menu-items nav-menu">
        {sections.map((section) => (
          <MobileNavSection key={section.id} section={section} />
        ))}
      </MenuItems>
    </Menu>
  );
}

function MobileNavSection({ section }: { section: ResolvedNavSection }) {
  const [open, setOpen] = useState(Boolean(section.defaultOpen || section.active));

  useEffect(() => {
    if (section.active) setOpen(true);
  }, [section.active]);

  return (
    <div className={`nav-menu-section${section.active ? ' is-active' : ''}`}>
      <button
        type="button"
        className={`nav-menu-section__toggle${open ? ' is-open' : ''}`}
        aria-expanded={open}
        onClick={(event) => {
          event.preventDefault();
          event.stopPropagation();
          setOpen((current) => !current);
        }}
      >
        <section.Icon className="nav-menu-section__icon" />
        <span>{section.label}</span>
        <ChevronDownIcon className="nav-menu-section__chevron" />
      </button>
      {open && (
        <div className="nav-menu-section__items">
          {section.items.map((item) => (
            <MenuItem
              key={item.href}
              as={Link}
              href={item.href}
              className={`menu-item nav-menu-item${item.active ? ' menu-item--active' : ''}`}
              aria-current={item.active ? 'page' : undefined}
            >
              <item.Icon className="nav-menu-item__icon" />
              {item.label}
            </MenuItem>
          ))}
        </div>
      )}
    </div>
  );
}
