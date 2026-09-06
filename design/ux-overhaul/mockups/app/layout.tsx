import type { ReactNode } from "react";
import "./wireframe.css";

export const metadata = {
  title: "NPL UX Overhaul — Wireframes",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
