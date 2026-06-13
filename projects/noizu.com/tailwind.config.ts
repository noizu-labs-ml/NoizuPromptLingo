import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./src/**/*.{js,ts,jsx,tsx,mdx}"],
  theme: {
    extend: {
      fontFamily: {
        sans: ["var(--font-inter)"],
        mono: ["var(--font-jetbrains)"],
      },
      colors: {
        // Built around the Noizu logo yellow #ffca02
        gold: {
          50: "#fffbeb",
          100: "#fff3c4",
          200: "#fce588",
          300: "#fad24b",
          400: "#ffca02", // exact logo color
          500: "#f0b400",
          600: "#cc8a00",
          700: "#a16207",
          800: "#854d0e",
          900: "#713f12",
          950: "#422006",
        },
        // Warm complementary accent
        amber: {
          400: "#fbbf24",
          500: "#f59e0b",
        },
      },
      animation: {
        "fade-in": "fade-in 0.6s ease-out forwards",
        "slide-up": "slide-up 0.6s ease-out forwards",
      },
      keyframes: {
        "fade-in": {
          "0%": { opacity: "0" },
          "100%": { opacity: "1" },
        },
        "slide-up": {
          "0%": { opacity: "0", transform: "translateY(20px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
      },
    },
  },
  plugins: [],
};
export default config;
