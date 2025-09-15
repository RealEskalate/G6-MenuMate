"use client";

import React from "react";
import Link from "next/link";
import Image from "next/image";

const Footer = () => {
  return (
    <footer className="w-full border-t border-gray-200 bg-white">
      <div className="max-w-7xl mx-auto flex flex-col items-center gap-6 py-6 px-4 sm:px-6 md:px-12 md:flex-row md:justify-between">
        {/* Left: Logo */}
        <div className="flex justify-center md:justify-start">
          <Image
            src="/Logo.png"
            alt="Logo"
            width={200}
            height={100}
            className="w-18 h-14 sm:w-16 sm:h-16"
          />
        </div>

        {/* Center: Navigation */}
        <div className="flex flex-wrap justify-center gap-6 text-gray-700 text-sm font-medium">
          <Link href="/" className="hover:text-orange-500">
            Home
          </Link>
          <Link href="/features" className="hover:text-orange-500">
            Features
          </Link>
          <Link href="/pricing" className="hover:text-orange-500">
            Pricing
          </Link>
        </div>

        {/* Right: Text */}
        <div className="text-center md:text-right max-w-sm">
          <p className="text-xs sm:text-sm text-gray-600 leading-relaxed">
            Digitizing Ethiopian dining experiences with <br /> AI-powered menu
            solutions.
          </p>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
