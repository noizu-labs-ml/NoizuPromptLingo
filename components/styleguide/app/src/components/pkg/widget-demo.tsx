import React from 'react';

interface StyleGuideWidgetDemoProps {
  title?: React.ReactNode;
  badge?: React.ReactNode;
  desc?: React.ReactNode;
  children?: React.ReactNode;
}

export function StyleGuideWidgetDemo({ title, badge, desc, children }: StyleGuideWidgetDemoProps) {
  return (
    <div className="widget-card">
      <div className="widget-card-header">
        <span className="widget-card-title">{title}</span>
        {badge && <span className="widget-card-badge">{badge}</span>}
      </div>
      <div className="widget-card-body">{children}</div>
      {desc && <div className="widget-card-desc">{desc}</div>}
    </div>
  );
}
