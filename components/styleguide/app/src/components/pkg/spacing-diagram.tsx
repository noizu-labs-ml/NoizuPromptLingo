import React from 'react';

interface SpacingBlock {
  label?: React.ReactNode;
  meta?: React.ReactNode;
  compact?: boolean;
}

interface StyleGuideSpacingDiagramProps {
  title?: React.ReactNode;
  blocks: SpacingBlock[];
}

export function StyleGuideSpacingDiagram({ title, blocks }: StyleGuideSpacingDiagramProps) {
  return (
    <div className="spacing-diagram">
      <div className="spacing-diagram-header">{title}</div>
      <div className="spacing-diagram-body">
        <div className="spacing-diagram-viewport">
          <div className="spacing-diagram-viewport-label">viewport</div>
          <div className="spacing-diagram-cols">
            <div className="spacing-diagram-gutter spacing-diagram-gutter-left"><span>40px gutter</span></div>
            <div className="spacing-diagram-content">
              {blocks.map((block, i) => (
                <React.Fragment key={i}>
                  {i > 0 && <div className="spacing-diagram-divider" style={{ height: 1, background: 'var(--border)', margin: '0 var(--space-2)' }} />}
                  <div className="spacing-diagram-block">
                    <div className={`spacing-diagram-padding${block.compact ? ' spacing-diagram-padding--sm' : ''}`} />
                    <div className="spacing-diagram-label">
                      <div className="spacing-diagram-label-title">{block.label}</div>
                      <div className="spacing-diagram-label-meta">{block.meta}</div>
                    </div>
                    <div className={`spacing-diagram-padding${block.compact ? ' spacing-diagram-padding--sm' : ''}`} />
                  </div>
                </React.Fragment>
              ))}
            </div>
            <div className="spacing-diagram-gutter spacing-diagram-gutter-right"><span>40px gutter</span></div>
          </div>
        </div>
      </div>
    </div>
  );
}
