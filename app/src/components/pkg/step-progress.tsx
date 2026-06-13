import React from 'react';

interface StyleGuideStepProgressProps {
  total: number;
  done: number;
  current: number;
  label?: React.ReactNode;
}

export function StyleGuideStepProgress({ total, done, current, label }: StyleGuideStepProgressProps) {
  return (
    <div>
      <div className="phase-step-bar">
        {Array.from({ length: total }, (_, i) => (
          <div key={i} className={`phase-step${i < done ? ' done' : ''}${i === current - 1 ? ' current' : ''}`} />
        ))}
      </div>
      {label && (
        <div style={{ fontFamily: 'var(--font-mono)', fontSize: "var(--font-size-xs)", color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
          {label}
        </div>
      )}
    </div>
  );
}
