import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./app/**/*.{ts,tsx}",
    "./components/**/*.{ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        bg: {
          void: "var(--ru-bg-void)",
          surface: "var(--ru-bg-surface)",
          elevated: "var(--ru-bg-elevated)",
          inset: "var(--ru-bg-inset)",
        },
        text: {
          primary: "var(--ru-text-primary)",
          secondary: "var(--ru-text-secondary)",
          tertiary: "var(--ru-text-tertiary)",
          "on-accent": "var(--ru-text-on-accent)",
        },
        border: {
          default: "var(--ru-border-default)",
          subtle: "var(--ru-border-subtle)",
          strong: "var(--ru-border-strong)",
        },
        orange: {
          DEFAULT: "var(--ru-orange)",
          hover: "var(--ru-orange-hover)",
          active: "var(--ru-orange-active)",
          muted: "var(--ru-orange-muted)",
          subtle: "var(--ru-orange-subtle)",
          glow: "var(--ru-orange-glow)",
        },
        cyan: {
          DEFAULT: "var(--ru-cyan)",
          hover: "var(--ru-cyan-hover)",
          active: "var(--ru-cyan-active)",
          muted: "var(--ru-cyan-muted)",
          subtle: "var(--ru-cyan-subtle)",
          glow: "var(--ru-cyan-glow)",
        },
        success: {
          DEFAULT: "var(--ru-success)",
          muted: "var(--ru-success-muted)",
        },
        warning: {
          DEFAULT: "var(--ru-warning)",
          muted: "var(--ru-warning-muted)",
        },
        error: {
          DEFAULT: "var(--ru-error)",
          muted: "var(--ru-error-muted)",
        },
        info: {
          DEFAULT: "var(--ru-info)",
          muted: "var(--ru-info-muted)",
        },
      },
      fontFamily: {
        display: ["var(--ru-font-display)"],
        body: ["var(--ru-font-body)"],
        mono: ["var(--ru-font-mono)"],
        sans: ["var(--ru-font-body)"],
      },
      borderRadius: {
        sm: "4px",
        md: "8px",
        lg: "12px",
        xl: "16px",
      },
      maxWidth: {
        content: "1200px",
      },
      keyframes: {
        "pulse-dot": {
          "0%, 100%": { opacity: "1" },
          "50%": { opacity: "0.3" },
        },
        "progress-pulse": {
          "0%, 100%": { opacity: "1" },
          "50%": { opacity: "0.7" },
        },
        "float": {
          "0%, 100%": { transform: "translateY(0)" },
          "50%": { transform: "translateY(-6px)" },
        },
        "fade-up": {
          "0%": { opacity: "0", transform: "translateY(20px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
        "chassis-pulse": {
          "0%, 100%": { opacity: "0.3" },
          "50%": { opacity: "0.8" },
        },
        "countdown-flash": {
          "50%": { opacity: "0.5" },
        },
        "scan-sweep": {
          "0%": { transform: "translateY(-100%)" },
          "100%": { transform: "translateY(100%)" },
        },
      },
      animation: {
        "pulse-dot": "pulse-dot 1.5s ease-in-out infinite",
        "progress-pulse": "progress-pulse 2s ease-in-out infinite",
        "float": "float 3s ease-in-out infinite",
        "fade-up": "fade-up 0.6s ease-out forwards",
        "chassis-pulse": "chassis-pulse 3s ease-in-out infinite",
        "countdown-flash": "countdown-flash 1s step-start infinite",
        "scan-sweep": "scan-sweep 8s linear infinite",
      },
      boxShadow: {
        sm: "var(--ru-shadow-sm)",
        md: "var(--ru-shadow-md)",
        lg: "var(--ru-shadow-lg)",
        "orange-glow": "var(--ru-shadow-orange)",
        "cyan-glow": "var(--ru-shadow-cyan)",
      },
    },
  },
  plugins: [],
};

export default config;
