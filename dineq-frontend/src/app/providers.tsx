"use client"; 

import ReduxProvider from "@/store/ReduxProvider";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { SessionProvider } from "next-auth/react";
import { useState, ReactNode } from "react";
import { FavoritesProvider } from "@/context/FavoritesContext";

export default function Providers({ children }: { children: ReactNode }) {
  const [queryClient] = useState(() => new QueryClient());

  return (
    <SessionProvider>
      <QueryClientProvider client={queryClient}>
      <ReduxProvider>
        <FavoritesProvider>
        {children}
        </FavoritesProvider>
      </ReduxProvider>
    </QueryClientProvider>
    </SessionProvider>
  );
}
