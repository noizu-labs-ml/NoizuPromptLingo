interface KnowledgeBaseLogoProps {
  size?: number;
  className?: string;
}

export function KnowledgeBaseLogo({ size = 24, className }: KnowledgeBaseLogoProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 200 200"
      width={size}
      height={size}
      role="img"
      aria-label="Knowledge Base"
      className={className}
    >
      {/* Book: left page */}
      <path d="M 98,88 L 32,80 L 32,164 L 98,164 Z" fill="currentColor" />

      {/* Book: right page (slightly transparent for depth) */}
      <path d="M 102,88 L 168,80 L 168,164 L 102,164 Z" fill="currentColor" opacity="0.7" />

      {/* Spine */}
      <line
        x1="100" y1="78" x2="100" y2="166"
        className="stroke-accent"
        strokeWidth="2.5"
        strokeLinecap="round"
      />

      {/* Graph connections */}
      <line x1="55" y1="52" x2="100" y2="28" className="stroke-accent" strokeWidth="2" strokeLinecap="round" />
      <line x1="145" y1="52" x2="100" y2="28" className="stroke-accent" strokeWidth="2" strokeLinecap="round" />
      <line x1="55" y1="52" x2="145" y2="52" className="stroke-accent" strokeWidth="2" strokeLinecap="round" />

      {/* Graph nodes */}
      <circle cx="55" cy="52" r="7" className="fill-accent" />
      <circle cx="100" cy="28" r="7" className="fill-accent" />
      <circle cx="145" cy="52" r="7" className="fill-accent" />
    </svg>
  );
}
