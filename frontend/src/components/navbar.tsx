"use client";

import Link from "next/link";
import { Menu, MenuButton, MenuItems, MenuItem } from "@headlessui/react";
import { Bars3Icon } from "@heroicons/react/24/outline";
import { useAuth } from "@/context/auth";
import { useOrg } from "@/context/org";
import { useSidebar } from "@/context/sidebar";
import { MobileNav } from "@/components/mobile-nav";
import { OrgProjectSwitcher } from "@/components/org-project-switcher";
import { CookieSettingsButton, useCookieConsent } from "@/components/cookie-consent";

export function Navbar() {
  const { user, loading, logout } = useAuth();
  const { currentOrg, currentProject } = useOrg();
  const { toggle } = useSidebar();
  const { openSettings } = useCookieConsent();
  const displayName = user ? user.user_name || user.handle || user.email : "";
  const isAdmin = user?.role === "admin" || user?.role === "owner";

  return (
    <nav className="sg-navbar">
      <div className="sg-navbar__inner">
        <div className="sg-navbar__left">
          {user && (
            <button
              type="button"
              className="sg-navbar__burger nav-rail-trigger"
              onClick={toggle}
              aria-label="Toggle sidebar"
              title="Toggle sidebar"
            >
              <Bars3Icon />
            </button>
          )}
          <div className="sg-navbar__brand tl-brand">
            {user ? (
              <OrgProjectSwitcher />
            ) : (
              <svg className="tl-brand__mark" width="26" height="26" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
                <rect x="1" y="1" width="30" height="30" rx="6" stroke="var(--border-strong)" strokeWidth="2" />
                <path d="M8 22V10L13 18L18 10V22" stroke="var(--red)" strokeWidth="2.5" fill="none" strokeLinejoin="round" strokeLinecap="round" />
                <circle cx="24" cy="21" r="2.5" fill="var(--blue)" />
              </svg>
            )}
            <Link href="/" className="tl-brand__name">Tobor Locker</Link>
            <span className="tl-brand__badge">MCP</span>
            {user && (currentProject || currentOrg) && (
              <span className="tl-brand__scope" title="Active scope">
                {currentOrg?.name}
                {currentProject && <span className="tl-brand__scope-proj"> / {currentProject.name}</span>}
              </span>
            )}
          </div>
        </div>
        <div className="sg-navbar__links">
          {loading ? null : user ? (
            <>
              <MobileNav />
              <Menu>
                <MenuButton className="menu-btn sg-navbar__user">{displayName}</MenuButton>
                <MenuItems anchor="bottom end" className="menu-items">
                  <MenuItem as={Link} href="/app/profile" className="menu-item">
                    Edit profile
                  </MenuItem>
                  {isAdmin && (
                    <MenuItem as={Link} href="/app/admin/users" className="menu-item">
                      Admin
                    </MenuItem>
                  )}
                  {isAdmin && (
                    <MenuItem as={Link} href="/app/admin/github" className="menu-item">
                      GitHub
                    </MenuItem>
                  )}
                  <div className="menu-sep" />
                  <MenuItem as="button" onClick={openSettings} className="menu-item">
                    Cookie settings
                  </MenuItem>
                  <div className="menu-sep" />
                  <MenuItem as="button" onClick={logout} className="menu-item">
                    Log out
                  </MenuItem>
                </MenuItems>
              </Menu>
            </>
          ) : (
            <>
              <CookieSettingsButton />
              <a href="/login" className="sg-btn sg-btn--black sg-btn--sm">
                Sign In
              </a>
            </>
          )}
        </div>
      </div>
    </nav>
  );
}
