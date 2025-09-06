// src/components/MenuUploader.tsx
"use client";

import Image from "next/image";
import React, { useState, useEffect } from "react";
import { useSession } from "next-auth/react";
import { useRouter } from "next/navigation";
import { useMenuContext } from "@/context/MenuOcrContext";
import { uploadMenuOCR, getOCRStatus } from "@/lib/api";
import { Upload, CheckCircle, Loader2, ImageIcon, Edit, X } from "lucide-react";

interface MenuItem {
  name: string;
  name_am: string;
  description: string;
  description_am: string;
  price: number;
  currency: string;
}

const MenuUploader = () => {
  const { data: session } = useSession();
  const router = useRouter();
  const { setMenuItems } = useMenuContext();

  const [file, setFile] = useState<File | null>(null);
  const [loading, setLoading] = useState<boolean>(false);
  const [progress, setProgress] = useState<number | null>(null);
  const [editedItems, setEditedItems] = useState<MenuItem[]>([]);
  const [currentStep, setCurrentStep] = useState<number>(1);

  const handleUpload = async () => {
    if (!file || !session?.accessToken) return;

    setLoading(true);
    setProgress(null);
    setEditedItems([]);

    try {
      const result = await uploadMenuOCR(file, session.accessToken);
      const jobId = result.data.job_id;
      setCurrentStep(2);

      const interval = setInterval(async () => {
        try {
          const statusRes = await getOCRStatus(jobId, session.accessToken);
          setProgress(statusRes.data.progress);

          if (statusRes.data.status === "completed") {
            clearInterval(interval);
            const ocrResults = statusRes.data.results;
            setEditedItems(ocrResults?.menu_items || []);
            setCurrentStep(3);
            setLoading(false);
          }

          if (statusRes.data.status === "failed") {
            clearInterval(interval);
            setLoading(false);
            console.error("❌ OCR job failed");
            // Add user-facing error message here
          }
        } catch (err) {
          clearInterval(interval);
          setLoading(false);
          console.error("❌ Error polling OCR:", err);
        }
      }, 3000);
    } catch (err) {
      console.error("❌ Error uploading menu:", err);
      setLoading(false);
    }
  };

  const handleItemChange = (index: number, field: keyof MenuItem, value: any) => {
    const newItems = [...editedItems];
    if (newItems[index]) {
      newItems[index] = {
        ...newItems[index],
        [field]: value,
      };
    }
    setEditedItems(newItems);
  };

  const handleSave = () => {
    setMenuItems(editedItems);
    router.push("/restaurant/dashboard/menu/manual_menu");
  };
  
  const handleRemoveFile = (event: React.MouseEvent<HTMLButtonElement>) => {
    event.stopPropagation();
    setFile(null);
  };

  const handleDragOver = (event: React.DragEvent<HTMLDivElement>) => {
    event.preventDefault();
  };

  const handleDrop = (event: React.DragEvent<HTMLDivElement>) => {
    event.preventDefault();
    const droppedFile = event.dataTransfer.files[0];
    if (
      droppedFile &&
      ["image/jpeg", "image/png", "image/heic"].includes(droppedFile.type)
    ) {
      setFile(droppedFile);
    }
  };

  const handleFileSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFile = event.target.files && event.target.files[0];
    if (
      selectedFile &&
      ["image/jpeg", "image/png", "image/heic"].includes(selectedFile.type)
    ) {
      setFile(selectedFile);
    }
  };

  const renderStepContent = () => {
    if (currentStep === 1) {
      return (
        <>
          <div className="flex flex-col items-center">
            <p className="text-center text-gray-500 mb-6 font-light">
              Upload a photo of your physical menu to get started.
            </p>
          </div>
          <div
            className="w-full relative border-2 border-dashed border-gray-300 rounded-2xl p-8 flex flex-col items-center justify-center mb-6 cursor-pointer hover:border-orange-400 transition-colors duration-300 bg-gray-50"
            onDrop={handleDrop}
            onDragOver={handleDragOver}
            onClick={() => document.getElementById("fileInput")?.click()}
          >
            {file ? (
              <>
                <Image
                  src={URL.createObjectURL(file)}
                  alt="Uploaded menu"
                  width={400}
                  height={0}
                  style={{ height: "auto" }}
                  className="object-contain mx-auto rounded-xl max-h-72 shadow-md"
                />
                <button
                  className="absolute top-3 right-3 p-1 rounded-full bg-white bg-opacity-70 text-gray-700 hover:text-red-500 transition-colors"
                  onClick={handleRemoveFile}
                >
                  <X size={18} />
                </button>
              </>
            ) : (
              <div className="flex flex-col items-center py-6">
                <ImageIcon className="w-12 h-12 text-gray-400 mb-4" />
                <p className="text-gray-600 font-medium mb-1">Drag & Drop Your Menu Photo</p>
                <span className="text-gray-400 text-sm">or</span>
                <button
                  type="button"
                  className="mt-4 px-6 py-2 bg-gray-900 text-white rounded-full font-medium shadow-lg hover:bg-gray-700 transition"
                  onClick={(e) => {
                    e.stopPropagation();
                    document.getElementById("fileInput")?.click();
                  }}
                >
                  Browse Files
                </button>
                <input
                  id="fileInput"
                  type="file"
                  accept="image/jpeg,image/png,image/heic"
                  className="hidden"
                  onChange={handleFileSelect}
                />
                <p className="text-xs text-gray-400 mt-2">
                  Supported formats: JPG, PNG, HEIC
                </p>
              </div>
            )}
          </div>
          <button
            type="button"
            className={`w-full font-medium py-3 rounded-xl text-white transition ${
              file
                ? "bg-orange-500 hover:bg-orange-600 shadow-md"
                : "bg-gray-200 text-gray-500 cursor-not-allowed"
            }`}
            onClick={handleUpload}
            disabled={!file || loading}
          >
            {loading ? (
              <span className="flex items-center justify-center">
                <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                Uploading...
              </span>
            ) : (
              "Next →"
            )}
          </button>
        </>
      );
    }

    if (currentStep === 2) {
      return (
        <div className="flex flex-col items-center justify-center h-[300px] text-center">
          <Loader2 className="w-12 h-12 text-orange-500 animate-spin mb-4" />
          <h2 className="font-semibold text-xl text-gray-700">
            Processing Menu...
          </h2>
          {progress !== null && (
            <div className="w-full bg-gray-200 rounded-full h-2.5 mt-4">
              <div
                className="bg-orange-500 h-2.5 rounded-full transition-all duration-500 ease-in-out"
                style={{ width: `${progress}%` }}
              ></div>
            </div>
          )}
          <p className="text-sm text-gray-500 mt-4 font-light">
            Our AI is carefully extracting all the details. This may take a moment.
          </p>
        </div>
      );
    }

    if (currentStep === 3) {
      return (
        <>
          <div className="flex flex-col items-center text-center">
            <h2 className="text-2xl font-bold text-gray-800 mb-2">Review & Refine</h2>
            <p className="text-gray-500 mb-6 font-light">
              Make any necessary edits before saving your menu.
            </p>
          </div>
          <div className="mt-4 p-4 bg-gray-50 rounded-xl text-left w-full shadow-inner">
            <h3 className="font-bold text-lg mb-2 text-gray-700">Extracted Items</h3>
            <ul className="space-y-4 max-h-[400px] overflow-y-auto pr-2 custom-scrollbar">
              {editedItems.map((item: MenuItem, idx: number) => (
                <li
                  key={idx}
                  className="p-4 border border-gray-200 rounded-lg bg-white shadow-sm transition-all hover:border-orange-300"
                >
                  <input
                    className="font-semibold w-full mb-1 text-lg outline-none focus:ring-1 focus:ring-orange-500 rounded-md p-1"
                    value={item.name}
                    onChange={(e) => handleItemChange(idx, "name", e.target.value)}
                    placeholder="Item Name"
                  />
                  <input
                    className="font-semibold w-full mb-1 text-gray-500 text-sm outline-none focus:ring-1 focus:ring-orange-500 rounded-md p-1"
                    value={item.name_am}
                    onChange={(e) => handleItemChange(idx, "name_am", e.target.value)}
                    placeholder="Amharic Name"
                  />
                  <textarea
                    className="text-sm text-gray-600 w-full mb-1 resize-none outline-none focus:ring-1 focus:ring-orange-500 rounded-md p-1"
                    rows={2}
                    value={item.description}
                    onChange={(e) => handleItemChange(idx, "description", e.target.value)}
                    placeholder="Description"
                  />
                  <textarea
                    className="text-sm text-gray-600 w-full mb-1 resize-none outline-none focus:ring-1 focus:ring-orange-500 rounded-md p-1"
                    rows={2}
                    value={item.description_am}
                    onChange={(e) => handleItemChange(idx, "description_am", e.target.value)}
                    placeholder="Amharic Description"
                  />
                  <div className="flex justify-between items-center mt-2">
                    <div className="flex items-center">
                      <p className="text-orange-500 font-bold text-lg mr-1">{item.currency}</p>
                      <input
                        type="number"
                        className="text-orange-500 font-bold text-lg w-24 outline-none focus:ring-1 focus:ring-orange-500 rounded-md p-1"
                        value={item.price}
                        onChange={(e) =>
                          handleItemChange(idx, "price", parseFloat(e.target.value))
                        }
                      />
                    </div>
                  </div>
                </li>
              ))}
            </ul>
          </div>
          <button
            type="button"
            className="w-full mt-6 bg-gray-900 text-white font-medium py-3 rounded-xl shadow-lg hover:bg-gray-700 transition"
            onClick={handleSave}
          >
            Save & View Menu
          </button>
        </>
      );
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col items-center py-10 px-4">
      <div className="bg-white shadow-xl rounded-3xl border border-gray-200 w-full max-w-lg p-8 flex flex-col items-center">
        <h1 className="text-3xl font-extrabold text-gray-800 mb-2">
          Digitize Your Menu
        </h1>
        <p className="text-gray-500 mb-8 font-light">
          A seamless way to add your menu online.
        </p>

        {/* Modern Step Indicator */}
        <div className="relative flex justify-between w-full mb-10">
          <div className="absolute top-4 left-0 w-full h-px bg-gray-200 z-0"></div>
          {[1, 2, 3].map((step) => (
            <div key={step} className="relative z-10 w-24 text-center">
              <div
                className={`mx-auto flex items-center justify-center w-10 h-10 rounded-full transition-colors duration-300 ${
                  currentStep >= step
                    ? "bg-orange-500 text-white shadow-md"
                    : "bg-gray-200 text-gray-600"
                } font-bold text-lg mb-2`}
              >
                {step}
              </div>
              <p
                className={`text-xs uppercase tracking-wide transition-colors duration-300 ${
                  currentStep >= step ? "font-semibold text-orange-500" : "text-gray-800"
                }`}
              >
                {step === 1 && "Upload"}
                {step === 2 && "Processing"}
                {step === 3 && "Review"}
              </p>
            </div>
          ))}
        </div>

        {renderStepContent()}
      </div>

      <div className="mt-16 w-full max-w-4xl grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8 text-center">
        {/* Updated Tips Section with icons and subtle styling */}
        <div className="p-4 bg-white rounded-xl shadow-sm border border-gray-100">
          <CheckCircle className="mx-auto text-orange-500 w-7 h-7 mb-2" />
          <h3 className="font-semibold text-gray-800">Good Lighting</h3>
          <p className="text-gray-500 text-sm font-light">
            Ensure the menu is well-lit and clearly visible.
          </p>
        </div>
        <div className="p-4 bg-white rounded-xl shadow-sm border border-gray-100">
          <CheckCircle className="mx-auto text-orange-500 w-7 h-7 mb-2" />
          <h3 className="font-semibold text-gray-800">Flat Surface</h3>
          <p className="text-gray-500 text-sm font-light">
            Place the menu on a flat surface to avoid distortion.
          </p>
        </div>
        <div className="p-4 bg-white rounded-xl shadow-sm border border-gray-100">
          <CheckCircle className="mx-auto text-orange-500 w-7 h-7 mb-2" />
          <h3 className="font-semibold text-gray-800">High Resolution</h3>
          <p className="text-gray-500 text-sm font-light">
            Use the highest resolution possible for accuracy.
          </p>
        </div>
        <div className="p-4 bg-white rounded-xl shadow-sm border border-gray-100">
          <CheckCircle className="mx-auto text-orange-500 w-7 h-7 mb-2" />
          <h3 className="font-semibold text-gray-800">Complete View</h3>
          <p className="text-gray-500 text-sm font-light">
            Capture the entire menu to get all available dishes.
          </p>
        </div>
      </div>
    </div>
  );
};

export default MenuUploader;