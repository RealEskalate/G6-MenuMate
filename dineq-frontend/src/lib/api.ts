const BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL;

import { RegisterPayload, RegisterResponse } from "@/Types/auth";

export async function registerUser(
  data: RegisterPayload
): Promise<RegisterResponse> {
  console.log("📤 Sending payload:", data, "to", `${BASE_URL}/auth/register`);

  const res = await fetch(`${BASE_URL}/auth/register`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });

  if (!res.ok) {
    throw new Error("Failed to register");
  }

  return res.json();
}

export interface ForgotPasswordPayload {
  email: string;
}

export interface ForgotPasswordResponse {
  message: string;
}

export async function forgotPassword(
  data: ForgotPasswordPayload
): Promise<ForgotPasswordResponse> {
  console.log(
    "📤 Sending payload:",
    data,
    "to",
    `${BASE_URL}/auth/forgot-password`
  );

  const res = await fetch(`${BASE_URL}/auth/forgot-password`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });

  if (!res.ok) {
    throw new Error("❌ Failed to send reset link");
  }

  return res.json();
}

export interface OCRUploadData {
  estimated_completion_time: string;
  job_id: string;
  status: "processing" | "completed" | "failed";
}

export interface OCRUploadResponse {
  data: OCRUploadData;
  success: boolean;
}


export async function uploadMenuOCR(
  file: File,
  accessToken: string
): Promise<OCRUploadResponse> {
  console.log("📤 Uploading file to OCR API:", file);

  const formData = new FormData();
  formData.append("menuImage", file);

  const res = await fetch(`${BASE_URL}/ocr/upload`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
    body: formData,
  });

  if (!res.ok) {
    throw new Error(`❌ Upload failed: ${res.status} ${res.statusText}`);
  }

  return res.json();
}

export interface OCRStatusResponse {
  data: {
    job_id: string;
    status: "processing" | "completed" | "failed";
    progress: number;
    results?: {
      extracted_text: string;
      menu_items: any[];
    };
  };
  success: boolean;
}

export async function getOCRStatus(
  jobId: string,
  accessToken: string
): Promise<OCRStatusResponse> {
  const res = await fetch(`${BASE_URL}/ocr/${jobId}`, {
    method: "GET",
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  });

  if (!res.ok) {
    throw new Error(`❌ Failed to get OCR status: ${res.status}`);
  }

  return res.json();
}


