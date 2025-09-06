"use client"

import NavBar from "@/components/common/NavBar";
import { RegisterProvider } from "@/context/RegisterContext";
import { SessionProvider } from "next-auth/react";

export default function RegisterLayout({ children }: { children: React.ReactNode }) {
  return (
    <SessionProvider>
      <RegisterProvider>
      <div className="min-h-screen bg-gray-50 flex flex-col">
        {/* Navbar */}
        <NavBar role="MANAGER" />

        <main className="flex flex-1 justify-center p-4 "> 
          <section className="bg-white rounded-lg shadow-sm max-w-4xl w-full"> 
            {children}
          </section>
        </main>
      </div>
    </RegisterProvider>
    </SessionProvider>
  );
}