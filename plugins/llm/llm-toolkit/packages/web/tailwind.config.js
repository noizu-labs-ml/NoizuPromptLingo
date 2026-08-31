/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        void: "#0E0E12",
        canvas: "#16161C",
        surface: {
          DEFAULT: "#212128",
          raised: "#2A2A32",
          active: "#33333D",
        },
        border: {
          subtle: "#35353F",
          strong: "#45454F",
        },
        glow: {
          DEFAULT: "#06B6D4",
          bright: "#22D3EE",
          dim: "color-mix(in srgb, #06B6D4 50%, transparent)",
          bg: "color-mix(in srgb, #06B6D4 8%, #212128)",
        },
        text: {
          dim: "#8888A0",
          muted: "#A0A0B8",
          secondary: "#C0C0D0",
          primary: "#E0E0EC",
          bright: "#FFFFFF",
          max: "#FFFFFF",
        },
      },
      fontFamily: {
        sans: ["Inter", "system-ui", "-apple-system", "sans-serif"],
        mono: ["JetBrains Mono", "Fira Code", "SF Mono", "Menlo", "monospace"],
      },
    },
  },
  plugins: [require("@tailwindcss/typography")],
};
