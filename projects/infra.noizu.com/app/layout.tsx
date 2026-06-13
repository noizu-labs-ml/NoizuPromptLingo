import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Noizu Infrastructure",
  description: "Service dashboard for noizu.com infrastructure",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="min-h-screen">{children}</body>
    </html>
  );
}
