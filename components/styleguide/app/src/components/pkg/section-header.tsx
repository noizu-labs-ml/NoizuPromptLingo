import React from 'react';

interface StyleGuideSectionHeaderProps {
  number?: React.ReactNode;
  title?: React.ReactNode;
  desc?: React.ReactNode;
}

export function StyleGuideSectionHeader({ number, title, desc }: StyleGuideSectionHeaderProps) {
  return (
    <div className="sg-section-header">
      <div className="sg-section-number">{number}</div>
      <div className="sg-section-title-group">
        <h2 className="sg-section-title">{title}</h2>
        <p className="sg-section-desc">{desc}</p>
      </div>
    </div>
  );
}
