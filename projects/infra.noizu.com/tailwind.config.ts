import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./app/**/*.{ts,tsx}",
    "./components/**/*.{ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        surface: {
          0: "#0a0a0f",
          1: "#12121a",
          2: "#1a1a25",
          3: "#232330",
        },
        accent: {
          DEFAULT: "#6366f1",
          hover: "#818cf8",
        },
        muted: "#64748b",
      },
    },
  },
  plugins: [],
};

export default config;
