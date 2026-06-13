import React from 'react';

interface StyleGuideButtonRowProps {
  children?: React.ReactNode;
}

export function StyleGuideButtonRow({ children }: StyleGuideButtonRowProps) {
  return <div className="button-row">{children}</div>;
}
