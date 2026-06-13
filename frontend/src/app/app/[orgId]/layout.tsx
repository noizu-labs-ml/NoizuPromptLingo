'use client';

import { OrgProvider } from '@/context/org';
import { ReactNode } from 'react';

export default function OrgLayout({ children }: { children: ReactNode }) {
  return <OrgProvider>{children}</OrgProvider>;
}
