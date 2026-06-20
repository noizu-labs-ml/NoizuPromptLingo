'use client';

import Link from 'next/link';
import { Menu, MenuButton, MenuItems, MenuItem } from '@headlessui/react';
import { Bars3Icon } from '@heroicons/react/24/outline';
import { useAppNav } from '@/components/app-nav';

export function MobileNav() {
  const items = useAppNav();

  return (
    <Menu>
      <MenuButton className="nav-mobile-trigger nav-mobile-btn" aria-label="Open navigation">
        <Bars3Icon className="nav-mobile-btn__icon" />
        <span>Menu</span>
      </MenuButton>
      <MenuItems anchor="bottom end" className="menu-items">
        {items.map((item) => (
          <MenuItem
            key={item.href}
            as={Link}
            href={item.href}
            className={`menu-item nav-menu-item${item.active ? ' menu-item--active' : ''}`}
          >
            <item.Icon className="nav-menu-item__icon" />
            {item.label}
          </MenuItem>
        ))}
      </MenuItems>
    </Menu>
  );
}
