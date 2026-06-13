'use client'

export interface BreadcrumbItem {
  label: string;
  href?: string;
}

export interface BreadcrumbsProps {
  items: BreadcrumbItem[];
  separator?: 'slash' | 'chevron';
  className?: string;
}

function Separator({ type }: { type: 'slash' | 'chevron' }) {
  if (type === 'chevron') {
    return (
      <svg className="twp-breadcrumb-separator" width="12" height="12" viewBox="0 0 12 12" fill="none" aria-hidden="true">
        <path d="M4 2l4 4-4 4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
      </svg>
    );
  }
  return <span className="twp-breadcrumb-separator" aria-hidden="true">/</span>;
}

export function Breadcrumbs({ items, separator = 'slash', className = '' }: BreadcrumbsProps) {
  return (
    <nav className={['twp-breadcrumbs', className].filter(Boolean).join(' ')} aria-label="Breadcrumb">
      <ol style={{ display: 'contents' }}>
        {items.map((item, i) => {
          const isLast = i === items.length - 1;
          return (
            <li key={i} style={{ display: 'contents' }}>
              {isLast ? (
                <span className="twp-breadcrumb twp-breadcrumb-active" aria-current="page">{item.label}</span>
              ) : item.href ? (
                <a className="twp-breadcrumb" href={item.href}>{item.label}</a>
              ) : (
                <span className="twp-breadcrumb">{item.label}</span>
              )}
              {!isLast && <Separator type={separator} />}
            </li>
          );
        })}
      </ol>
    </nav>
  );
}

const DEMO_ITEMS: BreadcrumbItem[] = [
  { label: 'Home', href: '/' },
  { label: 'Components', href: '/components' },
  { label: 'Breadcrumbs' },
];

const DEEP_ITEMS: BreadcrumbItem[] = [
  { label: 'Home', href: '/' },
  { label: 'Products', href: '/products' },
  { label: 'Electronics', href: '/products/electronics' },
  { label: 'Laptops' },
];

export function BreadcrumbsShowcase() {
  return (
    <div className="twp-showcase">
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">slash separator</div>
        <div className="twp-showcase-row">
          <Breadcrumbs items={DEMO_ITEMS} separator="slash" />
        </div>
      </div>
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">chevron separator</div>
        <div className="twp-showcase-row">
          <Breadcrumbs items={DEMO_ITEMS} separator="chevron" />
        </div>
      </div>
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">deep hierarchy</div>
        <div className="twp-showcase-row">
          <Breadcrumbs items={DEEP_ITEMS} separator="chevron" />
        </div>
      </div>
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">single item</div>
        <div className="twp-showcase-row">
          <Breadcrumbs items={[{ label: 'Home' }]} />
        </div>
      </div>
    </div>
  );
}
