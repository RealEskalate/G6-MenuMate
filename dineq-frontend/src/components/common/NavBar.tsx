"use client";
import React from "react";
import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import logo from "../../../public/logo.png";
import Roles from "../../Types/role";

function NavBar({ role }: Roles) {
  const pathname = usePathname();

  // Function to determine link classes
  const linkClasses = (path: string) =>
    pathname === path
      ? "px-4 text-[var(--color-primary)] underline underline-offset-4 font-medium"
      : "px-4 text-gray-700 hover:text-[var(--color-primary)]";

  return (
    <div className="border-b shadow-sm border-gray-300 px-6 py-2 flex justify-between w-full items-center">
      <Image src={logo} alt="logo" width={100} height={100} />
      {role === "CUSTOMER" ? (         

          <div className="flex ml-4">
            <Link href="/" className={linkClasses("/")}>
              Home
            </Link>
            <Link
              href="/customer/restaurants"
              className={linkClasses("/customer/restaurants")}
            >
              Restaurants
            </Link>
            <Link
              href="/customer/scan"
              className={linkClasses("/customer/scan")}
            >
              Scan
            </Link>
            <Link
              href="/customer/favorites"
              className={linkClasses("/customer/favorites")}
            >
              Favorites
            </Link>
            <Link
              href="/customer/profile"
              className={linkClasses("/customer/profile")}
            >
              Profile
            </Link>
          </div>
      ) : (
        <div className="flex ml-4">
          <Link
            href="/restaurant/dashboard"
            className={linkClasses("/restaurant/dashboard")}
          >
            Home
          </Link>
          <Link
            href="/restaurant/about"
            className={linkClasses("/restaurant/about")}
          >
            About
          </Link>
          <Link
            href="/restaurant/contact"
            className={linkClasses("/restaurant/contact")}
          >
            Contact
          </Link>
        </div>
      )}
    </div>
  );
}

export default NavBar;
