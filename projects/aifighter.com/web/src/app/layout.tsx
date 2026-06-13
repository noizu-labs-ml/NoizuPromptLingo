import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "AI Fighter — Design the Intelligence. Win the Fight.",
  description:
    "Mobile game where you build neural-net powered fighters, train their decision graphs, and battle in ranked PvP arenas. Join the waitlist.",
  icons: {
    icon: { url: "/favicon.svg", type: "image/svg+xml" },
  },
  openGraph: {
    title: "AI Fighter — Design the Intelligence. Win the Fight.",
    description:
      "Build AI fighters. Train neural networks. Compete in ranked arenas. The first mobile game where YOUR strategy is the AI.",
    type: "website",
    url: "https://aifighter.com",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
