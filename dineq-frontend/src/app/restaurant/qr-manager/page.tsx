import React from "react";
import NavBar from "@/components/common/NavBar";
import SideBar from "@/components/restaurant/SideBar";

function QrManager() {
  return (
    <>
      <NavBar role="MANAGER" />
      <div className="flex">
        <SideBar />
        <main className="flex-1 p-6">
          {/* Header */}
          <div className="flex justify-between items-center mb-6 bg-white p-4 rounded-2xl shadow-[0_4px_12px_#ffead4]">
            <div className="font-bold text-2xl">QR Manager</div>
          </div>

          {/* QR Cards */}
          <div className="flex px-5 space-x-5">
            {/* Card 1 */}
            <div className="rounded-2xl px-12 py-8 shadow-[0_4px_12px_#ffead4] flex flex-col items-center">
              <img
                src="/icons/qrcode.png"
                alt="QR Code"
                width={110}
                height={105}
                className="mb-3"
              />
              <span className="font-bold mb-4">Main Menu</span>
              <div className="flex space-x-4">
                <button className="flex items-center rounded-lg bg-white shadow-lg shadow-orange-100 hover:shadow-orange-500 transition text-orange-500 px-3 py-2">
                  <img
                    src="/icons/share.png"
                    alt="Share"
                    className="w-4 h-4 mr-2"
                  />
                  <span>Share</span>
                </button>

                <button className="flex items-center rounded-lg bg-orange-500 shadow-lg shadow-orange-400 hover:shadow-orange-500 transition text-white px-3 py-2">
                  <img
                    src="/icons/edit.png"
                    alt="Edit"
                    className="w-4 h-4 mr-2"
                  />
                  Customize
                </button>
              </div>
            </div>

            {/* Card 2 */}
            <div className="rounded-2xl px-12 py-8 shadow-[0_4px_12px_#ffead4] flex flex-col items-center">
              <img
                src="/icons/qrcode.png"
                alt="QR Code"
                width={110}
                height={105}
                className="mb-3"
              />
              <span className="font-bold mb-4">Fasting Menu</span>
              <div className="flex space-x-4">
                <button className="flex items-center rounded-lg bg-white shadow-lg shadow-orange-100 hover:shadow-orange-500 transition text-orange-500 px-3 py-2">
                  <img
                    src="/icons/share.png"
                    alt="Share"
                    className="w-4 h-4 mr-2"
                  />
                  <span>Share</span>
                </button>
                <a href="/qr-manager/customize">

                <button className="flex items-center rounded-lg bg-orange-500 shadow-lg shadow-orange-400 hover:shadow-orange-500 transition text-white px-3 py-2">
                  <img
                    src="/icons/edit.png"
                    alt="Edit"
                    className="w-4 h-4 mr-2"
                  />
                  Customize
                </button>
                </a>
              </div>
            </div>
          </div>
        </main>
      </div>
    </>
  );
}

export default QrManager;
