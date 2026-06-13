import type { Metadata } from "next";
import { Cinzel, Cinzel_Decorative, Lato, JetBrains_Mono } from "next/font/google";
import "./globals.css";
import { AuthProvider } from "@/context/auth";

const cinzel = Cinzel({
  variable: "--font-cinzel",
  subsets: ["latin"],
  display: "swap",
});

const cinzelDecorative = Cinzel_Decorative({
  variable: "--font-cinzel-decorative",
  subsets: ["latin"],
  weight: ["400", "700"],
  display: "swap",
});

const lato = Lato({
  variable: "--font-lato",
  subsets: ["latin"],
  weight: ["300", "400", "700"],
  display: "swap",
});

const jetbrainsMono = JetBrains_Mono({
  variable: "--font-jetbrains-mono",
  subsets: ["latin"],
  display: "swap",
});

export const metadata: Metadata = {
  title: "Blade of Eternity — An Accessibility-First Text RPG",
  description:
    "A text RPG where blindness is the native medium. AI-driven narrative, physics engine, and emergent gameplay — built for screen readers from the ground up.",
  keywords: [
    "text RPG",
    "accessible game",
    "blind gaming",
    "MMORPG",
    "screen reader game",
    "AI game",
  ],
  openGraph: {
    title: "Blade of Eternity",
    description:
      "An accessibility-first text RPG with AI-driven narrative and emergent physics.",
    type: "website",
    url: "https://bladeofeternity.com",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        {/* Adobe Typekit — same kit as the Elixir app (tlm4dko) */}
        <link rel="stylesheet" href="https://use.typekit.net/tlm4dko.css" />
      </head>
      <body
        className={`${cinzel.variable} ${cinzelDecorative.variable} ${lato.variable} ${jetbrainsMono.variable} antialiased`}
      >
        <AuthProvider>{children}</AuthProvider>
      </body>
    </html>
  );
}
