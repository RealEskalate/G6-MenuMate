"use client";

// import { Fullscreen } from "lucide-react";
import Image from "next/image";
import React, { useState } from "react";

const AddMenuWithOCR = () => {
  const [file, setFile] = useState<File | null>(null);

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

  const handleDragOver = (event: React.DragEvent<HTMLDivElement>) => {
    event.preventDefault();
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

  return (
    <>
      <div className="flex justify-between items-center mb-3 bg-white p-4 rounded-2xl shadow-[0_4px_12px_#ffead4] font-bold text-2xl">
        Add Menu with OCR
      </div>
      <div className="p-5 shadow-[0_4px_12px_#ffead4] rounded-lg mx-auto text-center bg-white">
        <div className="relative flex justify-between mb-8">
          <div className="absolute top-4 left-0 w-full h-px bg-gray-200 z-0"></div>
          <div className="relative z-10 w-36 text-center">
            <div className="mx-auto flex items-center justify-center w-8 h-8 rounded-full bg-orange-500 text-white font-bold text-base mb-1">
              1
            </div>
            <div className="text-sm font-semibold text-orange-500 mb-1">
              Upload Menu Photo
            </div>
            <p className="text-xs text-gray-500">
              Take a photo of any menu or upload an existing one
            </p>
          </div>
          <div className="relative z-10 w-36 text-center">
            <div className="mx-auto flex items-center justify-center w-8 h-8 rounded-full bg-gray-200 text-gray-600 font-bold text-base mb-1">
              2
            </div>
            <div className="text-sm font-bold text-gray-800 mb-1">
              OCR Processing
            </div>
            <p className="text-xs text-gray-500">
              Our AI extracts text and menu items
            </p>
          </div>
          <div className="relative z-10 w-36 text-center">
            <div className="mx-auto flex items-center justify-center w-8 h-8 rounded-full bg-gray-200 text-gray-600 font-bold text-base mb-1">
              3
            </div>
            <div className="text-sm font-bold text-gray-800 mb-1">
              Review & Edit
            </div>
            <p className="text-xs text-gray-500">
              Verify the extracted content and make adjustments
            </p>
          </div>
          <div className="relative z-10 w-36 text-center">
            <div className="mx-auto flex items-center justify-center w-8 h-8 rounded-full bg-gray-200 text-gray-600 font-bold text-base mb-1">
              4
            </div>
            <div className="text-sm font-bold text-gray-800 mb-1">
              Save & Share
            </div>
            <p className="text-xs text-gray-500">
              Get your digital menu with translation options
            </p>
          </div>
        </div>
        <div
          className="border-2 border-dashed border-gray-300 p-10 mb-5 cursor-pointer hover:border-orange-300 transition-colors bg-gray-50 rounded-lg"
          onDrop={handleDrop}
          onDragOver={handleDragOver}
          onClick={() => {
            const input = document.getElementById("fileInput");
            if (input) input.click();
          }}
        >
          {file ? (
            <Image
              src={URL.createObjectURL(file)}
              alt="Uploaded menu"
              width={400} // or any size you prefer
              height={300}
              className="object-contain mx-auto rounded max-h-72"
            />
          ) : (
            <>
              <p className="mb-2 text-xl text-gray-700 font-semibold">
                Drag & Drop Menu Photo
              </p>
              <p className="mb-4 text-gray-600">or</p>
              <button
                className="bg-orange-500 text-white px-6 py-2 rounded-lg hover:bg-orange-600 transition-colors"
                onClick={() => {
                  const input = document.getElementById("fileInput");
                  if (input) input.click();
                }}
              >
                Choose File
              </button>
              <input
                id="fileInput"
                type="file"
                accept="image/jpeg,image/png,image/heic"
                className="hidden"
                onChange={handleFileSelect}
              />
              <p className="text-xs text-gray-400 mt-4">
                Supported formats: JPG, PNG, HEIC
              </p>
            </>
          )}
        </div>
        <div className="flex justify-between">
          <button className="px-5 py-2 bg-gray-100 text-gray-600 rounded-lg hover:bg-gray-200 transition-colors">
            ← Back
          </button>
          <button className="px-5 py-2 bg-orange-400 text-white rounded-lg hover:bg-orange-500 transition-colors">
            Next →
          </button>
        </div>
      </div>
    </>
  );
};

export default AddMenuWithOCR;
