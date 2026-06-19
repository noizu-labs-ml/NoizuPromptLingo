"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState, useRef, useEffect } from "react";
import { useProject } from "./project-context";
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
  const { projects, current, select } = useProject();
  const [pickerOpen, setPickerOpen] = useState(false);
  const pickerRef = useRef(null);

  useEffect(() => {
    function handleClick(e) {
      if (pickerRef.current && !pickerRef.current.contains(e.target)) setPickerOpen(false);
    }
    document.addEventListener("mousedown", handleClick);
    return () => document.removeEventListener("mousedown", handleClick);
  }, []);

  return (
    <nav className={styles.sidebar}>
      <div className={styles.brand} ref={pickerRef}>
        <div className={styles.brandRow}>
          <div className={styles.logo}>T</div>
          <span className={styles.name}>Tobor Locker</span>
        </div>
        <button className={styles.projectBtn} onClick={() => setPickerOpen(!pickerOpen)}>
          <span className={styles.projectLabel}>
            {current ? current.name : "Select project…"}
          </span>
          <span className={styles.projectChevron}>{pickerOpen ? "▴" : "▾"}</span>
        </button>
        {pickerOpen && (
          <div className={styles.projectPicker}>
            {projects.length === 0 && (
              <div className={styles.pickerEmpty}>No projects</div>
            )}
            {projects.map((p) => (
              <button
                key={p.slug}
                className={`${styles.pickerItem} ${current?.slug === p.slug ? styles.pickerActive : ""}`}
                onClick={() => { select(p); setPickerOpen(false); }}
              >
                <span className={styles.pickerName}>{p.name}</span>
                <span className={styles.pickerSlug}>{p.slug}</span>
              </button>
            ))}
          </div>
        )}
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
    </nav>
  );
}
