import React from 'react';

interface StyleGuideColorSwatchProps {
  name?: React.ReactNode;
  hex?: string;
  color?: string;
  inline?: boolean;
}

export function StyleGuideColorSwatch({ name, hex, color, inline = false }: StyleGuideColorSwatchProps) {
  if (inline) {
    return (
      <div className="color-primary-block" style={{ background: hex, color: color || 'var(--white)' }}>
        <span className="name">{name}</span>
        <span className="hex">{hex}</span>
      </div>
    );
  }
  return (
    <div className="color-swatch">
      <div className="color-swatch-preview" style={{ background: hex }} />
      <div className="color-swatch-info">
        <div className="color-swatch-name">{name}</div>
        <div className="color-swatch-hex">{hex}</div>
      </div>
    </div>
  );
}
