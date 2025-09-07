
"use client";

import React, { createContext, useContext, useState, ReactNode } from "react";

interface UploadedFile {
  name: string;
  size: number; 
  file: File;   
}

export interface RegisterData {
  name: string;
  email: string;
  restaurant: string;
  address: string;
  phone: string;
  about?: string;
  tags?: string[];
  logo_image?: UploadedFile | null;
  businessLicense?: UploadedFile | null;
  cover_image?: UploadedFile | null;
  lat?: number | null;
  lng: number | null;

}

interface RegisterContextType {
  data: RegisterData;
  updateData: (newData: Partial<RegisterData>) => void;
  resetData: () => void;
}

const RegisterContext = createContext<RegisterContextType | undefined>(undefined);

export const RegisterProvider = ({ children }: { children: ReactNode }) => {
  const [data, setData] = useState<RegisterData>({
    name: "",
    email: "",
    restaurant: "",
    address: "",
    phone: "",
    about: "",
    tags: [],
    logo_image: null,
    businessLicense: null,
    cover_image: null,
    lat: null,
    lng: null,
  });

  const updateData = (newData: Partial<RegisterData>) => {
    setData((prev) => ({ ...prev, ...newData }));
  };

  const resetData = () => {
    setData({
      name: "",
      email: "",
      restaurant: "",
      address: "",
      phone: "",
      about: "",
      tags: [],
      logo_image: null,
      businessLicense: null,
      cover_image: null,
      lat: null,
      lng: null,
    });
  };

  return (
    <RegisterContext.Provider value={{ data, updateData, resetData }}>
      {children}
    </RegisterContext.Provider>
  );
};

export const useRegister = (): RegisterContextType => {
  const context = useContext(RegisterContext);
  if (!context) {
    throw new Error("useRegister must be used within RegisterProvider");
  }
  return context;
};
