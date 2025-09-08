"use client";
import { Toaster } from "react-hot-toast";
import Sidebar from "@/components/restaurant/SideBar";
import Navbar from "@/components/common/NavBar";
import { useSession } from "next-auth/react";
import { useRestaurant } from "@/hooks/useRestaurant";
import { MenuProvider } from "@/context/MenuOcrContext";
import { Building2 } from "lucide-react";

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { data: session, status } = useSession();
  const { data, isLoading, error } = useRestaurant(session?.accessToken);

  const restaurant = data;

  return (
    <MenuProvider>
      <div className="">
        <Toaster position="top-right" />
        <Navbar role="MANAGER" />
        <div className="flex gap-8">
          <Sidebar />
          <section className="mt-8 pt-2 bg-white rounded-lg shadow-sm max-w-4xl w-full">
            {status === "loading" || isLoading ? (
              <div className="flex flex-col items-center justify-center py-20">
                {/* Orange spinner */}
                <div className="animate-spin h-12 w-12 border-4 border-orange-500 border-dashed rounded-full mb-4"></div>


                <span className="text-gray-700 font-medium">Loading restaurant...</span>
              </div>
            ) : error ? (
              <p className="text-red-500 font-medium px-6 py-4">Error loading restaurant</p>
            ) : !restaurant ? (
              <div className="flex flex-col items-center justify-center text-center py-20">
                <div className="bg-orange-100 text-orange-500 p-4 rounded-full mb-4">
                  <Building2 className="w-10 h-10" />
                </div>
                <h2 className="text-lg font-semibold mb-2">No restaurant found</h2>
                <p className="text-gray-500 mb-6">
                  You don’t have any restaurants linked to your account yet.
                </p>
             </div>
            ) : (
              children
            )}
          </section>
        </div>
      </div>
    </MenuProvider>
  );
}
