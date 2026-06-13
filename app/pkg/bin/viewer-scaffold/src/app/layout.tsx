import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Style Guide Viewer",
  description: "Interactive design system viewer",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body>{children}</body>
    </html>
  );
}
