import type { NextConfig } from "next";
import path from "path";

// Do not add next.config.js / .mjs beside this file. Next 16 prefers those
// over .ts; the old Phoenix static export (distDir outside the app) panics
// Turbopack (`Invalid distDirRoot`) and skips `output: "standalone"`, which
// the frontend image copies from `.next/standalone`.

const pkgRoot = path.dirname(require.resolve("@noizu/styleguide/components"));
const engineSrc = path.resolve(pkgRoot, "dist", "engine-src");

const frontendRoot = path.resolve(__dirname);

const nextConfig: NextConfig = {
  output: "standalone",
  // Pin tracing/turbopack to this package. Building from the monorepo
  // otherwise infers /Users/.../Noizu as the workspace root (multiple lockfiles).
  outputFileTracingRoot: frontendRoot,
  transpilePackages: ["@noizu/styleguide"],
  turbopack: {
    root: frontendRoot,
    resolveAlias: {
      "@styleguide-engine": engineSrc,
      "@/": "./src/",
    },
  },
  webpack: (config) => {
    config.resolve.alias["@styleguide-engine"] = engineSrc;
    // Ensure @/ alias resolves from styleguide package's transpiled source too
    config.resolve.alias["@/"] = path.resolve(__dirname, "src") + "/";
    return config;
  },
};

export default nextConfig;
