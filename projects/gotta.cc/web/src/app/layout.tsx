import type { Metadata } from "next";
import { Fraunces, Source_Serif_4, Plus_Jakarta_Sans, JetBrains_Mono } from "next/font/google";
import "./globals.css";

const fraunces = Fraunces({
  variable: "--font-fraunces",
  subsets: ["latin"],
  axes: ["WONK", "SOFT", "opsz"],
});

const sourceSerif4 = Source_Serif_4({
  variable: "--font-source-serif-4",
  subsets: ["latin"],
  weight: ["400", "600"],
  style: ["normal", "italic"],
});

const plusJakartaSans = Plus_Jakarta_Sans({
  variable: "--font-plus-jakarta-sans",
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
});

const jetbrainsMono = JetBrains_Mono({
  variable: "--font-jetbrains-mono",
  subsets: ["latin"],
  weight: ["400"],
});

export const metadata: Metadata = {
  title: "Gotta.cc — The Yahoo Directory for the Post-Slop Web",
  description:
    "An AI-curated website directory with browsable categories, editorial summaries, and quality scoring. Browse the web by topic, not by keyword.",
  openGraph: {
    title: "Gotta.cc — The Yahoo Directory for the Post-Slop Web",
    description:
      "Browse curated categories. Read editorial summaries. Discover sites scored for originality, depth, and human authorship.",
    siteName: "gotta.cc",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Gotta.cc — The Yahoo Directory for the Post-Slop Web",
    description:
      "Browse curated categories. Read editorial summaries. Discover sites scored for originality, depth, and human authorship.",
  },
  icons: {
    icon: "/favicon.svg",
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
        className={`${fraunces.variable} ${sourceSerif4.variable} ${plusJakartaSans.variable} ${jetbrainsMono.variable} antialiased`}
      >
        {children}
      </body>
    </html>
  );
}
