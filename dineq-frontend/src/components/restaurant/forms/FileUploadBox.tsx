"use client";

import { Upload, Trash2, CheckCircle } from "lucide-react";

export interface UploadedFile {
  name: string;
  size: number;
  file?: File;
}

type FileUploadBoxProps = {
  label: string;
  required?: boolean;
  file: UploadedFile | null;
  onFileChange: (file: UploadedFile | null) => void;
  accept?: string;
  compact?: boolean;
};

export default function FileUploadBox({
  label,
  required = false,
  file,
  onFileChange,
  accept = ".pdf,.jpg,.jpeg,.png",
  compact = false,
}: FileUploadBoxProps) {
  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const f = e.target.files[0];
      onFileChange({
        name: f.name,
        size: +(f.size / (1024 * 1024)).toFixed(1),
        file: f,
      });
    }
  };

  return (
    <div className="bg-white">
      {/* Label */}
      <div className="flex justify-between items-center mb-2">
        <label className={`text-base font-normal ${compact ? "text-sm" : "text-base"}`}>
          {label} {required && <span className="text-red-500">*</span>}
        </label>
        {file && (
          <CheckCircle className={`${compact ? "w-4 h-4" : "w-5 h-5"} text-green-500`} />
        )}
      </div>

      {/* Uploaded file preview */}
      {file ? (
        <div
          className={`flex items-center justify-between bg-green-50 border border-green-200 px-3 rounded ${
            compact ? "py-2" : "py-3"
          }`}
        >
          <span className={`text-gray-800 ${compact ? "text-xs" : "text-base"} font-normal`}>
            {file.name} ({file.size} MB)
          </span>
          <button
            type="button"
            onClick={() => onFileChange(null)}
            className="text-red-500 hover:text-red-700"
          >
            <Trash2 className={`${compact ? "w-3 h-3" : "w-4 h-4"}`} />
          </button>
        </div>
      ) : (
        // File drop area
        <label
          className={`flex flex-col items-center justify-center border-2 border-dashed border-gray-300 rounded-lg cursor-pointer hover:bg-gray-50 text-center text-gray-500 ${
            compact ? "py-2 h-20 text-xs" : "py-4 h-24 text-base font-normal"
          }`}
        >
          <Upload className={`mb-2 text-gray-400 ${compact ? "w-4 h-4" : "w-6 h-6"}`} />
          <span className={`${compact ? "text-xs" : "text-base font-normal"}`}>
            Drag and drop your file here, or{" "}
            <span className="text-blue-600 underline">click to browse</span>
          </span>
          <input
            type="file"
            className="hidden"
            accept={accept}
            onChange={handleFileUpload}
          />
          <p className={`text-gray-400 mt-2 ${compact ? "text-xs" : "text-sm font-normal"}`}>
            PDF, JPG, PNG up to 10MB
          </p>
        </label>

      )}
    </div>
  );
}
