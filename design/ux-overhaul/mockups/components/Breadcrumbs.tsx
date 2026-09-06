import { breadcrumbLabels } from "@/lib/fixtures";

export function Breadcrumbs({ segments, basePath }: { segments: string[]; basePath: string }) {
  const crumbs = [{ label: "Home", href: basePath }].concat(
    segments.map((seg, i) => ({
      label: breadcrumbLabels[seg] ?? seg,
      href: `${basePath}/${segments.slice(0, i + 1).join("/")}`,
    }))
  );
  return (
    <nav aria-label="Breadcrumb">
      <ol style={{ display: "flex", gap: "0.35rem", listStyle: "none", padding: 0, margin: 0 }}>
        {crumbs.map((c, i) => (
          <li key={c.href}>
            {i > 0 && <span aria-hidden="true">/ </span>}
            {i === crumbs.length - 1 ? <span>{c.label}</span> : <a href={c.href}>{c.label}</a>}
          </li>
        ))}
      </ol>
    </nav>
  );
}
