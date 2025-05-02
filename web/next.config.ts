const nextConfig = {
  reactStrictMode: true,
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        destination: 'http://localhost:8000/api/:path*', // URL de votre backend Symfony
      },
    ];
  },
};

export default nextConfig;
