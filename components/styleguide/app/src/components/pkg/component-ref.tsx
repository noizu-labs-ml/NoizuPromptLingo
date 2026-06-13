import React from 'react';

interface ComponentRefProp {
  name: string;
  required?: boolean;
  type: string;
  default?: string;
  desc: React.ReactNode;
}

interface StyleGuideComponentRefProps {
  name?: string;
  category?: React.ReactNode;
  desc?: React.ReactNode;
  props: ComponentRefProp[];
  children?: React.ReactNode;
}

export function StyleGuideComponentRef({ name, category, desc, props, children }: StyleGuideComponentRefProps) {
  return (
    <div className="component-ref">
      <div className="component-ref-header">
        <span className="component-ref-name">&lt;{name} /&gt;</span>
        <span className="component-ref-category">{category}</span>
      </div>
      <div className="component-ref-desc">{desc}</div>
      {children && (
        <div className="component-ref-preview">
          <div className="component-ref-preview-label">Live Preview</div>
          {children}
        </div>
      )}
      <table className="component-ref-props">
        <thead>
          <tr><th>Prop</th><th>Type</th><th>Default</th><th>Description</th></tr>
        </thead>
        <tbody>
          {props.map(p => (
            <tr key={p.name}>
              <td>{p.name}{p.required && ' *'}</td>
              <td>{p.type}</td>
              <td>{p.default || '—'}</td>
              <td>{p.desc}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
