import React from 'react';

interface PhaseTab {
  label: React.ReactNode;
  state?: string;
  style?: React.CSSProperties;
}

interface StyleGuidePhaseTabsProps {
  tabs: PhaseTab[];
}

export function StyleGuidePhaseTabs({ tabs }: StyleGuidePhaseTabsProps) {
  return (
    <div className="phase-tabs">
      {tabs.map((t, i) => (
        <div key={i} className={`phase-tab${t.state ? ' ' + t.state : ''}`} style={t.style}>{t.label}</div>
      ))}
    </div>
  );
}
