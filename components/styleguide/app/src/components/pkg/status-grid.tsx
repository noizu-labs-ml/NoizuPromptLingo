import React from 'react';
import { StyleGuideStatusIndicator } from './status-indicator';

interface StatusItem {
  status: string;
  label?: React.ReactNode;
  desc?: React.ReactNode;
}

interface StyleGuideStatusGridProps {
  items: StatusItem[];
}

export function StyleGuideStatusGrid({ items }: StyleGuideStatusGridProps) {
  return (
    <div className="status-grid">
      {items.map(item => <StyleGuideStatusIndicator key={item.status} {...item} />)}
    </div>
  );
}
