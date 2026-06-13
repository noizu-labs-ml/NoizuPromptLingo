import type { Metadata } from "next";
import { Space_Grotesk, DM_Sans, JetBrains_Mono } from "next/font/google";
import "./globals.css";

const spaceGrotesk = Space_Grotesk({
  subsets: ["latin"],
  variable: "--font-space-grotesk",
  weight: ["400", "500", "600", "700"],
});

const dmSans = DM_Sans({
  subsets: ["latin"],
  variable: "--font-dm-sans",
  weight: ["400", "500", "600"],
});

const jetbrainsMono = JetBrains_Mono({
  subsets: ["latin"],
  variable: "--font-jetbrains-mono",
  weight: ["400", "500"],
});

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
      <body
        className={`${spaceGrotesk.variable} ${dmSans.variable} ${jetbrainsMono.variable}`}
      >
        {children}
      </body>
    </html>
  );
}
