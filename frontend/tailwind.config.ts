import type { Config } from "tailwindcss";
import typography from "@tailwindcss/typography";

/**
 * NPL Studio Tailwind config.
 *
 * Colors use the `hsl(var(--token) / <alpha-value>)` pattern so
 * utility classes like `bg-accent/25`, `text-foreground/60` work with
 * arbitrary opacities — a core primitive of the design system.
 */

const hsl = (name: string) => `hsl(var(--${name}) / <alpha-value>)`;

export default {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./lib/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  darkMode: ["class", '[data-theme="dark"]'],
  theme: {
    extend: {
      colors: {
        // Layered surfaces
        canvas:    hsl("canvas"),
        "surface-0": hsl("surface-0"),
        "surface-1": hsl("surface-1"),
        "surface-2": hsl("surface-2"),
        elevated:  hsl("elevated"),

        // Borders
        border: {
          DEFAULT: hsl("border"),
          strong:  hsl("border-strong"),
        },

        // Text
        foreground: hsl("foreground"),
        muted:      hsl("muted"),
        subtle:     hsl("subtle"),

        // Brand accent (violet)
        accent: {
          DEFAULT: hsl("accent"),
          soft:    hsl("accent-soft"),
          on:      hsl("accent-on"),
          fg:      hsl("accent-on"),   // legacy alias
        },

        // Semantic colors
        success: hsl("success"),
        warning: hsl("warning"),
        danger:  hsl("danger"),
        info:    hsl("info"),

        // Legacy aliases — migration-friendly; map to new tokens
        background: hsl("canvas"),
        surface: {
          DEFAULT: hsl("surface-0"),
          raised:  hsl("surface-1"),
          sunken:  hsl("canvas"),
        },
        // Legacy brand scale — all point at the accent so any remaining
        // `bg-brand-500` / `ring-brand-500` / `text-brand-600` refs render
        // with the new violet. Fully eliminated in Wave F+.
        brand: {
          50:  hsl("accent"),
          100: hsl("accent"),
          200: hsl("accent"),
          300: hsl("accent"),
          400: hsl("accent"),
          500: hsl("accent"),
          600: hsl("accent-soft"),
          700: hsl("accent-soft"),
          800: hsl("accent-soft"),
          900: hsl("accent-soft"),
          950: hsl("accent-soft"),
        },
      },

      fontFamily: {
        sans: ["var(--font-geist-sans)", "-apple-system", "BlinkMacSystemFont", "Segoe UI", "Roboto", "sans-serif"],
        mono: ["var(--font-geist-mono)", "ui-monospace", "SFMono-Regular", "Menlo", "Monaco", "Consolas", "monospace"],
      },

      fontSize: {
        // Named tiers (used by lib/ui/typography.ts const maps)
        display:  ["2.25rem", { lineHeight: "1.15", letterSpacing: "-0.02em", fontWeight: "600" }],
        title:    ["1.125rem", { lineHeight: "1.4", letterSpacing: "-0.01em", fontWeight: "600" }],
        heading:  ["0.875rem", { lineHeight: "1.4", letterSpacing: "0", fontWeight: "500" }],
        label:    ["0.6875rem", { lineHeight: "1.4", letterSpacing: "0.06em", fontWeight: "600" }],
      },

      borderRadius: {
        // Override the defaults — structural, softer than shadcn
        none: "0",
        sm:   "4px",   // inputs
        DEFAULT: "6px",
        md:   "8px",   // buttons, small cards
        lg:   "12px",  // cards, panels
        xl:   "16px",  // modals
        "2xl": "20px",
        full: "9999px",
      },

      boxShadow: {
        ambient:  "var(--shadow-ambient)",
        elevated: "var(--shadow-elevated)",
        ring:     "var(--ring-accent)",
        glow:     "var(--glow-accent)",
        // Legacy alias
        "glow-accent": "var(--glow-accent)",
      },

      keyframes: {
        "fade-in":   { from: { opacity: "0" }, to: { opacity: "1" } },
        "slide-up":  {
          from: { opacity: "0", transform: "translateY(8px)" },
          to:   { opacity: "1", transform: "translateY(0)" },
        },
        "spin-slow": { to: { transform: "rotate(360deg)" } },
      },
      animation: {
        "fade-in":  "fade-in 0.18s ease-out",
        "slide-up": "slide-up 0.24s ease-out",
        "spin-slow": "spin-slow 2.4s linear infinite",
      },
    },
  },
  plugins: [typography],
} satisfies Config;
