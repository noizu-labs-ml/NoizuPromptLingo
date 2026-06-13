"use client";

import { useState, useEffect } from "react";
import {
  readAllSectionState,
  writeSectionState,
  groupAnchor,
  sectionAnchor,
} from "@styleguide-engine/lib/section-cookie";
import { toast } from "sonner";

interface ContentItem {
  number: string;
  id?: string;
  title: string;
}

interface Props {
  label: string;
  contents: ContentItem[];
  defaultOpen?: boolean;
  children: React.ReactNode;
}

export function SectionGroup({ label, contents, defaultOpen = true, children }: Props) {
  const key = `g-${groupAnchor(label)}`;
  const anchor = groupAnchor(label);
  const [open, setOpen] = useState(defaultOpen);

  // On mount: restore from cookie, then check hash
  useEffect(() => {
    const stored = readAllSectionState();
    const hash = window.location.hash.slice(1);

    // Force open if hash targets this group or any child section
    const targeted =
      hash === anchor ||
      contents.some((item) => hash === sectionAnchor(item.id ?? item.number));

    if (targeted) {
      setOpen(true);
      writeSectionState(key, true);
    } else if (key in stored) {
      setOpen(stored[key]);
    }
  }, [key, anchor, contents]);

  function toggle() {
    setOpen((prev) => {
      const next = !prev;
      writeSectionState(key, next);
      return next;
    });
  }

  return (
    <div className="sg-group" id={anchor}>
      <div className="sg-group-header" onClick={toggle}>
        <span className="sg-group-label">{label}</span>
        <div className="sg-group-contents">
          {contents.map((item) => (
            <a
              key={item.number}
              href={`#${sectionAnchor(item.id ?? item.number)}`}
              className="sg-group-content-item"
              onClick={(e) => {
                e.stopPropagation();
                const anchor = sectionAnchor(item.id ?? item.number);
                const url = `${window.location.origin}${window.location.pathname}#${anchor}`;
                navigator.clipboard.writeText(url);
                toast.info(`URL set to anchor #${anchor}`);
                // ensure group is open so anchor is visible
                if (!open) {
                  setOpen(true);
                  writeSectionState(key, true);
                }
              }}
              style={{ textDecoration: "none", color: "inherit" }}
            >
              <span className="sg-group-item-num">{item.number}</span>
              {item.title}
            </a>
          ))}
        </div>
        <div className="sg-group-line" />
        <span
          className="sg-group-toggle"
          style={{ transform: open ? "rotate(90deg)" : "rotate(0deg)" }}
        >
          &#9654;
        </span>
      </div>
      {open && <div>{children}</div>}
      <div className="hr section" />
    </div>
  );
}
