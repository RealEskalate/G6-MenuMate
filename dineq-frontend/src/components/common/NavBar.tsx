"use client";
import React, { useEffect, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Menu, X } from "lucide-react";
import Roles from "@/Types/role";

function NavBar({ role }: Roles) {
  const pathname = usePathname();
  const [open, setOpen] = useState(false);

  // Close dropdown on route change
  useEffect(() => {
    setOpen(false);
  }, [pathname]);

  const linkClasses = (path: string) =>
    pathname === path
      ? "px-4 text-[var(--color-primary)] underline underline-offset-10 font-medium"
      : "px-4 text-gray-700 hover:text-[var(--color-primary)]";

  const managerLinks = [
    { name: "Menus", href: "/dashboard/menu", icon: "/icons/menu.svg" },
    { name: "QR Manager", href: "/dashboard/qr-manager", icon: "/icons/qr.png" },
    { name: "Settings", href: "/dashboard/settings", icon: "/icons/setting.png" },
    { name: "Analytics", href: "/dashboard/analytics", icon: "/icons/Analytics.png", pro: true },
  ];

  const extraManagerLinks = [
    { name: "About", href: "/restaurant/about" },
    { name: "Contact Us", href: "/restaurant/contact" },
  ];

  return (
    <div className="relative border-b shadow-sm border-gray-200 px-6 py-2 flex items-center justify-between">
      {/* Logo */}
      <Image src="/logo.png" alt="logo" width={100} height={120} />

      {/* CUSTOMER links */}
      {role === "USER" && (
        <div className="hidden md:flex ml-4">
          <Link href="/user" className={linkClasses("/user")}>Home</Link>
          
          <Link href="/user/scan" className={linkClasses("/user/scan")}>Scan</Link>
          <Link href="/user/favorites" className={linkClasses("/user/favorites")}>Favorites</Link>
          <Link href="/user/profile" className={linkClasses("/user/profile")}>Profile</Link>
        </div>
      )}

      {/* MANAGER desktop links */}
      {role === "MANAGER" && (
        <div className="hidden md:flex ml-auto">
          {extraManagerLinks.map((link) => (
            <Link key={link.name} href={link.href} className={linkClasses(link.href)}>
              {link.name}
            </Link>
          ))}
        </div>
      )}

      {/* MOBILE hamburger (USER or MANAGER) */}
      <div className="md:hidden ml-auto relative">
        <button
          className="p-2 rounded-lg hover:bg-gray-100"
          aria-label="Toggle menu"
          onClick={() => setOpen((p) => !p)}
        >
          {open ? <X size={22} /> : <Menu size={22} />}
        </button>

        {open && (
          <div className="absolute right-0 top-full mt-2 w-64 rounded-2xl border border-gray-200 bg-white shadow-lg z-50 p-3">
            <nav className="flex flex-col gap-2">
              {role === "MANAGER" &&
                managerLinks.map((link) => {
                  const active = pathname.startsWith(link.href);
                  return (
                    <Link
                      key={link.name}
                      href={link.href}
                      onClick={() => setOpen(false)}
                      className={`flex items-center gap-3 px-3 py-2 rounded-xl transition-colors ${
                        active
                          ? "bg-orange-50 text-primary underline underline-offset-4 font-medium"
                          : "text-gray-700 hover:bg-gray-50"
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

              {/* USER links */}
              {role === "USER" &&
                [
                  { name: "Home", href: "/user" },
                 
                  { name: "Scan", href: "/user/scan" },
                  { name: "Favorites", href: "/user/favorites" },
                  { name: "Profile", href: "/user/profile" },
                ].map((link) => (
                  <Link
                    key={link.name}
                    href={link.href}
                    onClick={() => setOpen(false)}
                    className={`px-3 py-2 rounded-xl text-sm ${
                      pathname === link.href
                        ? "text-[var(--color-primary)] underline underline-offset-4 font-medium"
                        : "text-gray-700 hover:bg-gray-50"
                    }`}
                  >
                    {link.name}
                  </Link>
                ))}

              {/* Extra manager links (if MANAGER) */}
              {role === "MANAGER" &&
                extraManagerLinks.map((link) => (
                  <Link
                    key={link.name}
                    href={link.href}
                    onClick={() => setOpen(false)}
                    className={`px-3 py-2 rounded-xl text-sm ${
                      pathname.startsWith(link.href)
                        ? "text-primary underline underline-offset-4 font-medium"
                        : "text-gray-700 hover:bg-gray-50"
                    }`}
                  >
                    {link.name}
                  </Link>
                ))}
            </nav>
          </div>
        )}
      </div>
    </div>
  );
}

export default NavBar;
