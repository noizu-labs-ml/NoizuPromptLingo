import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import {
  NPL_REFERENCE,
  SEMTEXT_REF_BASE,
  getNplRefEntry,
} from "@/lib/npl-reference";

type Params = { tag: string };

export function generateStaticParams(): Params[] {
  return NPL_REFERENCE.map((entry) => ({ tag: entry.tag }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<Params>;
}): Promise<Metadata> {
  const { tag } = await params;
  const entry = getNplRefEntry(tag);
  if (!entry) return { title: "Not found" };
  return {
    title: `<${entry.tag}> — NPL reference`,
    description: entry.summary,
    alternates: { canonical: `/reference/${entry.tag}` },
  };
}

export default async function NplRefPage({
  params,
}: {
  params: Promise<Params>;
}) {
  const { tag } = await params;
  const entry = getNplRefEntry(tag);
  if (!entry) notFound();

  return (
    <div className="content">
      <div className="tl-landing">
        <section className="tl-section" aria-labelledby="ref-tag-title">
          <p className="tl-ex__label">
            <Link href="/reference" className="tl-ref-back">
              ← NPL tag reference
            </Link>
          </p>
          <h1 className="tl-ref-tag" id="ref-tag-title">
            &lt;{entry.tag}&gt;
          </h1>
          <p className="tl-section__lede">{entry.summary}</p>
          {entry.body.map((para) => (
            <p key={para.slice(0, 32)} className="tl-section__lede">
              {para}
            </p>
          ))}
        </section>

        {entry.attributes.length > 0 && (
          <section className="tl-section" aria-labelledby="ref-attrs">
            <h2 className="tl-section__title" id="ref-attrs">
              Attributes
            </h2>
            <table className="tl-ref-table" data-cy="npl-ref-attrs">
              <thead>
                <tr>
                  <th scope="col">Attribute</th>
                  <th scope="col">Description</th>
                </tr>
              </thead>
              <tbody>
                {entry.attributes.map((attr) => (
                  <tr key={attr.name}>
                    <td>
                      <code className="tl-ref-code">{attr.name}</code>
                      {attr.required ? (
                        <span className="tl-ex__src"> required</span>
                      ) : null}
                    </td>
                    <td>{attr.desc}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </section>
        )}

        {entry.children && entry.children.length > 0 && (
          <section className="tl-section" aria-labelledby="ref-children">
            <h2 className="tl-section__title" id="ref-children">
              Children
            </h2>
            <ul className="tl-ref-list" data-cy="npl-ref-children">
              {entry.children.map((child) => (
                <li key={child.name}>
                  <code className="tl-ref-code">&lt;{child.name}&gt;</code> —{" "}
                  {child.desc}
                </li>
              ))}
            </ul>
          </section>
        )}

        <section className="tl-section" aria-labelledby="ref-example">
          <h2 className="tl-section__title" id="ref-example">
            Example
          </h2>
          <pre className="tl-gallery__sample" data-cy="npl-ref-example">
            <code>{entry.example}</code>
          </pre>
        </section>

        <section className="tl-section" aria-labelledby="ref-links">
          <div className="tl-ref-links">
            <a
              className="sg-btn sg-btn--outline"
              href={`${SEMTEXT_REF_BASE}/${entry.tag}`}
              target="_blank"
              rel="noreferrer"
              data-cy="npl-ref-semtext"
            >
              Rendered form on semtext.dev →
            </a>
            <a
              className="sg-btn sg-btn--outline"
              href={entry.source}
              target="_blank"
              rel="noreferrer"
            >
              Spec source →
            </a>
          </div>
        </section>
      </div>
    </div>
  );
}
