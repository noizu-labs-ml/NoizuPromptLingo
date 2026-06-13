'use client'

export interface PaginationProps {
  currentPage: number;
  totalPages: number;
  onPageChange: (page: number) => void;
  className?: string;
}

function getPages(current: number, total: number): (number | 'ellipsis')[] {
  if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1);
  if (current <= 4) return [1, 2, 3, 4, 5, 'ellipsis', total];
  if (current >= total - 3) return [1, 'ellipsis', total - 4, total - 3, total - 2, total - 1, total];
  return [1, 'ellipsis', current - 1, current, current + 1, 'ellipsis', total];
}

export function Pagination({ currentPage, totalPages, onPageChange, className = '' }: PaginationProps) {
  const pages = getPages(currentPage, totalPages);

  return (
    <nav className={['twp-pagination', className].filter(Boolean).join(' ')} aria-label="Pagination">
      <button
        className="twp-pagination-prev"
        onClick={() => onPageChange(currentPage - 1)}
        disabled={currentPage <= 1}
        aria-label="Previous page"
      >
        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" aria-hidden="true">
          <path d="M10 12L6 8l4-4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      </button>

      {pages.map((page, i) =>
        page === 'ellipsis' ? (
          <span key={`ellipsis-${i}`} className="twp-pagination-ellipsis" aria-hidden="true">…</span>
        ) : (
          <button
            key={page}
            className={['twp-pagination-item', page === currentPage ? 'twp-pagination-item-active' : ''].filter(Boolean).join(' ')}
            onClick={() => onPageChange(page)}
            aria-current={page === currentPage ? 'page' : undefined}
          >
            {page}
          </button>
        )
      )}

      <button
        className="twp-pagination-next"
        onClick={() => onPageChange(currentPage + 1)}
        disabled={currentPage >= totalPages}
        aria-label="Next page"
      >
        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" aria-hidden="true">
          <path d="M6 4l4 4-4 4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      </button>
    </nav>
  );
}

export function PaginationShowcase() {
  return (
    <div className="twp-showcase">
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">start of range</div>
        <div className="twp-showcase-row">
          <Pagination currentPage={1} totalPages={10} onPageChange={() => {}} />
        </div>
      </div>
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">middle of range</div>
        <div className="twp-showcase-row">
          <Pagination currentPage={5} totalPages={10} onPageChange={() => {}} />
        </div>
      </div>
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">end of range</div>
        <div className="twp-showcase-row">
          <Pagination currentPage={10} totalPages={10} onPageChange={() => {}} />
        </div>
      </div>
      <div className="twp-showcase-group">
        <div className="twp-showcase-label">few pages</div>
        <div className="twp-showcase-row">
          <Pagination currentPage={2} totalPages={4} onPageChange={() => {}} />
        </div>
      </div>
    </div>
  );
}
