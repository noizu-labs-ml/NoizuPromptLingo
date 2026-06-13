import Link from "next/link";
import { StyleGuideBtn, StyleGuideCard, StyleGuideCardGrid } from "@the-robot-lives/styleguide/components";
import { products, categories } from "@/lib/products";

export default function PortfolioPage() {
  const grouped = new Map<string, typeof products>();
  for (const cat of categories) {
    grouped.set(cat, products.filter((p) => p.category === cat));
  }

  return (
    <div className="content">
      <main>
        <h1 className="sg-page-title">The Portfolio</h1>
        <p className="sg-page-intro">
          {products.length} products across {categories.length} categories.
        </p>

        {/* Category filter row */}
        <div style={{ marginTop: "var(--space-8)" }} className="flex flex-wrap gap-4">
          {["All", ...categories].map((label, i) => (
            <span
              key={label}
              className={`rounded-full px-5 py-2 text-xs font-[family-name:var(--font-mono)] uppercase tracking-widest border cursor-default transition-colors ${
                i === 0
                  ? "border-[var(--text-link)] text-[var(--text-link)] bg-[var(--surface-accent)]"
                  : "border-[var(--border)] text-[var(--text-muted)] hover:border-[var(--text-link)] hover:text-[var(--text-link)]"
              }`}
            >
              {label}
            </span>
          ))}
        </div>

        {/* Product grid grouped by category */}
        <div style={{ marginTop: "var(--space-10)" }} className="space-y-28">
          {[...grouped.entries()].map(([category, items]) => (
            <section key={category}>
              {/* Category header with extending line */}
              <div className="flex items-center gap-6" style={{ marginBottom: "var(--space-8)" }}>
                <span className="font-[family-name:var(--font-mono)] text-xs uppercase tracking-widest text-[var(--text-muted)] whitespace-nowrap">
                  {category}
                </span>
                <div className="h-px flex-1 bg-[var(--border)]" />
                <span className="font-[family-name:var(--font-mono)] text-xs text-[var(--text-muted)]">
                  {items.length}
                </span>
              </div>

              <StyleGuideCardGrid>
                {items.map((p) => (
                  <Link key={p.domain} href={`/portfolio/${p.domain}`} className="block">
                    <StyleGuideCard
                      title={p.name}
                      body={p.oneLiner}
                    />
                    <span className="mt-3 block font-[family-name:var(--font-mono)] text-xs text-[var(--text-link)]">
                      {p.domain} →
                    </span>
                  </Link>
                ))}
              </StyleGuideCardGrid>
            </section>
          ))}
        </div>

        {/* CTA */}
        <div className="mt-20 button-row sg-page-cta">
          <Link href="/">
            <StyleGuideBtn variant="outline" label="← Back to Home" />
          </Link>
        </div>
      </main>
    </div>
  );
}
