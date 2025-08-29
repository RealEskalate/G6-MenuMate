"use client";
import React, { useState } from "react";
import { Plus, Trash2 } from "lucide-react";
import Link from "next/link";
import MenuOptionModal from "@/components/restaurant/MenuOptionModal";

function Dashboard() {
  const [isModalOpen, setIsModalOpen] = useState(false);

  return (
    <div>
      <div className="flex">
        <main className="flex-1 px-6">
          {/* Header */}
          <div className="flex justify-between items-center mb-6 bg-white p-4 rounded-2xl shadow-[0_4px_12px_#ffead4]">
            <div className="font-bold text-2xl">Menus</div>
            <button
              onClick={() => setIsModalOpen(true)}
              className="bg-[#FD7E14] text-white px-6 flex py-2 rounded"
            >
              <Plus size={16} />
              Add Menu
            </button>
          </div>

          {/* Menu cards */}
          <div className="flex gap-6">
            <div className="relative w-96 bg-white text-black rounded-xl border border-orange-400 p-4">
              {/* Status + Delete */}
              <div className="flex justify-between items-start">
                <span>Main Menu</span>
                <span className="bg-orange-100 text-orange-600 text-sm px-3 py-1 rounded-lg flex items-center gap-1">
                  <span className="w-2 h-2 bg-orange-500 rounded-full"></span>
                  Published
                </span>
                <button className="text-red-500 hover:text-red-700">
                  <Trash2 size={18} />
                </button>
              </div>
              <div>Created Jan 5,2025 - Updated Mar 18,2025</div>

              {/* Empty boxes */}
              <div className="grid grid-cols-2 gap-3 mt-6">
                <div className="h-16 border border-orange-400 rounded-md">
                  <div>Items</div>
                  <div>12 dishes</div>
                </div>
                <div className="h-16 border border-orange-400 rounded-md">
                  <div>Languages</div>
                  <div>
                    <span>Amh</span>
                    <span>Eng</span>
                  </div>
                </div>
                <div className="h-16 border border-orange-400 rounded-md col-span-1">
                  <div>Avg rating</div>
                  <div>4.3</div>
                </div>
                <div>
                  <img src="/Vector.png" alt="Menu Image" width={100} />
                </div>
              </div>

              {/* Buttons */}
              <div className="flex justify-between mt-6">
                <button className="bg-white text-black px-4 py-2 rounded-md hover:bg-gray-100">
                  Manage QR
                </button>
                <button className="bg-orange-500 text-white px-4 py-2 rounded-md hover:bg-orange-600 flex items-center gap-1">
                  ✏️ Edit Menu
                </button>
              </div>
            </div>

            <div className="relative w-96 bg-white text-black rounded-xl border border-orange-400 p-4">
              {/* Status + Delete */}
              <div className="flex justify-between items-start">
                <span>Main Menu</span>
                <span className="bg-orange-100 text-orange-600 text-sm px-3 py-1 rounded-lg flex items-center gap-1">
                  <span className="w-2 h-2 bg-orange-500 rounded-full"></span>
                  Published
                </span>
                <button className="text-red-500 hover:text-red-700">
                  <Trash2 size={18} />
                </button>
              </div>
              <div>Created Jan 5,2025 - Updated Mar 18,2025</div>

              {/* Empty boxes */}
              <div className="grid grid-cols-2 gap-3 mt-6">
                <div className="h-16 border border-orange-400 rounded-md">
                  <div>Items</div>
                  <div>12 dishes</div>
                </div>
                <div className="h-16 border border-orange-400 rounded-md">
                  <div>Languages</div>
                  <div>
                    <span>Amh</span>
                    <span>Eng</span>
                  </div>
                </div>
                <div className="h-16 border border-orange-400 rounded-md col-span-1">
                  <div>Avg rating</div>
                  <div>4.3</div>
                </div>
                <div>
                  <img src="/Vector.png" alt="Menu Image" width={100} />
                </div>
              </div>

              {/* Buttons */}
              <div className="flex justify-between mt-6">
                <button className="bg-white text-black px-4 py-2 rounded-md hover:bg-gray-100">
                  Manage QR
                </button>
                <button className="bg-orange-500 text-white px-4 py-2 rounded-md hover:bg-orange-600 flex items-center gap-1">
                  ✏️ Edit Menu
                </button>
              </div>
            </div>
          </div>
        </main>
      </div>

      {/* Popup Modal */}
      <MenuOptionModal isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} />
    </div>
  );
}

export default Dashboard;
