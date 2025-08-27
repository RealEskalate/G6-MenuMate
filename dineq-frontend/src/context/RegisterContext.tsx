"use client";

import { createContext, useContext, useEffect, useState } from "react";

interface RegisterData {
  firstName: string;
  lastName: string;
  email: string;
  password: string;
  restaurant: string;
  location: string;
}

interface RegisterContextType {
  data: RegisterData;
  updateData: (fields: Partial<RegisterData>) => void;
  resetData: () => void;
}

const RegisterContext = createContext<RegisterContextType | undefined>(undefined);

export function RegisterProvider({ children }: { children: React.ReactNode }) {
  const [data, setData] = useState<RegisterData>({
    firstName: "",
    lastName: "",
    email: "",
    password: "",
    restaurant: "",
    location: "",
  });

  // Load from localStorage on mount
  useEffect(() => {
    const saved = localStorage.getItem("registerData");
    if (saved) {
      setData(JSON.parse(saved));
    }
  }, []);

  // Save to localStorage whenever data changes
  useEffect(() => {
    localStorage.setItem("registerData", JSON.stringify(data));
  }, [data]);

  const updateData = (fields: Partial<RegisterData>) => {
    setData((prev) => ({ ...prev, ...fields }));
  };

  const resetData = () => {
    setData({ firstName: "",lastName: "", email: "", password: "", restaurant: "", location: "" });
    localStorage.removeItem("registerData");
  };

  return (
    <RegisterContext.Provider value={{ data, updateData, resetData }}>
      {children}
    </RegisterContext.Provider>
  );
}

export function useRegister() {
  const context = useContext(RegisterContext);
  if (!context) throw new Error("useRegister must be used within RegisterProvider");
  return context;
}
