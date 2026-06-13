import React from 'react';

interface StyleGuideSpecTableProps {
  columns: string[];
  rows: string[][];
}

export function StyleGuideSpecTable({ columns, rows }: StyleGuideSpecTableProps) {
  return (
    <table className="spec-table">
      <thead>
        <tr>{columns.map(c => <th key={c}>{c}</th>)}</tr>
      </thead>
      <tbody>
        {rows.map((row, i) => (
          <tr key={i}>{row.map((cell, j) => <td key={j} dangerouslySetInnerHTML={{ __html: cell }} />)}</tr>
        ))}
      </tbody>
    </table>
  );
}
