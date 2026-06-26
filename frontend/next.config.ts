import type { NextConfig } from "next";
import path from "path";

const pkgRoot = path.dirname(require.resolve("@noizu/styleguide/components"));
const engineSrc = path.resolve(pkgRoot, "dist", "engine-src");

const nextConfig: NextConfig = {
  output: "standalone",
  transpilePackages: ["@noizu/styleguide"],
  turbopack: {
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
