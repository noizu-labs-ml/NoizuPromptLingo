import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "NPL MCP Server",
  description: "Task queue management, artifacts, and collaborative chat",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="antialiased bg-gray-50 min-h-screen">
        {children}
      </body>
    </html>
  );
}
