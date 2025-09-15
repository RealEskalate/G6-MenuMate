
"use client";
import React, { useEffect, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { Menu, X } from "lucide-react";
import Roles from "@/Types/role";

function NavBar({ role }: Roles) {
  const pathname = usePathname();
  const router = useRouter();
  const [open, setOpen] = useState(false);

  // Close dropdown on route change
  useEffect(() => {
    setOpen(false);
  }, [pathname]);

  // Logout function
  const handleLogout = async () => {
    try {
      await fetch("process.env.NEXT_PUBLIC_API_BASE_URL/auth/logout", {
        method: "POST",
        credentials: "include", // if backend uses cookies
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${localStorage.getItem("token")}`,
        },
      });

      // Remove token from storage
      localStorage.removeItem("token");

      // Redirect to login page
      router.push("/landing_page/");
    } catch (err) {
      console.error("Logout failed:", err);
    }
  };

  // Highlight active links
  const linkClasses = (path: string) => {
    if (path === "/user") {
      // Home should match only exactly `/user`
      return pathname === "/user"
        ? "px-4 text-[var(--color-primary)] underline underline-offset-10 font-medium"
        : "px-4 text-gray-700 hover:text-[var(--color-primary)]";
    }

    // All other links: highlight if pathname starts with path
    return pathname.startsWith(path)
      ? "px-4 text-[var(--color-primary)] underline underline-offset-10 font-medium"
      : "px-4 text-gray-700 hover:text-[var(--color-primary)]";
  };

  const managerLinks = [
    { name: "Menus", href: "/dashboard/menu", icon: "/icons/menu.svg" },
    {
      name: "QR Manager",
      href: "restaurant/dashboard/qr-manager",
      icon: "/icons/qr.png",
    },
    {
      name: "Settings",
      href: "restaurant/dashboard/settings",
      icon: "/icons/setting.png",
    },
    {
      name: "Analytics",
      href: "restaurant/dashboard/analytics",
      icon: "/icons/Analytics.png",
      pro: true,
    },
  ];

  const extraManagerLinks = [
    { name: "About", href: "/restaurant/about" },
    { name: "Contact Us", href: "/restaurant/contact" },
  ];

  return (
    <div className="relative border-b shadow-sm border-gray-200 px-6 py-2 flex items-center justify-between">
      {/* Logo */}
      <Image src="/logo.png" alt="logo" width={100} height={120} />

      {/* CUSTOMER desktop links */}
      {role === "USER" && (
        <div className="hidden md:flex ml-4">
          <Link href="/user" className={linkClasses("/user")}>
            Home
          </Link>
          <Link href="/user/scan" className={linkClasses("/user/scan")}>
            Scan
          </Link>
          <Link
            href="/user/favorites"
            className={linkClasses("/user/favorites")}
          >
            Favorites
          </Link>
          <Link href="/user/profile" className={linkClasses("/user/profile")}>
            Profile
          </Link>

          {/* Logout */}
          <button
            onClick={handleLogout}
            className="px-4 text-gray-700 hover:text-[var(--color-primary)]"
          >
            Logout
          </button>
        </div>
      )}

      {/* MANAGER desktop links */}
      {role === "MANAGER" && (
        <div className="hidden md:flex ml-auto items-center">
          {extraManagerLinks.map((link) => (
            <Link
              key={link.name}
              href={link.href}
              className={linkClasses(link.href)}
            >
              {link.name}
            </Link>
          ))}
          <button
            onClick={handleLogout}
            className="px-4 text-gray-700 hover:text-[var(--color-primary)]"
          >
            Logout
          </button>
        </div>
      )}

      {/* MOBILE hamburger */}
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
              {/* MANAGER mobile links */}
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
                      <Image
                        src={link.icon}
                        alt={link.name}
                        width={18}
                        height={18}
                      />
                      <span className="flex items-center gap-1 text-sm">
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

              {/* USER mobile links */}
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

              {/* Extra manager links */}
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

              {/* Logout */}
              {role && (
                <button
                  onClick={() => {
                    handleLogout();
                    setOpen(false);
                  }}
                  className="px-3 py-2 rounded-xl text-sm text-gray-700 hover:text-[var(--color-primary)] text-left"
                >
                  Logout
                </button>
              )}
            </nav>
          </div>
        )}
      </div>
    </div>
  );
}

export default NavBar;

