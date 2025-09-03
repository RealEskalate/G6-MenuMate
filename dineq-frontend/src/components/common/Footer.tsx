"use client";

import React from "react";
// import { Utensils } from "lucide-react"; // icon
import Image from "next/image";

const Footer = () => {
  return (
  <footer className="w-full border-t  bg-white px-8 mt-10">
    <div className="flex justify-around items-center w-full">
      {/* Left Section - Logo and Text */}
      <div className="flex flex-col">
        <Image src="/Logo.png" alt="Logo" width={100} height={100} />
        <p className="text-sm text-gray-600 max-w-xs">
          Digitizing Ethiopian dining experiences with AI-powered menu solutions.
        </p>
      </div>

      {/* Right Section - Navigation */}
      <div className="flex justify-between w-1/2 text-gray-700 text-sm font-medium">
        <a href="#" className="hover:text-orange-500 text-center">Home</a>
        <a href="#" className="hover:text-orange-500 text-center">Features</a>
        <a href="#" className="hover:text-orange-500 text-center">Pricing</a>
      </div>
    </div>
  </footer>

  );
};


export default Footer;
