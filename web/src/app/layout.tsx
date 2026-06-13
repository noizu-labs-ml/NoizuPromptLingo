import type { Metadata } from "next";
import { Cinzel, Alegreya, Alegreya_Sans, Alegreya_SC, JetBrains_Mono } from "next/font/google";
import "./globals.css";

const cinzel = Cinzel({
  variable: "--font-cinzel",
  subsets: ["latin"],
  weight: ["400", "600", "700"],
});

const alegreya = Alegreya({
  variable: "--font-alegreya",
  subsets: ["latin"],
  weight: ["400", "600"],
  style: ["normal", "italic"],
});

const alegreyaSans = Alegreya_Sans({
  variable: "--font-alegreya-sans",
  subsets: ["latin"],
  weight: ["400", "500", "700"],
});

const alegreyaSC = Alegreya_SC({
  variable: "--font-alegreya-sc",
  subsets: ["latin"],
  weight: ["400"],
});

const jetbrainsMono = JetBrains_Mono({
  variable: "--font-jetbrains-mono",
  subsets: ["latin"],
  weight: ["400", "700"],
});

export const metadata: Metadata = {
  title: "NoizuRPG — The Composable Framework for AI-Powered RPGs",
  description:
    "Build role-playing games where LLMs are first-class primitives. Composable components for characters, worlds, narrative, quests, dialogue, and memory. Any LLM. Persistent state. Coherent narrative.",
  icons: {
    icon: [
      { url: "/favicon.svg", type: "image/svg+xml" },
    ],
  },
  openGraph: {
    title: "NoizuRPG — The Composable Framework for AI-Powered RPGs",
    description:
      "The React of AI-powered RPGs. Snap together character systems, dialogue engines, quest generators, and world-state managers. Wire in any LLM. Ship an AI RPG that actually works.",
    siteName: "noizurpg.com",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "NoizuRPG — The Composable Framework for AI-Powered RPGs",
    description:
      "Composable Python framework for building AI-powered RPGs with persistent state and coherent narrative.",
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
        className={`${cinzel.variable} ${alegreya.variable} ${alegreyaSans.variable} ${alegreyaSC.variable} ${jetbrainsMono.variable} antialiased`}
      >
        {children}
      </body>
    </html>
  );
}
