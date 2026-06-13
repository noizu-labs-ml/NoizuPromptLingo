import React from 'react';

interface StyleGuideTokenPreviewProps {
  type: 'color' | 'font' | 'space' | 'radius' | 'shadow' | 'size' | string;
  value: string;
}

export function StyleGuideTokenPreview({ type, value }: StyleGuideTokenPreviewProps) {
  switch (type) {
    case 'color':
      return <span className="token-preview token-preview--color" style={{ backgroundColor: value }} />;
    case 'font':
      return <span className="token-preview token-preview--font" style={{ fontFamily: value }}>Ag</span>;
    case 'space':
      return <span className="token-preview token-preview--space" style={{ width: value, height: value }} />;
    case 'radius':
      return <span className="token-preview token-preview--radius" style={{ borderRadius: value }} />;
    case 'shadow':
      return <span className="token-preview token-preview--shadow" style={{ boxShadow: value }} />;
    case 'size':
      return <span className="token-preview token-preview--size" style={{ fontSize: value }}>A</span>;
    default:
      return null;
  }
}
