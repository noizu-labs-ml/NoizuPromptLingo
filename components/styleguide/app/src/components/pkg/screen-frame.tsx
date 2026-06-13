import React from 'react';

interface StyleGuideScreenFrameProps {
  url?: React.ReactNode;
  label?: React.ReactNode;
  children?: React.ReactNode;
}

export function StyleGuideScreenFrame({ url, label, children }: StyleGuideScreenFrameProps) {
  return (
    <div>
      {label && <div className="screen-label">{label}</div>}
      <div className="screen-frame">
        <div className="screen-titlebar">
          <div className="screen-dot" />
          <div className="screen-dot" />
          <div className="screen-dot" />
          <div className="screen-url">{url}</div>
        </div>
        <div className="screen-body">{children}</div>
      </div>
    </div>
  );
}
