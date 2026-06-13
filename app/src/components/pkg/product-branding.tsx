import React from 'react';

interface StyleGuideProductBrandingProps {
  name?: React.ReactNode;
  logo?: React.ReactNode;
  intent?: React.ReactNode;
  perception?: React.ReactNode;
  audience?: React.ReactNode;
  tone?: React.ReactNode;
  keywords?: string[];
  children?: React.ReactNode;
  actions?: React.ReactNode;
}

export function StyleGuideProductBranding({ name, logo, intent, perception, audience, tone, keywords, children, actions }: StyleGuideProductBrandingProps) {
  return (
    <div className="product-branding grid grid-cols-1 @md:grid-cols-[var(--branding-grid-width)_1fr]">
      <div className="product-branding-logo border-b @md:border-b-0 @md:border-r border-[var(--card-border-color,var(--border))]">
        {logo || <div className="product-branding-logo-placeholder">SVG Logo</div>}
      </div>
      <div className="product-branding-content">
        <div className="flex items-center justify-between">
          <div className="product-branding-name">{name}</div>
          {actions}
        </div>
        <div className="product-branding-grid grid grid-cols-1 @md:grid-cols-2 gap-[var(--space-3)]">
          {intent && (
            <div className="product-branding-field">
              <div className="product-branding-field-label">Style Intent</div>
              <div className="product-branding-field-value">{intent}</div>
            </div>
          )}
          {perception && (
            <div className="product-branding-field">
              <div className="product-branding-field-label">Desired Perception</div>
              <div className="product-branding-field-value">{perception}</div>
            </div>
          )}
          {audience && (
            <div className="product-branding-field">
              <div className="product-branding-field-label">Target Audience</div>
              <div className="product-branding-field-value">{audience}</div>
            </div>
          )}
          {tone && (
            <div className="product-branding-field">
              <div className="product-branding-field-label">Tone / Voice</div>
              <div className="product-branding-field-value">{tone}</div>
            </div>
          )}
          {keywords && (
            <div className="product-branding-field product-branding-full col-span-full">
              <div className="product-branding-field-label">Brand Keywords</div>
              <div className="product-branding-tags">
                {keywords.map(k => <span key={k} className="product-branding-tag">{k}</span>)}
              </div>
            </div>
          )}
          {children && (
            <div className="product-branding-field product-branding-full col-span-full">
              {children}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
