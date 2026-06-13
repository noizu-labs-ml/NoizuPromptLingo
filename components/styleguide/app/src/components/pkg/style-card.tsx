import React from 'react';

interface StyleCardMeta {
  label: React.ReactNode;
  value: React.ReactNode;
}

interface StyleGuideStyleCardProps {
  title?: string;
  subtitle?: React.ReactNode;
  epigraph?: React.ReactNode;
  seal?: React.ReactNode;
  colors?: string[];
  meta?: StyleCardMeta[];
  heroStyle?: React.CSSProperties;
}

export function StyleGuideStyleCard({ title, subtitle, epigraph, seal, colors, meta, heroStyle }: StyleGuideStyleCardProps) {
  return (
    <div className="style-card">
      <div className="style-card-hero" style={heroStyle}>
        {seal && <div className="style-card-seal">{seal}</div>}
        <h1 className="style-card-title" dangerouslySetInnerHTML={{ __html: title ?? '' }} />
        {subtitle && <div className="style-card-subtitle">{subtitle}</div>}
        {epigraph && <p className="style-card-epigraph">"{epigraph}"</p>}
      </div>
      {colors && (
        <div className="style-card-color-bar">
          {colors.map((c, i) => <div key={i} style={{ background: c }} />)}
        </div>
      )}
      {meta && (
        <div className="style-card-meta">
          {meta.map((m, i) => (
            <div className="style-card-meta-item" key={i}>
              <div className="style-card-meta-label">{m.label}</div>
              <div className="style-card-meta-value">{m.value}</div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
