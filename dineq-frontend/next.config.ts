import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "res.cloudinary.com", // 👈 Cloudinary
      },
      {
        protocol: "https",
        hostname: "ui-avatars.com", // 👈 for profile images
      },
      {
        protocol: "https",
        hostname: "placehold.co", // keep your existing
      },
      {
        protocol: "https",
        hostname: "example.com", // keep your existing
      },
    ],
  },
};

export default nextConfig;
