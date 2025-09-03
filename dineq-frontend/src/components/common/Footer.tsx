
"use client";

import React from "react";
import Link from "next/link";
import Image from "next/image";

const Footer = () => {
  return (
    <footer className="w-full border-t border-gray-200 bg-white">
      <div className="max-w-7xl mx-auto flex flex-row items-center justify-between py-4 px-4 sm:px-6 md:px-12 gap-4">
        {/* Left: Logo */}
        <div >
          <Image
            src="/Logo.png"
            alt="Logo"
            width={100}
            height={100}
            className="w-12 h-12 sm:w-16 sm:h-16"
          />
        </div>

        {/* Center: Navigation */}
        <div className="flex flex-row space-x-4 sm:space-x-12 text-gray-700 text-xs sm:text-sm font-medium">
          <Link
            href="/"
            className="hover:text-orange-500"
            onClick={() => console.log("Clicked Home")}
          >
            Home
          </Link>
          <Link
            href="/features"
            className="hover:text-orange-500"
            onClick={() => console.log("Clicked Features")}
          >
            Features
          </Link>
          <Link
            href="/pricing"
            className="hover:text-orange-500"
            onClick={() => console.log("Clicked Pricing")}
          >
            Pricing
          </Link>
        </div>

        {/* Right: Text */}
        <div className="flex-shrink-0 max-w-xs text-right">
          <p className="text-xs sm:text-sm text-gray-600">
            Digitizing Ethiopian dining experiences with AI-powered menu
            solutions.
          </p>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
;
