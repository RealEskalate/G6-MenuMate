
import React from "react";

// import NavBar from "@/components/common/NavBar";
// import SideBar from "@/components/restaurant/SideBar";
import { Plus, } from "lucide-react";
import Link from "next/link";

function Dashboard() {
  return (
    <div>
      <div className="flex">
        <main className="flex-1 p-6">
          <div className="flex justify-between items-center mb-6 bg-white p-4 rounded-2xl shadow-[0_4px_12px_#ffead4]">
            <div className="font-bold text-2xl">Menus</div>
            <button className="bg-[#FD7E14] text-white px-6 flex py-2 rounded">
              <Plus size={16} />
              Add Menu
            </button>
          </div>
          <div>
            <div>How do you want to create your menu?</div>
            <div className="flex justify-around items-center">
              <Link href="/dashboard/menu/ocr_menu">
              <button className="bg-[#FD7E14]  px-4 py-2 rounded-md">
                Scan With Ocr
              </button>
              </Link>              
              <Link href="/dashboard/menu/manual_menu">
                <button className="bg-[#FD7E14]  px-4 py-2 rounded-md">
                  Add Manually
                </button>
                </Link>
            </div>
          </div>
        </main>
      </div>
    </div>
  );
}

export default Dashboard;
