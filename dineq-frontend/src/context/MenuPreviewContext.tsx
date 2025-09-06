"use client";

import { createContext, useState, ReactNode } from "react";
import { Menu } from "@/Types/menu";

interface MenuPreviewContextValue {
  previewMenu: Menu | null;
  setPreviewMenu: (menu: Menu | null) => void;
}

export const MenuPreviewContext = createContext<MenuPreviewContextValue>({
  previewMenu: null,
  setPreviewMenu: () => {},
});

export function MenuPreviewProvider({ children }: { children: ReactNode }) {
  const [previewMenu, setPreviewMenu] = useState<Menu | null>(null);

  return (
    <MenuPreviewContext.Provider value={{ previewMenu, setPreviewMenu }}>
      {children}
    </MenuPreviewContext.Provider>
  );
}
