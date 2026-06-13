import React from 'react';

interface StyleGuideCardGridProps {
  children?: React.ReactNode;
  style?: React.CSSProperties;
}

export function StyleGuideCardGrid({ children, style }: StyleGuideCardGridProps) {
  return <div className="card-grid" style={style}>{children}</div>;
}
