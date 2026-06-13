import React from 'react';
import { StyleGuideTokenPreview } from './token-preview';

interface StyleGuideTokenCardProps {
  title?: React.ReactNode;
  type: string;
  tokens: [string, string][];
  stylize?: boolean;
}

export function StyleGuideTokenCard({ title, type, tokens, stylize = true }: StyleGuideTokenCardProps) {
  return (
    <div className="token-card">
      <div className="token-card-title">{title}</div>
      {tokens.map(([name, value]) => (
        <div className="token-row" key={name}>
          <span className="token-name">{name}</span>
          <span className="token-value">{value}</span>
          {stylize && <StyleGuideTokenPreview type={type} value={value} />}
        </div>
      ))}
    </div>
  );
}
