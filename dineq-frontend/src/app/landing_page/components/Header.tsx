"use client";

import { useState, useEffect } from "react";
import Image from "next/image";
import Link from "next/link";

export default function Header() {
  const [isOpen, setIsOpen] = useState(false);
  const [isScrolled, setIsScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 10); // threshold: 10px
    };

    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  return (
    <div className="relative">
      <header
        className={`fixed top-0 left-1/2 transform -translate-x-1/2 
                    border border-orange-400 rounded-2xl 
                    shadow-lg py-4 px-6 md:px-12 lg:px-24 
                    flex items-center justify-between w-[90%] md:w-[80%] lg:w-[70%] z-50
                    transition-colors duration-300 ${
                      isScrolled ? "bg-white/30 backdrop-blur-sm" : "bg-white"
                    }`}
      >
        <div className="flex items-center space-x-2">
          <Image src="/Logo.png" alt="Logo" width={100} height={100} />
        </div>

        {/* Desktop Menu */}
        <div className="hidden md:flex items-center space-x-4">
          <a href="/auth/signin" className="text-gray-600 hover:text-orange-500">
            Log in
          </a>
          <Link
            href="/user-routes/whoareyou"
            className="bg-orange-500 text-white px-4 py-2 rounded-md hover:bg-orange-600"
          >
            Get started
          </Link>
        </div>

        {/* Mobile Menu Button */}
        <div className="md:hidden">
          <button onClick={() => setIsOpen(!isOpen)}>
            <svg
              className="w-6 h-6"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth="2"
                d="M4 6h16M4 12h16m-7 6h7"
              />
            </svg>
          </button>
        </div>
      </header>

      {/* Mobile Dropdown */}
      {isOpen && (
        <div
          className={`fixed top-[76px] left-1/2 transform -translate-x-1/2 
                      w-[90%] md:w-[80%] lg:w-[70%] 
                      bg-orange-50/95 border border-yellow-400 rounded-3xl shadow-lg 
                      p-4 md:hidden z-40`}
        >
          <Link
            href="#"
            className="block hover:bg-amber-500 text-gray-600 rounded-md p-2"
          >
            Log in
          </Link>
          <Link
            href="#"
            className="block hover:bg-amber-500 text-gray-600 rounded-md mt-2 p-2"
          >
            Get started
          </Link>
        </div>
      )}
    </div>
  );
}
