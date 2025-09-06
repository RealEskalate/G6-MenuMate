"use client";

import {
  createContext,
  useContext,
  useState,
  ReactNode,
  useCallback,
} from "react";

// --- Types from OCR response (keep these) ---
interface NutritionalInfo {
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
}

interface MenuItem {
  name: string;
  name_am?: string;
  image: File | null | string;
  price: number | string;
  currency?: string;
  ingredients: string[];
  description: string;
  description_am?: string;
  tab_tags?: string[];
  tab_tags_am?: string[];
  allergies?: string;
  allergies_am?: string;
  nutritional_info?: NutritionalInfo;
  preparation_time?: number;
  instructions: string;
  instructions_am?: string;
  voice?: string | null;
}

interface MenuContextType {
  menuItems: MenuItem[];
  setMenuItems: (items: MenuItem[]) => void;
  clearMenuItems: () => void;
}

const MenuContext = createContext<MenuContextType | undefined>(undefined);

export const MenuProvider = ({ children }: { children: ReactNode }) => {
  const [menuItems, setMenuItemsState] = useState<MenuItem[]>([]);

  const setMenuItems = useCallback((items: MenuItem[]) => {
    setMenuItemsState(items);
  }, []);

  const clearMenuItems = useCallback(() => {
    setMenuItemsState([]);
  }, []);

  return (
    <MenuContext.Provider value={{ menuItems, setMenuItems, clearMenuItems }}>
      {children}
    </MenuContext.Provider>
  );
};

export const useMenuContext = () => {
  const context = useContext(MenuContext);
  if (context === undefined) {
    throw new Error("useMenuContext must be used within a MenuProvider");
  }
  return context;
};