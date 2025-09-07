// next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "avatar.iran.liara.run",
      },
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
    
    domains: ['placehold.co', 'example.com', "res.cloudinary.com"],
  },
}

module.exports = nextConfig
