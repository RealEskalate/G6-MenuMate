"use client";

import React, { useEffect, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Menu, X } from "lucide-react";

import Roles from "../../Types/role";

function NavBar({ role }: Roles) {
  const pathname = usePathname();
  const [open, setOpen] = useState(false);

  useEffect(() => {
    setOpen(false); 
  }, [pathname]);

  const linkClasses = (path: string) =>
    pathname === path
      ? "px-4 py-2 text-[var(--color-primary)] underline underline-offset-4 font-medium"
      : "px-4 py-2 text-gray-700 hover:text-[var(--color-primary)]";

  const customerLinks = [
    { name: "Home", href: "/" },
    { name: "Restaurants", href: "/user/restaurants" },
    { name: "Scan", href: "/user/scan" },
    { name: "Favorites", href: "/user/favorites" },
    { name: "Profile", href: "/user/profile" },
  ];

  const restaurantLinks = [
    { name: "About", href: "/about" },
    { name: "Contact", href: "/contact" },
  ];

  const links = role === "USER" ? customerLinks : restaurantLinks;

  return (
    <nav className="w-full bg-white/95 backdrop-blur-md border-b border-gray-100 z-50">
      <div className="max-w-7xl mx-auto px-6 py-3 flex items-center justify-between">
        {/* Logo */}
        <Link href="/">
          <Image src="/logo.png" alt="Logo" width={100} height={100} />
        </Link>

        {/* Desktop Menu */}
        <div className="hidden md:flex space-x-4">
          {links.map((link) => (
            <Link key={link.name} href={link.href} className={linkClasses(link.href)}>
              {link.name}
            </Link>
          ))}
        </div>

        {/* Mobile Menu Button */}
        <div className="md:hidden">
          <button onClick={() => setOpen(!open)}>
            {open ? <X size={24} /> : <Menu size={24} />}
          </button>
        </div>
      </div>

      {/* Mobile Menu Dropdown */}
      {open && (
        <div className="md:hidden bg-white border-t border-gray-200 shadow-lg">
          {links.map((link) => (
            <Link
              key={link.name}
              href={link.href}
              className={linkClasses(link.href) + " block px-6 py-3"}
            >
              {link.name}
            </Link>
          ))}
        </div>
      )}
    </nav>
  );
}

export default NavBar;
