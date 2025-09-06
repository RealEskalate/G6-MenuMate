"use client";

import { usePathname } from "next/navigation";
import Link from "next/link";

const tabs = [
  { name: "Profile", href: "/restaurant/dashboard/settings/profile" },
  { name: "Legal info", href: "/restaurant/dashboard/settings/legal-info" },
  { name: "Branding", href: "/restaurant/dashboard/settings/branding" },
  { name: "Billings", href: "/restaurant/dashboard/settings/billings" },
];

export default function SettingsLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const pathname = usePathname();

  return (
    <div className="flex flex-col gap-6 px-4 sm:px-6">
      {/* Settings Title */}
      <div className="bg-white p-4 rounded-2xl shadow-[0_4px_12px_#ffead4]">
        <h1 className="text-2xl font-bold">Settings</h1>
      </div>

      {/* Tabs (scrollable on mobile) */}
      <div className="flex overflow-x-auto flex-nowrap border border-orange-200 rounded-xl bg-white p-2 sm:justify-around">
        {tabs.map((tab) => {
          const active =
            (tab.href === "/restaurant/dashboard/settings" &&
              pathname === "/restaurant/dashboard/settings/profile") ||
            (tab.href !== "/restaurant/dashboard/settings" &&
              pathname.startsWith(tab.href));

          return (
            <Link
              key={tab.name}
              href={tab.href}
              className={`whitespace-nowrap px-4 py-2 text-sm sm:text-base font-medium transition-all ${
                active
                  ? "text-orange-500 border-b-2 border-orange-500"
                  : "text-gray-600 hover:text-gray-800"
              }`}
            >
              {tab.name}
            </Link>
          );
        })}
      </div>

      {/* Tab Content */}
      <div className="border border-orange-200 rounded-xl p-4 sm:p-6 shadow-sm bg-white">
        {children}
      </div>
    </div>
  );
}
