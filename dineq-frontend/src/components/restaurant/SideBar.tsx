import React from 'react'
import Image from 'next/image'
function SideBar() {
  return (
    <>
      <aside className="w-64  h-[82.5vh] bg-white border border-gray-200 p-4 flex flex-col gap-6 rounded-2xl shadow-[0_4px_12px_#ffd2a9] ml-6 mt-8">
        <div className="space-y-6 pt-6 pb-32 pl-4 pr-5">
          <button className="flex items-center gap-3 text-orange-600 font-medium">
            <Image src="/icons/menu.svg" alt="Menus" width={18} height={18} />{" "}
            Menus
          </button>
          <button className="flex items-center gap-3 text-gray-600 hover:text-orange-600">
            <Image src="/icons/qr.png" alt="QR" width={18} height={18} /> QR
            Manager
          </button>
          <button className="flex items-center gap-3 text-gray-600 hover:text-orange-600">
            <Image
              src="/icons/setting.png"
              alt="Settings"
              width={18}
              height={18}
            />{" "}
            Settings
          </button>
          <button className="flex items-center gap-3 text-gray-600 hover:text-orange-600">
            <Image
              src="/icons/Analytics.png"
              alt="Analytics"
              width={18}
              height={18}
            />
            <div>
              Analytics
              <sup className=" text-[8px] text-orange-500 px-1 font-bold">
                PRO
              </sup>
            </div>
          </button>
        </div>
      </aside>
    </>
  );
}


export default SideBar;
