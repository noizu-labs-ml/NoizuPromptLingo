import Link from "next/link";

import { NPL_REFERENCE, nplRefGroups } from "@/lib/npl-reference";

// Grouped tag index for /reference, mirroring semtext.dev's reference
// sidebar (annotate 594ba6f6): one heading per group, flat tag links under
// it. Desktop gets a sticky always-open rail; mobile collapses the same nav
// into a native <details> — no client JS.

function TagNav({ current }: { current?: string }) {
  return (
    <nav className="tl-refnav__nav" aria-label="Reference tags">
      {nplRefGroups().map(({ group, entries }) => (
        <div key={group} className="tl-refnav__group">
          <h3 className="tl-refnav__heading">{group}</h3>
          <ul className="tl-refnav__list">
            {entries.map((entry) => (
              <li key={entry.tag}>
                <Link
                  href={`/reference/${entry.tag}`}
                  className="tl-refnav__link"
                  aria-current={current === entry.tag ? "page" : undefined}
                >
                  &lt;{entry.tag}&gt;
                </Link>
              </li>
            ))}
          </ul>
        </div>
      ))}
    </nav>
  );
}

export function ReferenceSidebar({ current }: { current?: string }) {
  return (
    <>
      <aside className="tl-refnav tl-refnav--desktop" aria-label="Reference tag index">
        <TagNav current={current} />
      </aside>
      <details className="tl-refnav tl-refnav--mobile">
        <summary className="tl-refnav__summary">
          All {NPL_REFERENCE.length} tags
        </summary>
        <TagNav current={current} />
      </details>
    </>
  );
}
