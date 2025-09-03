"use client";

import React from "react";
import OpeningHours from "./components/OpeningHours";

const SettingProfile = () => {
  return (
    <div className="w-full h-full max-w-full max-h-full overflow-auto lg:w-auto lg:h-auto lg:overflow-visible">
      <h1 className="font-semibold text-2xl">Restaurant Details</h1>
      {/* Restaurant Details and Country Type */}
      <div className="grid grid-cols-1 min-w-[200px] md:grid-cols-2 gap-x-8 gap-y-6 mt-5">
        {/* Restaurant Name Field */}
        <div>
          <label
            htmlFor="restaurant_name"
            className="block font-semibold text-base text-gray-700 mb-2"
          >
            Restaurant name
          </label>
          <input
            type="text"
            id="restaurant_name"
            className="block w-full border border-gray-300 rounded-lg p-2.5 focus:ring-blue-500 focus:border-blue-500"
          />
        </div>

        {/* Country Field */}
        <div>
          <label
            htmlFor="country"
            className="block font-semibold text-base text-gray-700 mb-2"
          >
            Country
          </label>
          <select
            id="country"
            className="block w-full border border-gray-300 rounded-lg p-2.5 focus:ring-blue-500 focus:border-blue-500"
          >
            <option value="Ethiopia">Ethiopia</option>
            <option value="Kenya">Kenya</option>
            <option value="Uganda">Uganda</option>
          </select>
        </div>
      </div>

      {/* Restaurant Photo upload */}
      <div className="flex flex-col md:flex-row gap-10 mt-10 justify-between">
        <div>
          {/* Logo Upload area*/}
          <label
            htmlFor="logo"
            className="block text-sm font-medium text-gray-700 mb-1"
          >
            Logo
          </label>

          <label
            htmlFor="logo"
            className="flex flex-col items-center justify-center w-full bg-white border border-gray-300 rounded-lg cursor-pointer hover:bg-gray-50 transition-colors md:w-[24rem] max-w-md h-40 "
          >
            <div className="flex flex-col items-center justify-center pt-5 pb-6">
              {/* Icon */}
              <svg
                className="w-8 h-8 mb-3 text-gray-400"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                strokeWidth="1.5"
                stroke="currentColor"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M2.25 15.75l5.159-5.159a2.25 2.25 0 013.182 0l5.159 5.159m-1.5-1.5l1.409-1.409a2.25 2.25 0 013.182 0l2.909 2.909m-18 3.75h16.5a1.5 1.5 0 001.5-1.5V6a1.5 1.5 0 00-1.5-1.5H3.75A1.5 1.5 0 002.25 6v12a1.5 1.5 0 001.5 1.5zm10.5-11.25h.008v.008h-.008V8.25zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0z"
                />
              </svg>

              {/* Text */}
              <p className="text-sm text-gray-600">Upload photo</p>
            </div>

            {/* Your original file input, now correctly linked and hidden */}
            <input type="file" id="logo" className="hidden" accept="image/*" />
          </label>
        </div>
        {/* logo upload area ends */}

        {/* Banner upload area */}
        <div>
          <label
            htmlFor="banner"
            className="block text-sm font-medium text-gray-700 mb-1"
          >
            Cover/Banner
          </label>

          {/* This new label acts as the clickable, styled upload area */}
          <label
            htmlFor="banner"
            className="flex flex-col items-center justify-center w-full bg-white border border-gray-300 rounded-lg cursor-pointer hover:bg-gray-50 transition-colors md:w-[24rem] max-w-md h-40 "
          >
            <div className="flex flex-col items-center justify-center pt-5 pb-6">
              {/* Icon */}
              <svg
                className="w-8 h-8 mb-3 text-gray-400"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                strokeWidth="1.5"
                stroke="currentColor"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M2.25 15.75l5.159-5.159a2.25 2.25 0 013.182 0l5.159 5.159m-1.5-1.5l1.409-1.409a2.25 2.25 0 013.182 0l2.909 2.909m-18 3.75h16.5a1.5 1.5 0 001.5-1.5V6a1.5 1.5 0 00-1.5-1.5H3.75A1.5 1.5 0 002.25 6v12a1.5 1.5 0 001.5 1.5zm10.5-11.25h.008v.008h-.008V8.25zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0z"
                />
              </svg>

              {/* Text */}
              <p className="text-sm text-gray-600">Upload photo</p>
            </div>

            {/* Your original file input, now correctly linked and hidden */}
            <input
              type="file"
              id="banner"
              className="hidden"
              accept="image/*"
            />
          </label>
        </div>
      </div>
      {/* Restaurant Photo upload end */}

      {/*Description*/}
      <div className="w-full md:w-[51rem] mt-3">
        <label
          htmlFor="description"
          className="block text-sm font-medium text-gray-700 mb-1"
        >
          Description
        </label>

        <div className="relative">
          <textarea
            id="description"
            rows={4}
            className="block w-full px-4 py-3 pr-12 text-gray-900 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            placeholder="Enter a description..."
            defaultValue="Authentic Ethiopian flavours"
          />

          <div className="absolute top-3.5 right-4">
            <button className="text-gray-400 hover:text-gray-600">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                strokeWidth="1.5"
                stroke="currentColor"
                className="w-5 h-5"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M16.862 4.487l1.687-1.688a1.875 1.875 0 112.652 2.652L10.582 16.07a4.5 4.5 0 01-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 011.13-1.897l8.932-8.931zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0115.75 21H5.25A2.25 2.25 0 013 18.75V8.25A2.25 2.25 0 015.25 6H10"
                />
              </svg>
            </button>
          </div>
        </div>
      </div>

      {/* START: Contact Details Section */}
      <div className="mt-8">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-6">
          {/* Email Field */}
          <div>
            <label
              htmlFor="email"
              className="block text-sm font-medium text-gray-700"
            >
              email
            </label>
            <div className="mt-1 relative">
              <input
                type="email"
                id="email"
                className="block w-full px-4 py-3 pr-10 text-gray-900 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                defaultValue="yohannesT@gmail.com"
              />
              <div className="absolute inset-y-0 right-0 pr-3 flex items-center">
                <button className="text-gray-400 hover:text-gray-600">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                    strokeWidth="1.5"
                    stroke="currentColor"
                    className="w-5 h-5"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      d="M16.862 4.487l1.687-1.688a1.875 1.875 0 112.652 2.652L6.832 19.82a4.5 4.5 0 01-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 011.13-1.897L16.863 4.487zm0 0L19.5 7.125"
                    />
                  </svg>
                </button>
              </div>
            </div>
          </div>

          {/* Phone Number Field */}
          <div>
            <label
              htmlFor="phone-number"
              className="block text-sm font-medium text-gray-700"
            >
              Phone number
            </label>
            <div className="mt-1 relative">
              <input
                type="tel"
                id="phone-number"
                className="block w-full px-4 py-3 pr-10 text-gray-900 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                defaultValue="+251 9 000000"
              />
              <div className="absolute inset-y-0 right-0 pr-3 flex items-center">
                <button className="text-gray-400 hover:text-gray-600">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                    strokeWidth="1.5"
                    stroke="currentColor"
                    className="w-5 h-5"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      d="M16.862 4.487l1.687-1.688a1.875 1.875 0 112.652 2.652L6.832 19.82a4.5 4.5 0 01-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 011.13-1.897L16.863 4.487zm0 0L19.5 7.125"
                    />
                  </svg>
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Location Field */}
        <div className="mt-6">
          <label
            htmlFor="location"
            className="block text-sm font-medium text-gray-700"
          >
            Location
          </label>
          <div className="mt-1 relative">
            <input
              type="text"
              id="location"
              className="block w-full px-4 py-3 pr-10 text-gray-900 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              defaultValue="Bole, Addis Ababa"
            />
            <div className="absolute inset-y-0 right-0 pr-3 flex items-center">
              <button className="text-gray-400 hover:text-gray-600">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  strokeWidth="1.5"
                  stroke="currentColor"
                  className="w-5 h-5"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M16.862 4.487l1.687-1.688a1.875 1.875 0 112.652 2.652L6.832 19.82a4.5 4.5 0 01-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 011.13-1.897L16.863 4.487zm0 0L19.5 7.125"
                  />
                </svg>
              </button>
            </div>
          </div>
        </div>

        {/* Map Image */}
        <div className="mt-4">
          <img
            src="https://i.imgur.com/4l34n4A.png" // Placeholder map image
            alt="Location map"
            className="w-full h-48 object-cover rounded-lg border border-gray-300"
          />
        </div>
      </div>
      {/* END: Contact Details Section */}

      {/* START: Opening Hours Section */}

      <OpeningHours />

      {/* END: Opening Hours Section */}
    </div>
  );
};

export default SettingProfile;
