"use client";

import { SessionProvider } from "next-auth/react";
import { Provider as ReduxProvider } from "react-redux";
import { store } from "@/store/store";
import { FavoritesProvider } from "@/context/FavoritesContext";
import { MenuProvider } from "@/context/MenuOcrContext";

export default function Providers({ children }: { children: React.ReactNode }) {
  return (
    <ReduxProvider store={store}>
      <SessionProvider>
        <FavoritesProvider>
        
        {children}
        </FavoritesProvider>
        <MenuProvider>
          {children}
          </MenuProvider>
        </SessionProvider>
    </ReduxProvider>
  );
}
