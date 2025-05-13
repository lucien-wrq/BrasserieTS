const nextConfig = {
  reactStrictMode: true,
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        destination: 'https://api.13.61.145.109.traefik.me/api/:path*',
      },
    ];
  },
};

export default nextConfig;
