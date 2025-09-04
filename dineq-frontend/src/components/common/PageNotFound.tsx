import React from "react";
import { FaCheck } from "react-icons/fa";

const PageNotFound = () => {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center px-4 text-center">
      {/* Icon */}
      <div className="flex items-center justify-center w-12 h-12 rounded-full bg-gray-500 mb-4">
        <FaCheck className="text-white text-xl" />
      </div>

      {/* Title */}
      <h1 className="text-4xl md:text-5xl text-gray-500 font-extrabold mb-2">
        404
      </h1>
      <h2 className="text-xl md:text-2xl text-gray-500 font-bold mb-2">
        Page Not Found
      </h2>

      {/* Message */}
      <p className="text-gray-500 text-sm md:text-base max-w-md">
        The page you are looking for does not exist or has been moved.
      </p>

      {/* Button */}
      <button
        type="button"
        className="mt-6 w-full sm:w-auto px-6 py-2 rounded-lg text-white transition"
        style={{ backgroundColor: "var(--color-primary)" }}
      >
        Back to Home
      </button>
    </div>
  );
};

export default PageNotFound;
