import type { Metadata } from "next";
import Link from "next/link";
import { NPL_REFERENCE, nplRefGroups } from "@/lib/npl-reference";
import { ReferenceSidebar } from "@/components/reference-sidebar";

export const metadata: Metadata = {
  title: "NPL tag reference",
  description:
    "Every npl-* tag in Noizu Prompt Lingua — declarations, reasoning pumps, evaluation blocks, runtime flags, and prompt sections — with attributes and examples.",
  alternates: { canonical: "/reference" },
};

export default function ReferenceIndex() {
  const groups = nplRefGroups();
  return (
    <div className="content">
      <div className="tl-refnav-wrap">
        <ReferenceSidebar />
        <div className="tl-landing">
          <section className="tl-section" aria-labelledby="ref-title">
            <h1 className="tl-section__title" id="ref-title">
              NPL tag reference
            </h1>
            <p className="tl-section__lede">
              The <code>&lt;npl-*&gt;</code> tags of Noizu Prompt Lingua:{" "}
              {NPL_REFERENCE.length} tags covering declarations, reasoning pumps,
              evaluation blocks, runtime control, and prompt sections. Each page
              gives the tag&rsquo;s purpose, attributes, and a short example.
            </p>
            <p className="tl-section__note">
              SemText renders these tags as live components — every tag page links
              to its rendered-form reference on semtext.dev.
            </p>
          </section>
          {groups.map(({ group, entries }) => (
            <section
              key={group}
              className="tl-section"
              aria-labelledby={`ref-${group.replace(/[^a-z]+/gi, "-")}`}
            >
              <h2
                className="tl-section__title"
                id={`ref-${group.replace(/[^a-z]+/gi, "-")}`}
              >
                {group}
              </h2>
              <div className="tl-exgrid" data-cy="npl-ref-grid">
                {entries.map((entry) => (
                  <Link
                    key={entry.tag}
                    href={`/reference/${entry.tag}`}
                    className="tl-ex"
                    data-cy={`npl-ref-${entry.tag}`}
                  >
                    <header className="tl-ex__head">
                      <h3 className="tl-ref-tag">
                        &lt;{entry.tag}&gt;
                      </h3>
                      <span className="tl-ex__src">{entry.name}</span>
                    </header>
                    <p className="tl-gallery__brief">{entry.summary}</p>
                  </Link>
                ))}
              </div>
            </section>
          ))}
        </div>
      </div>
    </div>
  );
}
