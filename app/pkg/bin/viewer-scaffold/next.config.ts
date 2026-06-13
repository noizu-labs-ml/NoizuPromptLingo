import type { NextConfig } from "next";
import path from "path";

const pkgRoot = path.dirname(require.resolve("@noizu/styleguide/components"));
const engineSrc = path.resolve(pkgRoot, "dist", "engine-src");

const nextConfig: NextConfig = {
  transpilePackages: ["@noizu/styleguide"],
  webpack: (config) => {
    config.resolve.alias["@styleguide-engine"] = engineSrc;
    config.resolve.alias["@"] = path.resolve(__dirname, "src");
    return config;
  },
};

export default nextConfig;
