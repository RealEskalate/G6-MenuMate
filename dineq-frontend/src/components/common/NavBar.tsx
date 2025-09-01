"use client";
import React, { useEffect, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Menu, X } from "lucide-react";
import logo from "../../../public/logo.png";
import Roles from "@/Types/role";

function NavBar({ role }: Roles) {
  const pathname = usePathname();
  const [open, setOpen] = useState(false);

  useEffect(() => {
    setOpen(false);
  }, [pathname]);

  const linkClasses = (path: string) =>
    pathname === path
      ? "px-4 text-primary underline underline-offset-4 font-medium"
      : "px-4 text-gray-700 hover:text-primary";

  const managerLinks = [
    { name: "Menus", href: "/dashboard/menu", icon: "/icons/menu.svg" },
    { name: "QR Manager", href: "/dashboard/qr-manager", icon: "/icons/qr.png" },
    { name: "Settings", href: "/dashboard/settings", icon: "/icons/setting.png" },
    { name: "Analytics", href: "/dashboard/analytics", icon: "/icons/Analytics.png", pro: true },
  ];

  return (
    <div className="relative border-b shadow-sm border-gray-300 px-6 py-2 flex items-center">
      {/* Logo */}
      <Image src={logo} alt="logo" width={100} height={120} />

      {/* CUSTOMER links */}
      {role === "user" && (
        <div className="hidden md:flex ml-4">
          <Link href="/" className={linkClasses("/")}>Home</Link>
          <Link href="/customer/restaurants" className={linkClasses("/customer/restaurants")}>Restaurants</Link>
          <Link href="/customer/scan" className={linkClasses("/customer/scan")}>Scan</Link>
          <Link href="/customer/favorites" className={linkClasses("/customer/favorites")}>Favorites</Link>
          <Link href="/customer/profile" className={linkClasses("/customer/profile")}>Profile</Link>
        </div>
      )}

  
      {role !== "user" && role !== "MANAGER" && (
        <div className="hidden md:flex ml-4">
          <Link href="/restaurant/about" className={linkClasses("/restaurant/about")}>About</Link>
          <Link href="/restaurant/contact" className={linkClasses("/restaurant/contact")}>Contacts</Link>
        </div>
      )}

      {role === "MANAGER" && (
        <>
          <button
            className="ml-auto md:hidden p-2 rounded-lg hover:bg-gray-100"
            aria-label="Open menu"
            onClick={() => setOpen((p) => !p)}
          >
            {open ? <X size={22} /> : <Menu size={22} />}
          </button>

          {/* Dropdown menu */}
          {open && (
            <div
              className="absolute right-4 top-full mt-2 w-64 rounded-2xl border border-gray-200 bg-white shadow-[0_8px_24px_rgba(0,0,0,0.08)] z-50 p-3"
              role="menu"
            >
              <nav className="flex flex-col gap-2">
                {managerLinks.map((link) => {
                  const active = pathname.startsWith(link.href);
                  return (
                    <Link
                      key={link.name}
                      href={link.href}
                      onClick={() => setOpen(false)}
                      className={`flex items-center gap-3 px-3 py-2 rounded-xl transition-colors ${
                        active ? "bg-orange-50 text-orange-600" : "text-gray-700 hover:bg-gray-50"
                      }`}
                    >
                      <Image src={link.icon} alt={link.name} width={18} height={18} />
                      <span className="flex items-center gap-1 text-sm">
                        {link.name}
                        {link.pro && (
                          <sup className="text-[8px] text-orange-500 px-1 font-bold">PRO</sup>
                        )}
                      </span>
                    </Link>
                  );
                })}
              </nav>
            </div>
          )}
        </>
      )}
    </div>
  );
}

export default NavBar;
