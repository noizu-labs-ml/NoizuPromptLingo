import React from 'react';

interface StyleGuideSectionDescProps {
  children?: React.ReactNode;
}

export function StyleGuideSectionDesc({ children }: StyleGuideSectionDescProps) {
  return <p className="sg-description">{children}</p>;
}
