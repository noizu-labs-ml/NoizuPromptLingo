/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  distDir: '../src/npl_mcp/web/static',
  images: {
    unoptimized: true,
  },
  eslint: {
    ignoreDuringBuilds: true,
  },
  typescript: {
    ignoreBuildErrors: true,
  },
}

export default nextConfig