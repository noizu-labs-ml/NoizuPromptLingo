"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Logomark } from "@/components/Logo";

const navLinks = [
  { href: "/", label: "Home" },
  { href: "/projects", label: "Projects" },
  { href: "/papers", label: "Papers" },
  { href: "/#services", label: "Services" },
  { href: "/#testimonials", label: "Testimonials" },
  { href: "https://therobotlives.com/", label: "Blog", external: true },
  { href: "/#contact", label: "Contact" },
];

export function Navbar() {
  const [mobileOpen, setMobileOpen] = useState(false);
  const pathname = usePathname();
  const isHome = pathname === "/";

  return (
    <header className="fixed top-0 left-0 right-0 z-50">
      <nav className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="flex h-14 sm:h-16 items-center justify-between mt-2 rounded-2xl glass px-4 sm:px-6">
          <div className="flex items-center gap-3">
            {/* Back button on inner pages */}
            {!isHome && (
              <Link
                href="/"
                className="md:hidden flex items-center justify-center w-8 h-8 rounded-lg text-zinc-400 hover:text-white hover:bg-white/[0.05] transition-colors mr-1"
                aria-label="Back to home"
              >
                <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M10.5 19.5L3 12m0 0l7.5-7.5M3 12h18" />
                </svg>
              </Link>
            )}
            <Link href="/" className="flex items-center gap-3">
              <Logomark className="h-8 w-8" />
              <div className="flex items-baseline gap-1.5">
                <span className="font-semibold text-white text-lg tracking-tight">
                  noizu
                </span>
                <span className="text-sm font-medium text-gold-400">Labs</span>
              </div>
            </Link>
          </div>

          {/* Desktop nav */}
          <div className="hidden md:flex items-center gap-1">
            {navLinks.map((link) => {
              const isActive = link.href === pathname || (link.href !== "/" && pathname.startsWith(link.href));
              return link.external ? (
                <a
                  key={link.href}
                  href={link.href}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="px-4 py-2 text-sm text-zinc-300 hover:text-white transition-colors rounded-lg hover:bg-white/[0.05]"
                >
                  {link.label}
                </a>
              ) : (
                <Link
                  key={link.href}
                  href={link.href}
                  className={`px-4 py-2 text-sm transition-colors rounded-lg hover:bg-white/[0.05] ${
                    isActive ? "text-gold-400" : "text-zinc-300 hover:text-white"
                  }`}
                >
                  {link.label}
                </Link>
              );
            })}
            <a
              href="https://github.com/noizu-labs"
              target="_blank"
              rel="noopener noreferrer"
              className="ml-2 px-4 py-2 text-sm bg-gold-400 hover:bg-gold-300 text-zinc-950 font-medium rounded-lg transition-colors"
            >
              GitHub
            </a>
          </div>

          {/* Mobile toggle */}
          <button
            onClick={() => setMobileOpen(!mobileOpen)}
            className="md:hidden p-2 text-zinc-400 hover:text-white"
            aria-label="Toggle menu"
          >
            <svg
              className="w-6 h-6"
              fill="none"
              viewBox="0 0 24 24"
              strokeWidth={1.5}
              stroke="currentColor"
            >
              {mobileOpen ? (
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M6 18L18 6M6 6l12 12"
                />
              ) : (
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M3.75 9h16.5m-16.5 6.75h16.5"
                />
              )}
            </svg>
          </button>
        </div>

        {/* Mobile menu */}
        <AnimatePresence>
          {mobileOpen && (
            <motion.div
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              className="md:hidden mt-2 rounded-2xl glass p-4"
            >
              {navLinks.map((link) => {
                const isActive = link.href === pathname || (link.href !== "/" && pathname.startsWith(link.href));
                return link.external ? (
                  <a
                    key={link.href}
                    href={link.href}
                    target="_blank"
                    rel="noopener noreferrer"
                    onClick={() => setMobileOpen(false)}
                    className="block px-4 py-3 text-sm text-zinc-300 hover:text-white transition-colors rounded-lg hover:bg-white/[0.05]"
                  >
                    {link.label}
                  </a>
                ) : (
                  <Link
                    key={link.href}
                    href={link.href}
                    onClick={() => setMobileOpen(false)}
                    className={`block px-4 py-3 text-sm transition-colors rounded-lg hover:bg-white/[0.05] ${
                      isActive ? "text-gold-400" : "text-zinc-300 hover:text-white"
                    }`}
                  >
                    {link.label}
                  </Link>
                );
              })}
              <a
                href="https://github.com/noizu-labs"
                target="_blank"
                rel="noopener noreferrer"
                className="block mt-2 px-4 py-3 text-sm text-center bg-gold-400 hover:bg-gold-300 text-zinc-950 font-medium rounded-lg transition-colors"
              >
                GitHub
              </a>
            </motion.div>
          )}
        </AnimatePresence>
      </nav>
    </header>
  );
}
