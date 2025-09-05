// next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
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
    remotePatterns: [
      {
        protocol: "https",
        hostname: "res.cloudinary.com",
        pathname: "/**", // allow all cloudinary paths
      },
      {
        protocol: "https",
        hostname: "ui-avatars.com",
        pathname: "/**", // allow all ui-avatars paths
      },
    ],
  },
}

module.exports = nextConfig
