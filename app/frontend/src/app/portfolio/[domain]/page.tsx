import Link from "next/link";
import { StyleGuideBtn, StyleGuideCard, StyleGuideStatusIndicator } from "@the-robot-lives/styleguide/components";
import { products, getProductByDomain } from "@/lib/products";
import { notFound } from "next/navigation";

export function generateStaticParams() {
  return products.map((p) => ({ domain: p.domain }));
}

type Props = {
  params: Promise<{ domain: string }>;
};

export default async function ProductPage({ params }: Props) {
  const { domain } = await params;
  const product = getProductByDomain(domain);

  if (!product) {
    notFound();
  }

  return (
    <div className="content content--article">
      <main>
        {/* Back link */}
        <Link
          href="/portfolio"
          className="text-[var(--text-link)] font-[family-name:var(--font-mono)] text-sm hover:underline"
        >
          &larr; Back to Portfolio
        </Link>

        {/* Category tag */}
        <span className="mt-8 block font-[family-name:var(--font-mono)] text-xs uppercase tracking-widest text-[var(--text-muted)]">
          {product.category}
        </span>

        {/* Product name */}
        <h1 className="sg-page-title mt-3">{product.name}</h1>

        {/* Domain link */}
        <a
          href={`https://${product.domain}`}
          target="_blank"
          rel="noopener noreferrer"
          className="mt-2 inline-block font-[family-name:var(--font-mono)] text-sm text-[var(--text-link)] hover:underline"
        >
          {product.domain} ↗
        </a>

        {/* One-liner */}
        <p className="sg-page-intro mt-6">{product.oneLiner}</p>

        {/* Status + info row */}
        <div className="mt-8 flex flex-wrap gap-4 items-center">
          <span className="inline-flex items-center gap-2 rounded-md border border-[var(--info)] bg-[var(--surface-accent)] px-3 py-1.5 font-[family-name:var(--font-mono)] text-xs uppercase tracking-widest text-[var(--info)]">
            ◇ Concept
          </span>
          <span className="text-[var(--text-muted)] font-[family-name:var(--font-mono)] text-xs">
            Stage 1 of 5
          </span>
        </div>

        {/* Placeholder sections */}
        <section className="mt-12 mb-8">
          <h2 className="sg-section-heading">About This Product</h2>
          <StyleGuideCard
            title="README"
            body={`Full product details for ${product.name} will be generated from its README.md at build time. For now, this is a placeholder — the product is at Concept stage.`}
          />
        </section>

        {/* CTA */}
        <div className="mt-12 button-row sg-page-cta">
          <Link href="/portfolio">
            <StyleGuideBtn variant="outline" label="← Back to Portfolio" />
          </Link>
          <a href={`https://${product.domain}`} target="_blank" rel="noopener noreferrer">
            <StyleGuideBtn variant="black" label={`Visit ${product.domain} ↗`} />
          </a>
        </div>
      </main>
    </div>
  );
}
