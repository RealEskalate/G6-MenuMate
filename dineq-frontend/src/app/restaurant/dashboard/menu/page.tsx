"use client";
import React, { useState } from "react";
import { Plus, Trash2 } from "lucide-react";
import MenuOptionModal from "@/components/restaurant/MenuOptionModal";
import Image from "next/image";
import Link from "next/link";

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
          <div className="flex flex-col md:flex-row gap-6">
            <div className="relative w-full md:w-96 bg-white text-black rounded-xl border border-orange-400 p-4 shadow-md">
              {/* Status + Delete */}
              <div className="flex justify-between  mb-2">
                <span className="font-bold text-xl">Main Menu</span>
                <div className="flex space-x-4">
                  <span className="bg-orange-100 text-orange-600 text-sm px-3 py-1 rounded-lg flex items-center gap-1">
                    <span className="w-2 h-2 bg-orange-500 rounded-full"></span>
                    Published
                  </span>
                  <button className="text-red-500 hover:text-red-700">
                    <Trash2 size={18} />
                  </button>
                </div>
              </div>
              <div className="text-gray-800 text-[12px]">
                Created Jan 5,2025 - Updated Mar 18,2025
              </div>

              {/* Empty boxes */}
              <div className=" flex justify-between mt-6">
                <div className="">
                  <div className="flex space-x-3 space-y-2">
                    <div className=" py-3 px-5 border border-orange-400 rounded-md">
                      <div className="text-[16px] text-gray-600">Items</div>
                      <div className="font-normal">12 Dishes</div>
                    </div>
                    <div className=" py-2 px-5 border border-orange-400 rounded-md">
                      <div className="text-[16px] text-gray-600">Languages</div>
                      <div className="flex space-x-2 pt-1">
                        <span className="border border-gray-700 text-gray-700 rounded-md p-0.5">
                          Amh
                        </span>
                        <span className="border border-gray-700 text-gray-700 rounded-md p-0.5 ">
                          Eng
                        </span>
                      </div>
                    </div>
                  </div>
                  <div className="py-3 px-5 border border-orange-400 rounded-md w-1/2">
                    <div className="text-[16px] text-gray-600">Avg rating</div>
                    <div className="font-normal">4.3</div>
                  </div>
                </div>
                <div>
                  <Image
                    src="/Vector.png"
                    alt="Menu Image"
                    width={100}
                    height={100}
                    className="pt-6 pr-1"
                  />
                </div>
              </div>

              {/* Buttons */}
              <div className="flex justify-between mt-6">
                <button className="border border-[#FD7E14]  bg-white text-[#FD7E14] px-4 py-2 rounded-md  hover:bg-gray-100 font-semibold">
                  Manage QR
                </button>
                <Link href="/restaurant/dashboard/menu/edit-menu">
                  <button className="bg-[#FD7E14]  text-white px-4 py-2 rounded-md hover:bg-orange-600 flex items-center gap-1">
                    <Image
                      src="/icons/edit.png"
                      alt="Edit Icon"
                      width={16}
                      height={16}
                    />{" "}
                    Edit Menu
                  </button>
                </Link>
              </div>
            </div>

  <div className="relative w-full md:w-96 bg-white text-black rounded-xl border border-orange-400 p-4 shadow-md">
              {/* Status + Delete */}
              <div className="flex justify-between  mb-2">
                <span className="font-bold text-xl">Main Menu</span>
                <div className="flex space-x-4">
                  <span className="bg-orange-100 text-orange-600 text-sm px-3 py-1 rounded-lg flex items-center gap-1">
                    <span className="w-2 h-2 bg-orange-500 rounded-full"></span>
                    Published
                  </span>
                  <button className="text-red-500 hover:text-red-700">
                    <Trash2 size={18} />
                  </button>
                </div>
              </div>
              <div className="text-gray-800 text-[12px]">
                Created Jan 5,2025 - Updated Mar 18,2025
              </div>

              {/* Empty boxes */}
              <div className=" flex justify-between mt-6">
                <div className="">
                  <div className="flex space-x-3 space-y-2">
                    <div className=" py-3 px-5 border border-orange-400 rounded-md">
                      <div className="text-[16px] text-gray-600">Items</div>
                      <div className="font-normal">12 Dishes</div>
                    </div>
                    <div className=" py-2 px-5 border border-orange-400 rounded-md">
                      <div className="text-[16px] text-gray-600">Languages</div>
                      <div className="flex space-x-2 pt-1">
                        <span className="border border-gray-700 text-gray-700 rounded-md p-0.5">
                          Amh
                        </span>
                        <span className="border border-gray-700 text-gray-700 rounded-md p-0.5">
                          Eng
                        </span>
                      </div>
                    </div>
                  </div>
                  <div className="py-3 px-5 border border-orange-400 rounded-md w-1/2">
                    <div className="text-[16px] text-gray-600">Avg rating</div>
                    <div className="font-medium">4.3</div>
                  </div>
                </div>
                <div>
                  <Image
                    src="/Vector.png"
                    alt="Menu Image"
                    width={100}
                    height={100}
                    className="pt-6 pr-1"
                  />
                </div>
              </div>

              {/* Buttons */}
              <div className="flex justify-between mt-6">
                <button className="border border-[#FD7E14]  bg-white text-[#FD7E14] px-4 py-2 rounded-md  hover:bg-gray-100 font-semibold">
                  Manage QR
                </button>
                <Link href="/restaurant/dashboard/menu/edit-menu">
                  <button className="bg-[#FD7E14]  text-white px-4 py-2 rounded-md hover:bg-orange-600 flex items-center gap-1">
                    <Image
                      src="/icons/edit.png"
                      alt="Edit Icon"
                      width={16}
                      height={16}
                    />{" "}
                    Edit Menu
                  </button>
                </Link>
              </div>
            </div>
          </div>
        </main>
      </div>

      {/* Popup Modal */}
      <MenuOptionModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
      />
    </div>
  );
}

export default Dashboard;
