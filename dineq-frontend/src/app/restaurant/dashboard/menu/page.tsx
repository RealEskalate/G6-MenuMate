"use client";

import React, { useEffect, useState } from "react";
import { Plus, Trash2 } from "lucide-react";
import MenuOptionModal from "@/components/restaurant/MenuOptionModal";
import Image from "next/image";
import Link from "next/link";
import { useSession } from "next-auth/react";

interface Menu {
  id: string;
  slug: string;
  is_published: boolean;
  created_at: string;
  updated_at: string;
  items: any[];
}

function Dashboard() {
  const { data: session } = useSession();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [menus, setMenus] = useState<Menu[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchMenus = async () => {
      if (!session?.accessToken) return;

      try {
        // Step 1: Get restaurant info
        const res = await fetch(
          `${process.env.NEXT_PUBLIC_API_BASE_URL}/restaurants/me`,
          {
            headers: {
              Authorization: `Bearer ${session.accessToken}`,
            },
          }
        );
        const restaurantData = await res.json();
        console.log("🍽 Restaurant data:", restaurantData);
        const restaurantSlug = restaurantData?.restaurants?.[0]?.slug ;
        console.log("🍽 Restaurant slug:", restaurantSlug);


        if (!restaurantSlug) {
          console.error("❌ No restaurant slug found in response");
          return;
        }

        // Step 2: Fetch menus (replace with correct endpoint if you have list)
        const menusRes = await fetch(
          `${process.env.NEXT_PUBLIC_API_BASE_URL}/menus/${restaurantSlug}`,
          {
            headers: {
              Authorization: `Bearer ${session.accessToken}`,
            },
          }
        );

        const menusJson = await menusRes.json();
        setMenus(menusJson.data?.menus ?? []);
      } catch (error) {
        console.error("❌ Error fetching menus:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchMenus();
  }, [session?.accessToken]);

  if (loading) {
    return <p className="p-6">Loading menus...</p>;
  }

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
          <div className="flex flex-col md:flex-row gap-6 flex-wrap">
            {menus.length > 0 ? (
              menus.map((menu) => (
                <div
                  key={menu.id}
                  className="relative w-full md:w-96 bg-white text-black rounded-xl border border-orange-400 p-4 shadow-md"
                >
                  {/* Status + Delete */}
                  <div className="flex justify-between mb-2">
                    <span className="font-bold text-xl">{menu.slug}</span>
                    <div className="flex space-x-4">
                      <span
                        className={`${
                          menu.is_published
                            ? "bg-green-100 text-green-600"
                            : "bg-orange-100 text-orange-600"
                        } text-sm px-3 py-1 rounded-lg flex items-center gap-1`}
                      >
                        <span
                          className={`w-2 h-2 rounded-full ${
                            menu.is_published ? "bg-green-500" : "bg-orange-500"
                          }`}
                        ></span>
                        {menu.is_published ? "Published" : "Draft"}
                      </span>
                      <button className="text-red-500 hover:text-red-700">
                        <Trash2 size={18} />
                      </button>
                    </div>
                  </div>
                  <div className="text-gray-800 text-[12px]">
                    Created {new Date(menu.created_at).toDateString()} - Updated{" "}
                    {new Date(menu.updated_at).toDateString()}
                  </div>

                  {/* Stats */}
                  <div className="flex justify-between mt-6">
                    <div>
                      <div className="flex space-x-3">
                        <div className="py-3 px-5 border border-orange-400 rounded-md">
                          <div className="text-[16px] text-gray-600">Items</div>
                          <div className="font-normal">
                            {menu.items.length} Dishes
                          </div>
                        </div>
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
                    <button className="border border-[#FD7E14] bg-white text-[#FD7E14] px-4 py-2 rounded-md hover:bg-gray-100 font-semibold">
                      Manage QR
                    </button>
                    <Link
                      href={`/restaurant/dashboard/menu/edit-menu/${menu.id}`}
                    >
                      <button className="bg-[#FD7E14] text-white px-4 py-2 rounded-md hover:bg-orange-600 flex items-center gap-1">
                        <Image
                          src="/icons/edit.png"
                          alt="Edit Icon"
                          width={16}
                          height={16}
                        />
                        Edit Menu
                      </button>
                    </Link>
                  </div>
                </div>
              ))
            ) : (
              <p>No menus found.</p>
            )}
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
