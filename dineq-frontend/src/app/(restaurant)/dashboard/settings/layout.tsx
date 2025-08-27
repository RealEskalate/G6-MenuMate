"use client";

import { usePathname } from "next/navigation";
import Link from "next/link";

const tabs = [
  { name: "Profile", href: "/dashboard/settings" },
  { name: "Legal info", href: "/dashboard/settings/legal-info" },
  { name: "Branding", href: "/dashboard/settings/branding" },
  { name: "Billings", href: "/dashboard/settings/billings" },

];

export default function SettingsLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();

  return (
    <div className="flex flex-col gap-6 px-4">
      {/* Settings Title */}
      <div className="border border-orange-200 rounded-xl p-4 shadow-sm bg-white">
        <h1 className="text-2xl font-semibold">Settings</h1>
      </div>

      {/* Tabs */}
      <div className="flex justify-around border border-orange-200 rounded-xl bg-white p-2">
        {tabs.map((tab) => {
          const active =
            (tab.href === "/dashboard/settings" && pathname === "/dashboard/settings") ||
            (tab.href !== "/dashboard/settings" && pathname.startsWith(tab.href));

          return (
            <Link
              key={tab.name}
              href={tab.href}
              className={`px-4 py-2 text-sm font-medium transition-all ${
                active
                  ? "text-orange-500 border-b-2 border-orange-500"
                  : "text-gray-500 hover:text-gray-700"
              }`}
            >
              {tab.name}
            </Link>
          );
        })}
      </div>

      {/* Tab Content */}
      <div className="border border-orange-200 rounded-xl p-6 shadow-sm bg-white">
        {children}
      </div>
    </div>
  );
}
