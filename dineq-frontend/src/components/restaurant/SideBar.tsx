"use client";

import React from "react";
import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";

function SideBar() {
  const pathname = usePathname();

  const links = [
    { name: "Menus", href: "/restaurant/dashboard", icon: "/icons/menu.svg" },
    { name: "QR Manager", href: "/dashboard/qr-manager", icon: "/icons/qr.png" },
    { name: "Settings", href: "/restaurant/dashboard/settings", icon: "/icons/setting.png" },
    { name: "Analytics", href: "/dashboard/analytics", icon: "/icons/Analytics.png", pro: true },
  ];

  return (
    <aside className="hidden md:block w-64 h-[82.5vh] bg-white border border-gray-200 p-4 flex flex-col gap-6 rounded-2xl shadow-[0_4px_12px_#ffd2a9] ml-6 mt-8">
      <div className="space-y-6 pt-6 pb-32 pl-4 pr-5">
        {links.map((link) => {
          const active = pathname.startsWith(link.href);

          return (
            <Link
              key={link.name}
              href={link.href}
              className={`flex items-center gap-3 font-medium transition-colors ${
                active ? "text-orange-600" : "text-gray-600 hover:text-orange-600"
              }`}
            >
              <Image src={link.icon} alt={link.name} width={18} height={18} />
              <span className="flex items-center gap-1">
                {link.name}
                {link.pro && (
                  <sup className="text-[8px] text-orange-500 px-1 font-bold">
                    PRO
                  </sup>
                )}
              </span>
            </Link>
          );
        })}
      </div>
    </aside>
  );
}

export default SideBar;
