"use client";

import React from "react";
import { Utensils } from "lucide-react"; // icon

const Footer = () => {
  return (
    <footer className="w-full border-t bg-white">
      <div className="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-center py-6 px-6 md:px-12">
        {/* Left Section - Logo + Text */}
        <div className="flex flex-col items-start space-y-2">
          <div className="flex items-center space-x-2">
            <div className="bg-orange-500 text-white p-2 rounded-lg">
              <Utensils className="w-5 h-5" />
            </div>
            <span className="text-xl font-bold text-orange-500">MenuMate</span>
          </div>
          <p className="text-sm text-gray-600 max-w-xs">
            Digitizing Ethiopian dining experiences with AI-powered menu
            solutions.
          </p>
        </div>

        {/* Right Section - Navigation */}
        <div className="flex space-x-8 mt-4 md:mt-0 text-gray-700 text-sm font-medium">
          <a href="#" className="hover:text-orange-500">
            Home
          </a>
          <a href="#" className="hover:text-orange-500">
            Features
          </a>
          <a href="#" className="hover:text-orange-500">
            Pricing
          </a>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
