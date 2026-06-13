"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { signOut, useSession } from "next-auth/react";
import styles from "./sidebar.module.css";

const NAV = [
  { section: "Overview", items: [
    { href: "/dashboard", icon: "◫", label: "Dashboard" },
  ]},
  { section: "Workspaces", items: [
    { href: "/projects", icon: "▦", label: "Projects" },
    { href: "/settings", icon: "◉", label: "Sessions & Keys" },
  ]},
  { section: "Content", items: [
    { href: "/tickets", icon: "☐", label: "Tickets" },
    { href: "/assets", icon: "◈", label: "Assets" },
  ]},
  { section: "Collaboration", items: [
    { href: "/chat", icon: "▬", label: "Chat" },
    { href: "/reviews", icon: "◎", label: "Reviews" },
  ]},
];

export default function Sidebar() {
  const pathname = usePathname();
  const { data: session } = useSession();

  return (
    <nav className={styles.sidebar}>
      <div className={styles.brand}>
        <div className={styles.logo}>T</div>
        <span className={styles.name}>Tobor Locker</span>
      </div>

      {NAV.map(({ section, items }) => (
        <div key={section} className={styles.section}>
          <div className={styles.sectionTitle}>{section}</div>
          {items.map(({ href, icon, label }) => (
            <Link
              key={href}
              href={href}
              className={`${styles.navItem} ${pathname.startsWith(href) ? styles.active : ""}`}
            >
              <span className={styles.navIcon}>{icon}</span>
              {label}
            </Link>
          ))}
        </div>
      ))}

      <div className={styles.footer}>
        {session && (
          <div className={styles.user}>
            <div className={styles.avatar}>
              {(session.user?.name || session.user?.email || "?").slice(0, 2).toUpperCase()}
            </div>
            <div className={styles.userInfo}>
              <div className={styles.userName}>{session.user?.name || session.user?.email}</div>
              <button onClick={() => signOut()} className={styles.signOut}>Sign out</button>
            </div>
          </div>
        )}
      </div>
    </nav>
  );
}
