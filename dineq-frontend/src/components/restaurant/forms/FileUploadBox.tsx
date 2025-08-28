"use client";

import { useState } from "react";
import { Upload, Trash2, CheckCircle } from "lucide-react";

export interface UploadedFile {
  name: string;
  size: number; // in MB
}

type FileUploadBoxProps = {
  label: string;
  required?: boolean;
  file: UploadedFile | null;
  onFileChange: (file: UploadedFile | null) => void;
  accept?: string;
};

export default function FileUploadBox({
  label,
  required = false,
  file,
  onFileChange,
  accept = ".pdf,.jpg,.jpeg,.png",
}: FileUploadBoxProps) {
  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const f = e.target.files[0];
      onFileChange({
        name: f.name,
        size: +(f.size / (1024 * 1024)).toFixed(1),
      });
    }
  };

  return (
    <div className="rounded-lg p-4 bg-white max-w-md">
      <div className="flex justify-between items-center mb-2">
        <label className="font-medium">
          {label} {required && <span className="text-red-500">*</span>}
        </label>
        {file && <CheckCircle className="w-5 h-5 text-green-500" />}
      </div>

      {file ? (
        <div className="flex items-center justify-between bg-green-50 border border-green-200 px-3 py-2 rounded">
          <span className="text-sm text-gray-800">
            {file.name} ({file.size} MB)
          </span>
          <button
            type="button"
            onClick={() => onFileChange(null)}
            className="text-red-500 hover:text-red-700"
          >
            <Trash2 className="w-4 h-4" />
          </button>
        </div>
      ) : (
        <label className="flex flex-col items-center justify-center h-28 border-2 border-dashed border-gray-300 rounded-lg cursor-pointer hover:bg-gray-50 text-center text-sm text-gray-500">
          <Upload className="w-6 h-6 mb-1 text-gray-400" />
          Drag and drop your file here, or{" "}
          <span className="text-blue-600 underline">click to browse</span>
          <input
            type="file"
            className="hidden"
            accept={accept}
            onChange={handleFileUpload}
          />
          <p className="text-xs text-gray-400 mt-1">PDF, JPG, PNG up to 10MB</p>
        </label>
      )}
    </div>
  );
}
