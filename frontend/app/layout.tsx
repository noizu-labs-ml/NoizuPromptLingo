import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "NPL MCP Server",
  description: "NoizuPromptLingo MCP Server Web Interface",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="antialiased">
        {children}
      </body>
    </html>
  );
}