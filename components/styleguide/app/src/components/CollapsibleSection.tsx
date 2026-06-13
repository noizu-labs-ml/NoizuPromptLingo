"use client";

import { useState, useEffect, useRef } from "react";
import {
  readAllSectionState,
  writeSectionState,
  sectionAnchor,
} from "@styleguide-engine/lib/section-cookie";
import { SectionIdProvider } from "@styleguide-engine/lib/section-context";
import { toast } from "sonner";

/** Sections that have standalone pages at /section/{route} */
const STANDALONE_ROUTES: Record<string, string> = {
  "ui-elements": "hui",
  "typography": "typography",
  "color": "color",
  "design-tokens": "tokens",
  "generated-css": "css",
  "theme-config": "config",
  "snippets": "snippets",
};

interface Props {
  number: string;
  id?: string;
  title: string;
  desc: string;
  defaultOpen?: boolean;
  collapsedContent?: React.ReactNode;
  children: React.ReactNode;
}

export function CollapsibleSection({
  number,
  id,
  title,
  desc,
  defaultOpen = true,
  collapsedContent,
  children,
}: Props) {
  const stableId = id ?? number;
  const key = `s-${stableId}`;
  const anchor = sectionAnchor(stableId);
  const ref = useRef<HTMLDivElement>(null);
  const [open, setOpen] = useState(defaultOpen);
  const [mounted, setMounted] = useState(false);

  // On mount: restore from cookie (only if defaultOpen is false — sections
  // that default open always start open on fresh load)
  useEffect(() => {
    if (!defaultOpen) {
      const stored = readAllSectionState();
      if (key in stored) {
        setOpen(stored[key]);
      } else {
        writeSectionState(key, defaultOpen);
      }
    }
    setMounted(true);
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  // Scroll to section if hash targets it (group handles expanding itself)
  useEffect(() => {
    if (!mounted) return;
    const hash = window.location.hash.slice(1);
    if (hash === anchor && ref.current) {
      requestAnimationFrame(() => {
        ref.current?.scrollIntoView({ behavior: "smooth", block: "start" });
      });
    }
  }, [mounted, anchor]);

  function toggle() {
    setOpen((prev) => {
      const next = !prev;
      writeSectionState(key, next);
      return next;
    });
  }

  return (
    <div id={anchor} ref={ref} data-search-name={stableId} data-search-title={title} data-search-description={desc}>
      <div
        className="sg-section-header cursor-pointer select-none"
        onClick={toggle}
      >
        <div className="sg-section-number">{number}</div>
        <div className="sg-section-title-group flex-1">
          <h2 className="sg-section-title">
            {title}
            <span
              className="sg-anchor-heading-icon text-primary"
              aria-hidden="true"
              onClick={(e) => {
                e.stopPropagation();
                window.history.replaceState(null, "", `#${anchor}`);
                navigator.clipboard.writeText(`${window.location.origin}${window.location.pathname}#${anchor}`);
                toast.info(`URL set to anchor #${anchor}`);
              }}
            >
              #
            </span>
            {STANDALONE_ROUTES[stableId] && (
              <a
                href={`/section/${STANDALONE_ROUTES[stableId]}`}
                className="sg-anchor-heading-icon"
                title={`Open ${title} in standalone view`}
                onClick={(e) => e.stopPropagation()}
                style={{ textDecoration: "none" }}
              >
                <svg width="14" height="14" viewBox="0 0 14 14" fill="none" style={{ verticalAlign: "middle" }}>
                  <path d="M5 2H3a1 1 0 00-1 1v8a1 1 0 001 1h8a1 1 0 001-1V9" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round" strokeLinejoin="round" />
                  <path d="M8 2h4v4" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round" strokeLinejoin="round" />
                  <path d="M12 2L6.5 7.5" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
              </a>
            )}
          </h2>
          <p className="sg-section-desc">{desc}</p>
        </div>
        <span
          className="[font-size:var(--toggle-icon-size)] text-[var(--toggle-icon-color)] inline-flex items-center justify-center ml-auto self-center"
          style={{
            transition: `transform var(--toggle-transition)`,
            transform: open ? "rotate(90deg)" : "rotate(0deg)",
          }}
        >
          &#9654;
        </span>
      </div>
      <SectionIdProvider value={stableId}>
        {open ? (
          children
        ) : collapsedContent ? (
          collapsedContent
        ) : (
          <div className="sg-default-collapse" onClick={toggle}>
            {children}
            <div className="sg-default-collapse-fade" />
          </div>
        )}
      </SectionIdProvider>
    </div>
  );
}
