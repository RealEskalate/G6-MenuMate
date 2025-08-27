"use client";

import React, { useState } from "react";
const AddMenuWithOCR = () => {
  const [file, setFile] = useState<File | null>(null);

  const handleDrop = (event: React.DragEvent<HTMLDivElement>) => {
    event.preventDefault();
    const droppedFile = event.dataTransfer.files[0];
    if (droppedFile && ['image/jpeg', 'image/png', 'image/heic'].includes(droppedFile.type)) {
      setFile(droppedFile);
    }
  };

  const handleDragOver = (event: React.DragEvent<HTMLDivElement>) => {
    event.preventDefault();
  };

  const handleFileSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFile = event.target.files && event.target.files[0];
    if (selectedFile && ['image/jpeg', 'image/png', 'image/heic'].includes(selectedFile.type)) {
      setFile(selectedFile);
    }
  };

  return (
    <div className="p-5 border-2 border-orange-300 rounded-lg max-w-xl mx-auto text-center">
      <h2 className="text-2xl mb-5">Add menu with OCR</h2>
      <div className="flex justify-between mb-5">
        <div className="w-24 text-center text-gray-600">
          <div className="text-orange-500 font-bold">1<br />Upload Menu Photo</div>
        </div>
        <div className="w-24 text-center text-gray-600">
          <div>2<br />OCR Processing</div>
        </div>
        <div className="w-24 text-center text-gray-600">
          <div>3<br />Review & Edit</div>
        </div>
        <div className="w-24 text-center text-gray-600">
          <div>4<br />Save & Share</div>
        </div>
      </div>
      <div
        className="border-2 border-dashed border-gray-300 p-10 mb-5 cursor-pointer"
        onDrop={handleDrop}
        onDragOver={handleDragOver}
        onClick={() => {
          const input = document.getElementById('fileInput');
          if (input) input.click();
        }}
      >
        {file ? (
          <img src={URL.createObjectURL(file)} alt="Uploaded menu" className="max-w-full max-h-72 mx-auto" />
        ) : (
          <>
            <p className="mb-2 text-gray-600">Drag & Drop Menu Photo</p>
            <p className="mb-2 text-gray-600">or</p>
            <button
              className="bg-orange-500 text-white px-5 py-2 rounded-lg hover:bg-orange-600"
              onClick={() => document.getElementById('fileInput').click()}
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
            <p className="text-xs text-gray-400 mt-2">Supported formats: JPG, PNG, HEIC</p>
          </>
        )}
      </div>
      <div className="flex justify-between">
        <button className="px-5 py-2 bg-gray-200 text-gray-600 rounded-lg">← Back</button>
        <button className="px-5 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600">Next →</button>
      </div>
    </div>
  );
};

export default AddMenuWithOCR;