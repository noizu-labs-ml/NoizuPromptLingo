import React from 'react';

interface Principle {
  rule: React.ReactNode;
  detail?: React.ReactNode;
}

interface StyleGuidePrinciplesProps {
  items: Principle[];
}

export function StyleGuidePrinciples({ items }: StyleGuidePrinciplesProps) {
  return (
    <div className="sg-principles">
      {items.map((item, i) => (
        <div className="sg-principle" key={i}>
          <strong>{i + 1}. {item.rule}</strong> {item.detail}
        </div>
      ))}
    </div>
  );
}
