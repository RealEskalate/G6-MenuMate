import React from "react";
import SideBar from "../../../components/restaurant/SideBar";
import NavBar from "../../../components/common/NavBar";
import Image from "next/image";
const AnalyticsPage = () => {
  return (
    <div>
      <NavBar />
      {/*The grid Container*/}
      <div className="grid grid-cols-5">
        {/*The first column*/}
        <div className="col-span-1">
          <SideBar />
        </div>
        {/*The second column*/}
        <div className="col-span-4 border border-orange-200 rounded-2xl h-[24rem] m-4 p-4 ">
          <h1 className="border border-orange-200 rounded-2xl m-4 p-4">
            Analytics
          </h1>
          <div className="flex justify-between mb-7">
            <h1 className="pl-5 ">Analytics Overview</h1>
            <div className="pr-1">
              <button className="border flex-1 rounded-2xl border-gray-200 p-3 mr-3 hover:bg-orange-300">
                Today
              </button>
              <button className="border flex-1 rounded-2xl border-gray-200 p-3 mr-3 hover:bg-orange-300">
                Week
              </button>
              <button className="border flex-1 rounded-2xl border-gray-200 p-3 mr-3 hover:bg-orange-300">
                Month
              </button>
              <button className="border flex-1 rounded-2xl border-gray-200 p-3 mr-3 hover:bg-orange-300">
                Year
              </button>
            </div>
          </div>

          <div className="flex justify-evenly">
            <div className="flex gap-2  w-[12rem] h-[12rem] border border-orange-200 rounded-2xl items-start">
              <Image
                src="/groupOfPeople.png"
                alt="Group of People"
                width={30}
                height={30}
                style={{ objectFit: "contain" }}
              ></Image>

              <p>Total Menu Views</p>
            </div>

            <div className="flex gap-2 w-[12rem] h-[12rem] border border-orange-200 rounded-2xl items-start">
              <Image
                src="/groupOfPeople.png"
                alt="Group of People"
                width={30}
                height={30}
                style={{ objectFit: "contain" }}
              ></Image>

              <p>Total QR Scan</p>
            </div>

            <div className="flex gap-2 w-[12rem] h-[12rem] border border-orange-200 rounded-2xl items-start">
              <Image
                src="/star.png"
                alt="Group of People"
                width={30}
                height={30}
                style={{ objectFit: "contain" }}
              ></Image>

              <p>Average Rating</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AnalyticsPage;
