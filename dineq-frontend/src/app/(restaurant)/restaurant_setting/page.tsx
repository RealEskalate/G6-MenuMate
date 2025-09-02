"use client";

import { useState } from "react";
import SideBar from "../../../components/restaurant/SideBar";
import NavBar from "../../../components/common/NavBar";
import SettingProfile from "./SettingProfile";

const RestaurnatSetting = () => {
  const [activeTab, setActiveTab] = useState("Profile");

  return (
    <div>
      <NavBar />

      {/*The grid Container for side bar and the main body*/}
      <div className="grid grid-cols-6">
        {/*The first column*/}
        <div className="col-span-1">
          <SideBar />
        </div>
        {/*The second column*/}
        <div className="col-span-5 m-4 p-4">
          <h1 className="border font-bold text-xl border-orange-200 rounded-2xl m-4 p-4 w-9/10">
            Settings
          </h1>
          <div className="flex justify-between gap-2 border border-orange-200 rounded-2xl m-4 p-4 w-3/4">
            <button
              onClick={() => setActiveTab("Profile")}
              className="relative text-gray-500 focus:text-orange-500 font-semibold after:content-[''] after:absolute after:left-1/2 after:-translate-x-1/2 after:-bottom-1 after:h-[2px] after:w-0 after:bg-orange-500 after:transition-all after:duration-300 hover:after:w-full focus:after:w-full"
            >
              Profile
            </button>
            <button
              onClick={() => setActiveTab("LegalInfo")}
              className="relative text-gray-500 focus:text-orange-500 font-semibold after:content-[''] after:absolute after:left-1/2 after:-translate-x-1/2 after:-bottom-1 after:h-[2px] after:w-0 after:bg-orange-500 after:transition-all after:duration-300 hover:after:w-full focus:after:w-full"
            >
              Legal Info
            </button>
            <button
              onClick={() => setActiveTab("Branding")}
              className="relative text-gray-500 focus:text-orange-500 font-semibold after:content-[''] after:absolute after:left-1/2 after:-translate-x-1/2 after:-bottom-1 after:h-[2px] after:w-0 after:bg-orange-500 after:transition-all after:duration-300 hover:after:w-full focus:after:w-full"
            >
              Branding
            </button>
            <button
              onClick={() => setActiveTab("Billing")}
              className="relative text-gray-500 focus:text-orange-500 font-semibold after:content-[''] after:absolute after:left-1/2 after:-translate-x-1/2 after:-bottom-1 after:h-[2px] after:w-0 after:bg-orange-500 after:transition-all after:duration-300 hover:after:w-full focus:after:w-full"
            >
              Billing
            </button>
            <button
              onClick={() => setActiveTab("Staff")}
              className="relative text-gray-500 focus:text-orange-500 font-semibold after:content-[''] after:absolute after:left-1/2 after:-translate-x-1/2 after:-bottom-1 after:h-[2px] after:w-0 after:bg-orange-500 after:transition-all after:duration-300 hover:after:w-full focus:after:w-full"
            >
              Staff
            </button>
          </div>
          {/* Restaurant Details Section */}
          {/* Add your restaurant details component here, e.g. <SettingProfile /> */}

          {activeTab === "Profile" && <SettingProfile />}
          {activeTab === "Legal Info" && <h1>Legal Information here</h1>}
          {activeTab === "Branding" && <h1>Branding Settings here</h1>}
          {activeTab === "Billing" && <h1>Billing Info here</h1>}
          {activeTab === "Staff" && <h1>Staff Management here</h1>}
        </div>
      </div>
    </div>
  );
};

export default RestaurnatSetting;
