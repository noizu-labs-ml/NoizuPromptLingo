import React from 'react';

interface SpacingStep {
  px: number | string;
  label: string;
}

interface StyleGuideSpacingScaleProps {
  steps: SpacingStep[];
}

export function StyleGuideSpacingScale({ steps }: StyleGuideSpacingScaleProps) {
  return (
    <div className="spacing-demo">
      {steps.map(({ px, label }) => (
        <div className="spacing-row" key={label}>
          <div className="spacing-label">{label}</div>
          <div className="spacing-bar" style={{ width: px }} />
          <div className="spacing-value">{px}px</div>
        </div>
      ))}
    </div>
  );
}
