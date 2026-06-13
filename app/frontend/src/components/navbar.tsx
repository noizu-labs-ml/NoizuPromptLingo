"use client";

import Link from "next/link";
import { useAuth } from "@/context/auth";
import { Logo } from "@/components/logo";
import { VerbCycle } from "@/components/verb-cycle";

export function Navbar() {
  const { user, loading, logout } = useAuth();

  return (
    <nav className="sg-navbar">
      <div className="sg-navbar__inner" style={{ display: "grid", gridTemplateColumns: "1fr auto 1fr", alignItems: "center" }}>
        {/* Left: icon only */}
        <Link href="/" style={{ justifySelf: "start", display: "inline-flex", alignItems: "center" }}>
          <Logo size={48} showText={false} />
        </Link>

        {/* Center: hidden for now */}
        <div />

        {/* Right: nav links */}
        <div className="sg-navbar__links" style={{ justifySelf: "end" }}>
          <Link href="/portfolio" className="sg-navbar__link">Portfolio</Link>
          <Link href="/process" className="sg-navbar__link">Process</Link>
          <Link href="/about" className="sg-navbar__link">About</Link>
          <Link href="/contact" className="sg-btn sg-btn--outline sg-btn--sm">
            Contact
          </Link>
        </div>
      </div>
    </nav>
  );
}
