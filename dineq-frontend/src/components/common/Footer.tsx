"use client";

import React from "react";
import { Utensils } from "lucide-react"; // icon
import Image from "next/image";

const Footer = () => {
  return (
    <footer className="w-full border-t border-gray-200 bg-white">
      <div className="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-center py-6 px-6 md:px-12">
        {/* Left Section - Logo + Text */}
        <div className="flex flex-col items-center md:items-start space-y-2 text-center md:text-left">
          <div className="flex items-center justify-center md:justify-start space-x-2">
            
              <div className="flex items-center space-x-2">
                        
                          <Image src="/Logo.png" alt="Logo" width={100} height={100} />
                        
              </div>
            </div>
            
          </div>
          <p className="text-sm text-gray-600 max-w-xs">
            Digitizing Ethiopian dining experiences with AI-powered menu
            solutions.
          </p>
        </div>

        {/* Right Section - Navigation */}
        <div className="flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-8 mt-4 md:mt-0 text-gray-700 text-sm font-medium">
          <a href="#" className="hover:text-orange-500 text-center">
            Home
          </a>
          <a href="#" className="hover:text-orange-500 text-center">
            Features
          </a>
          <a href="#" className="hover:text-orange-500 text-center">
            Pricing
          </a>
        </div>
      
    </footer>
  );
};


export default Footer;
