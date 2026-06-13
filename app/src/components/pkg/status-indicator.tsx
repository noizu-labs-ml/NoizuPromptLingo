import React from 'react';

interface StyleGuideStatusIndicatorProps {
  status: string;
  label?: React.ReactNode;
  desc?: React.ReactNode;
}

export function StyleGuideStatusIndicator({ status, label, desc }: StyleGuideStatusIndicatorProps) {
  return (
    <div className="status-item">
      <div className={`status-indicator ${status}`} />
      <div className="status-text"><strong>{label}</strong>{desc}</div>
    </div>
  );
}
