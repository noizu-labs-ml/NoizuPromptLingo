"use client";
import { useState, useRef, useEffect } from "react";
import { signOut, useSession } from "next-auth/react";
import Link from "next/link";
import styles from "./topbar.module.css";

export default function Topbar() {
  const { data: session } = useSession();
  const [open, setOpen] = useState(false);
  const ref = useRef(null);

  useEffect(() => {
    function handleClick(e) {
      if (ref.current && !ref.current.contains(e.target)) setOpen(false);
    }
    document.addEventListener("mousedown", handleClick);
    return () => document.removeEventListener("mousedown", handleClick);
  }, []);

  if (!session) return null;

  const name = session.user?.name || session.user?.email || "User";
  const initials = name.slice(0, 2).toUpperCase();

  return (
    <header className={styles.topbar}>
      <div />
      <div className={styles.userArea} ref={ref}>
        <button className={styles.userBtn} onClick={() => setOpen(!open)}>
          <span className={styles.userName}>{name}</span>
          <span className={styles.avatar}>{initials}</span>
          <span className={styles.chevron}>{open ? "▴" : "▾"}</span>
        </button>
        {open && (
          <div className={styles.dropdown}>
            <div className={styles.dropdownHeader}>
              <div className={styles.dropdownName}>{name}</div>
              <div className={styles.dropdownEmail}>{session.user?.email}</div>
            </div>
            <div className={styles.dropdownDivider} />
            <Link href="/profile" className={styles.dropdownItem} onClick={() => setOpen(false)}>
              Edit Profile
            </Link>
            <button className={styles.dropdownItem} onClick={() => signOut()}>
              Sign out
            </button>
          </div>
        )}
      </div>
    </header>
  );
}
