"use client"
import Sidebar from "@/components/restaurant/SideBar";
import Navbar from "@/components/common/NavBar";
import { useSession } from "next-auth/react";
import { useRestaurant } from "@/hooks/useRestaurant";
import { MenuProvider } from "@/context/MenuOcrContext"; 

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { data: session, status } = useSession();
  const { data, isLoading, error } = useRestaurant(session?.accessToken);

  const restaurant = data?.restaurants?.[0];

  return (
    <MenuProvider>
      <div className="">
        <Navbar role="MANAGER" />
        <div className="flex gap-8">
          <Sidebar />
          <section className="mt-8 pt-2 bg-white rounded-lg shadow-sm max-w-4xl w-full">
            {status === "loading" || isLoading ? (
              <p>Loading restaurant...</p>
            ) : error ? (
              <p>Error loading restaurant</p>
            ) : !restaurant ? (
              <p>No restaurant found</p>
            ) : (
              children
            )}
          </section>
        </div>
      </div>
    </MenuProvider>
  );
}
