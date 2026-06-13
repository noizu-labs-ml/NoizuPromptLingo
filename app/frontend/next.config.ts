import type { NextConfig } from "next";
import path from "path";
import createNextIntlPlugin from "next-intl/plugin";

const withNextIntl = createNextIntlPlugin("./src/i18n/request.ts");

const pkgRoot = path.dirname(require.resolve("@noizu/styleguide/components"));
const engineSrc = path.resolve(pkgRoot, "dist", "engine-src");

const nextConfig: NextConfig = {
  output: "standalone",
  transpilePackages: ["@noizu/styleguide"],
  webpack: (config) => {
    config.resolve.alias["@styleguide-engine"] = engineSrc;
    config.resolve.alias["@/"] = path.resolve(__dirname, "src") + "/";
    return config;
  },
};

export default withNextIntl(nextConfig);
