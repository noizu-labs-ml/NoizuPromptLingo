'use client';

import { ReactNode } from 'react';
import { AppSidebar } from '@/components/app-sidebar';

export default function AppLayout({ children }: { children: ReactNode }) {
  return (
    <div className="app-shell">
      <a className="skip-link" href="#main-content">
        Skip to content
      </a>
      <AppSidebar />
      <main id="main-content" className="app-shell__main" tabIndex={-1}>
        {children}
      </main>
    </div>
  );
}
