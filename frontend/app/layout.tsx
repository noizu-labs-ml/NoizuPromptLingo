import type { Metadata } from "next";
import { GeistSans } from "geist/font/sans";
import { GeistMono } from "geist/font/mono";
import "./globals.css";
import { AppShell } from "@/components/shell/AppShell";

export const metadata: Metadata = {
  title: "NPL MCP Companion",
  description: "NoizuPromptLingo MCP Server Web Interface",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={`h-full ${GeistSans.variable} ${GeistMono.variable}`}>
      <body className="h-full antialiased">
        <AppShell>{children}</AppShell>
      </body>
    </html>
  );
}
