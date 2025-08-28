"use client";

import { useState } from "react";
import { Upload, Trash2, CheckCircle } from "lucide-react";

interface UploadedFile {
  name: string;
  size: number;
}

export default function LegalDocumentsForm() {
  const [businessLicense, setBusinessLicense] = useState<UploadedFile | null>(null);
  const [foodSafety, setFoodSafety] = useState<UploadedFile | null>(null);
  const [taxId, setTaxId] = useState<UploadedFile | null>(null);
  const [liquorLicense, setLiquorLicense] = useState<UploadedFile | null>(null);

  const handleFileUpload = (
    e: React.ChangeEvent<HTMLInputElement>,
    setter: (file: UploadedFile | null) => void
  ) => {
    if (e.target.files && e.target.files[0]) {
      const file = e.target.files[0];
      setter({
        name: file.name,
        size: +(file.size / (1024 * 1024)).toFixed(1), // in MB
      });
    }
  };

  const renderUploadBox = (
    label: string,
    required: boolean,
    file: UploadedFile | null,
    setter: (file: UploadedFile | null) => void,
    optional?: boolean
  ) => (
    <div className="rounded-lg p-4 bg-white">
      <div className="flex justify-between items-center mb-2">
        <label className="font-medium">
          {label} {required && <span className="text-red-500">*</span>}{" "}
          {optional && <span className="text-gray-400 text-sm">(Optional)</span>}
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
            onClick={() => setter(null)}
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
            accept=".pdf,.jpg,.jpeg,.png"
            onChange={(e) => handleFileUpload(e, setter)}
          />
          <p className="text-xs text-gray-400 mt-1">
            PDF, JPG, PNG up to 10MB
          </p>
        </label>
      )}
    </div>
  );

  return (
    <div className="space-y-6">
      {renderUploadBox("Business License", true, businessLicense, setBusinessLicense)}
      {renderUploadBox("Food Safety Certificate", true, foodSafety, setFoodSafety)}
      {renderUploadBox("Tax ID / EIN Certificate", true, taxId, setTaxId)}
      {renderUploadBox("Liquor License", false, liquorLicense, setLiquorLicense, true)}
    </div>
  );
}
