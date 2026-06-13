'use client'

import { useState } from 'react';

export type TabsVariant = 'underline' | 'pill' | 'bordered';

export interface TabItem {
  key: string;
  label: string;
}

export interface TabsProps {
  tabs: TabItem[];
  activeKey: string;
  onChange: (key: string) => void;
  variant?: TabsVariant;
  className?: string;
}

export function Tabs({
  tabs,
  activeKey,
  onChange,
  variant = 'underline',
  className = '',
}: TabsProps) {
  const containerCls = [
    'twp-tabs',
    variant === 'underline' ? 'twp-tabs-underline' : '',
    variant === 'pill' ? 'twp-tabs-pill' : '',
    variant === 'bordered' ? 'twp-tabs-bordered' : '',
    className,
  ].filter(Boolean).join(' ');

  return (
    <div role="tablist" className={containerCls}>
      {tabs.map((tab) => {
        const isActive = tab.key === activeKey;
        const tabCls = ['twp-tab', isActive ? 'twp-tab-active' : ''].filter(Boolean).join(' ');
        return (
          <button
            key={tab.key}
            role="tab"
            aria-selected={isActive}
            className={tabCls}
            onClick={() => onChange(tab.key)}
            type="button"
          >
            {tab.label}
          </button>
        );
      })}
    </div>
  );
}

const DEMO_TABS: TabItem[] = [
  { key: 'overview', label: 'Overview' },
  { key: 'activity', label: 'Activity' },
  { key: 'settings', label: 'Settings' },
  { key: 'billing', label: 'Billing' },
];

function TabsDemo({ variant }: { variant: TabsVariant }) {
  const [active, setActive] = useState('overview');
  return <Tabs tabs={DEMO_TABS} activeKey={active} onChange={setActive} variant={variant} />;
}

export function TabsShowcase() {
  const variants: { variant: TabsVariant; label: string }[] = [
    { variant: 'underline', label: 'underline (default)' },
    { variant: 'pill', label: 'pill' },
    { variant: 'bordered', label: 'bordered' },
  ];

  return (
    <div className="twp-showcase">
      {variants.map(({ variant, label }) => (
        <div key={variant} className="twp-showcase-group">
          <div className="twp-showcase-label">{label}</div>
          <TabsDemo variant={variant} />
        </div>
      ))}
    </div>
  );
}
