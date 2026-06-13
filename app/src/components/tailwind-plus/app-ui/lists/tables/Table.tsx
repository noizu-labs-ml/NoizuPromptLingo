'use client';

import React, { ReactNode } from 'react';

export interface TableColumn {
  key: string;
  label: string;
}

export interface TableProps {
  columns: TableColumn[];
  data: Array<Record<string, ReactNode>>;
  striped?: boolean;
  bordered?: boolean;
  stickyHeader?: boolean;
  className?: string;
}

export function Table({
  columns,
  data,
  striped = false,
  bordered = false,
  stickyHeader = false,
  className = '',
}: TableProps) {
  const tableClasses = [
    'twp-table',
    striped ? 'twp-table-striped' : '',
    stickyHeader ? 'twp-table-sticky-header' : '',
  ]
    .filter(Boolean)
    .join(' ');

  const wrapperClasses = ['twp-table-wrapper', bordered ? 'twp-table-bordered' : '', className]
    .filter(Boolean)
    .join(' ');

  return (
    <div className={wrapperClasses} style={{ overflowX: 'auto' }}>
      <table className={tableClasses}>
        <thead>
          <tr>
            {columns.map((col) => (
              <th key={col.key}>{col.label}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data.map((row, i) => (
            <tr key={i}>
              {columns.map((col) => (
                <td key={col.key}>{row[col.key]}</td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export function TableShowcase() {
  const columns: TableColumn[] = [
    { key: 'name', label: 'Name' },
    { key: 'role', label: 'Role' },
    { key: 'status', label: 'Status' },
    { key: 'joined', label: 'Joined' },
  ];

  const data: Array<Record<string, ReactNode>> = [
    { name: 'Alice Nguyen', role: 'Engineer', status: 'Active', joined: '2023-01' },
    { name: 'Bob Martinez', role: 'Designer', status: 'Active', joined: '2022-07' },
    { name: 'Carol Smith', role: 'Manager', status: 'Away', joined: '2021-03' },
    { name: 'David Lee', role: 'Engineer', status: 'Inactive', joined: '2020-11' },
  ];

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-4)' }}>
      <div>
        <p style={{ fontSize: 'var(--font-size-xs)', color: 'var(--text-muted)', marginBottom: 'var(--space-2)' }}>
          Default
        </p>
        <Table columns={columns} data={data} />
      </div>
      <div>
        <p style={{ fontSize: 'var(--font-size-xs)', color: 'var(--text-muted)', marginBottom: 'var(--space-2)' }}>
          Striped + Bordered
        </p>
        <Table columns={columns} data={data} striped bordered />
      </div>
      <div>
        <p style={{ fontSize: 'var(--font-size-xs)', color: 'var(--text-muted)', marginBottom: 'var(--space-2)' }}>
          Sticky Header + Bordered (scroll to see)
        </p>
        <div style={{ maxHeight: '120px', overflowY: 'auto' }}>
          <Table columns={columns} data={[...data, ...data]} stickyHeader bordered />
        </div>
      </div>
    </div>
  );
}
