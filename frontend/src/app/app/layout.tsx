'use client';

import { ReactNode } from 'react';
import { AppSidebar } from '@/components/app-sidebar';

export default function AppLayout({ children }: { children: ReactNode }) {
  return (
    <div className="app-shell">
      <AppSidebar />
      <div className="app-shell__main">{children}</div>
    </div>
  );
}
