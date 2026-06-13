import React from 'react';

interface StyleGuideTypeSpecimenProps {
  name?: React.ReactNode;
  font?: string;
  weight?: string | number;
  size?: string;
  lineHeight?: string | number;
  sample?: React.ReactNode;
  usage?: React.ReactNode;
}

export function StyleGuideTypeSpecimen({ name, font, weight, size, lineHeight, sample, usage }: StyleGuideTypeSpecimenProps) {
  return (
    <div className="type-specimen">
      <div className="type-meta">
        <strong>{name}</strong>
        {font} {weight}<br />
        {size} / {lineHeight}
        {usage && <div className="type-usage">{usage}</div>}
      </div>
      <div style={{ fontFamily: font, fontWeight: weight as React.CSSProperties['fontWeight'], fontSize: size, lineHeight: lineHeight, color: 'var(--border-strong)', maxWidth: 560 }}>
        {sample}
      </div>
    </div>
  );
}
