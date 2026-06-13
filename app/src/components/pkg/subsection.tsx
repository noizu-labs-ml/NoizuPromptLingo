"use client";

import { useState } from "react";
import { toast } from "sonner";

interface Props {
  id: string;
  title: string;
  defaultOpen?: boolean;
  children: React.ReactNode;
}

export function Subsection({ id, title, defaultOpen = true, children }: Props) {
  const [open, setOpen] = useState(defaultOpen);

  return (
    <section id={id} className="sg-subsection-wrapper scroll-mt-[var(--space-4)]" data-search-name={id} data-search-title={title}>
      <div className="hr subsection sg-subsection-hr" />
      <div
        className="cursor-pointer list-none flex items-center gap-[var(--space-1)] select-none sg-section-head"
        onClick={() => setOpen((p) => !p)}
      >
        <svg
          width="12" height="12" viewBox="0 0 12 12" fill="none"
          className="shrink-0 transition-transform"
          style={{ transform: open ? "rotate(90deg)" : "rotate(0deg)" }}
        >
          <path d="M4 2l4 4-4 4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
        {title}
        <a
          href={`#${id}`}
          onClick={(e) => {
            e.preventDefault();
            e.stopPropagation();
            const url = `${window.location.origin}${window.location.pathname}#${id}`;
            window.history.replaceState(null, "", `#${id}`);
            navigator.clipboard.writeText(url);
            toast.info(`URL set to anchor #${id}`);
          }}
          className="subsection-anchor sg-anchor-heading-icon text-primary"
        >
          #
        </a>
      </div>
      {open ? (
        <div className="pt-[var(--space-2)]">
          {children}
        </div>
      ) : (
        <div className="sg-subsection-collapse" onClick={() => setOpen(true)}>
          {children}
          <div className="sg-subsection-collapse-fade" />
        </div>
      )}
    </section>
  );
}
