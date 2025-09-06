"use client";

import Image from "next/image";
import React, { useState } from "react";
import { useSession } from "next-auth/react";
import { uploadMenuOCR, getOCRStatus } from "@/lib/api"; // import the API function
import { useRouter } from "next/navigation";
import { useDispatch, useSelector } from "react-redux";
import { setMenuItems } from "@/store/menuSlice";
import { RootState } from "@/store";

const AddMenuWithOCR = () => {
  const { data: session } = useSession();
  const router = useRouter();
  const dispatch = useDispatch();
  const [file, setFile] = useState<File | null>(null);
  const [loading, setLoading] = useState(false);
  const [progress, setProgress] = useState<number | null>(null);
  const [menuData, setMenuData] = useState<any | null>(null);
  const [editedItems, setEditedItems] = useState<any[]>([]);
  const [currentStep, setCurrentStep] = useState(1);
  const ocrMenuItems = useSelector(
    (state: RootState) => state.menu?.menuItems ?? []
  );

  const handleUpload = async () => {
    if (!file || !session?.accessToken) return;

    setLoading(true);
    setProgress(null);
    setMenuData(null);

    try {
      // Step 1: Upload file
      const result = await uploadMenuOCR(file, session.accessToken);
      // console.log("✅ OCR Upload Response:", result);

      const jobId = result.data.job_id;
      setCurrentStep(2);

      // Step 2: Poll OCR status
      const interval = setInterval(async () => {
        try {
          const statusRes = await getOCRStatus(jobId, session.accessToken);
          console.log("📡 OCR Status:", statusRes);

          setProgress(statusRes.data.progress);

          if (statusRes.data.status === "completed") {
            clearInterval(interval);
            const ocrResults = statusRes.data.results;
            // console.log(ocrResults);
            setMenuData(ocrResults);
            setEditedItems(ocrResults?.menu_items || []);
            setCurrentStep(3);
            console.log("✅ OCR job completed:", ocrResults);
            setLoading(false);
          }

          if (statusRes.data.status === "failed") {
            clearInterval(interval);
            setLoading(false);
            console.error("❌ OCR job failed");
          }
        } catch (err) {
          clearInterval(interval);
          setLoading(false);
          console.error("❌ Error polling OCR:", err);
        }
      }, 3000); // poll every 3 seconds
    } catch (err) {
      console.error("❌ Error uploading menu:", err);
      setLoading(false);
    }
  };

  const handleItemChange = (index: number, field: string, value: any) => {
    const newItems = [...editedItems];
    newItems[index][field] = value;
    setEditedItems(newItems);
  };

  const handleNutritionalChange = (
    index: number,
    subField: string,
    value: number
  ) => {
    const newItems = [...editedItems];
    if (!newItems[index].nutritional_info) {
      newItems[index].nutritional_info = {};
    }
    newItems[index].nutritional_info[subField] = value;
    setEditedItems(newItems);
  };

  const handleSave = () => {
    dispatch(setMenuItems(editedItems));
    router.push("/restaurant/dashboard/menu/manual_menu");
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

  return (
    <>
      <div className="flex justify-between items-center mb-3 bg-white p-4 rounded-2xl shadow-[0_4px_12px_#ffead4] font-bold text-2xl">
        Add Menu with OCR
      </div>
      <div className="p-5 shadow-[0_4px_12px_#ffead4] rounded-lg mx-auto text-center bg-white">
        <div className="relative flex justify-between mb-8">
          <div className="absolute top-4 left-0 w-full h-px bg-gray-200 z-0"></div>
          <div className="relative z-10 w-36 text-center">
            <div
              className={`mx-auto flex items-center justify-center w-8 h-8 rounded-full ${
                currentStep >= 1
                  ? "bg-orange-500 text-white"
                  : "bg-gray-200 text-gray-600"
              } font-bold text-base mb-1`}
            >
              1
            </div>
            <div
              className={`text-sm ${
                currentStep >= 1
                  ? "font-semibold text-orange-500"
                  : "font-bold text-gray-800"
              } mb-1`}
            >
              Upload Menu Photo
            </div>
            <p className="text-xs text-gray-500">
              Take a photo of any menu or upload an existing one
            </p>
          </div>
          <div className="relative z-10 w-36 text-center">
            <div
              className={`mx-auto flex items-center justify-center w-8 h-8 rounded-full ${
                currentStep >= 2
                  ? "bg-orange-500 text-white"
                  : "bg-gray-200 text-gray-600"
              } font-bold text-base mb-1`}
            >
              2
            </div>
            <div
              className={`text-sm ${
                currentStep >= 2
                  ? "font-semibold text-orange-500"
                  : "font-bold text-gray-800"
              } mb-1`}
            >
              OCR Processing
            </div>
            <p className="text-xs text-gray-500">
              Our AI extracts text and menu items
            </p>
          </div>
          <div className="relative z-10 w-36 text-center">
            <div
              className={`mx-auto flex items-center justify-center w-8 h-8 rounded-full ${
                currentStep >= 3
                  ? "bg-orange-500 text-white"
                  : "bg-gray-200 text-gray-600"
              } font-bold text-base mb-1`}
            >
              3
            </div>
            <div
              className={`text-sm ${
                currentStep >= 3
                  ? "font-semibold text-orange-500"
                  : "font-bold text-gray-800"
              } mb-1`}
            >
              Review & Edit
            </div>
            <p className="text-xs text-gray-500">
              Verify the extracted content and make adjustments
            </p>
          </div>
          <div className="relative z-10 w-36 text-center">
            <div
              className={`mx-auto flex items-center justify-center w-8 h-8 rounded-full ${
                currentStep >= 4
                  ? "bg-orange-500 text-white"
                  : "bg-gray-200 text-gray-600"
              } font-bold text-base mb-1`}
            >
              4
            </div>
            <div
              className={`text-sm ${
                currentStep >= 4
                  ? "font-semibold text-orange-500"
                  : "font-bold text-gray-800"
              } mb-1`}
            >
              Save & Share
            </div>
            <p className="text-xs text-gray-500">
              Get your digital menu with translation options
            </p>
          </div>
        </div>
        {currentStep < 3 && (
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
                height={0} // or remove height entirely
                style={{ height: "auto" }}
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
        )}
        <div className="flex justify-between">
          <button className="px-5 py-2 bg-gray-100 text-gray-600 rounded-lg hover:bg-gray-200 transition-colors">
            ← Back
          </button>
          {currentStep < 3 ? (
            <button
              className="px-5 py-2 bg-orange-400 text-white rounded-lg hover:bg-orange-500 transition-colors"
              onClick={handleUpload}
              disabled={loading}
            >
              {loading ? "Uploading..." : "Next →"}
            </button>
          ) : (
            <button
              className="px-5 py-2 bg-orange-400 text-white rounded-lg hover:bg-orange-500 transition-colors"
              onClick={handleSave}
            >
              Save →
            </button>
          )}
        </div>
        {loading && (
          <div className="mt-4 text-center">
            <p className="font-semibold">Processing OCR...</p>
            {progress !== null && <p>Progress: {progress}%</p>}
          </div>
        )}

        {menuData && (
          <div className="mt-6 p-4 bg-gray-50 rounded-lg text-left">
            <h3 className="font-bold text-lg mb-2">Extracted Menu</h3>
            <ul className="space-y-2">
              {editedItems.map((item: any, idx: number) => (
                <li
                  key={idx}
                  className="p-2 border rounded-lg bg-white shadow-sm"
                >
                  <input
                    className="font-semibold w-full mb-1"
                    value={item.name}
                    onChange={(e) =>
                      handleItemChange(idx, "name", e.target.value)
                    }
                  />
                  <input
                    className="font-semibold w-full mb-1 text-gray-500"
                    value={item.name_am}
                    onChange={(e) =>
                      handleItemChange(idx, "name_am", e.target.value)
                    }
                  />
                  <textarea
                    className="text-sm text-gray-600 w-full mb-1"
                    value={item.description}
                    onChange={(e) =>
                      handleItemChange(idx, "description", e.target.value)
                    }
                  />
                  <textarea
                    className="text-sm text-gray-600 w-full mb-1"
                    value={item.description_am}
                    onChange={(e) =>
                      handleItemChange(idx, "description_am", e.target.value)
                    }
                  />
                  <input
                    type="number"
                    className="text-orange-500 font-bold w-full mb-1"
                    value={item.price}
                    onChange={(e) =>
                      handleItemChange(idx, "price", parseFloat(e.target.value))
                    }
                  />
                  <input
                    className="text-orange-500 font-bold w-full mb-1"
                    value={item.currency}
                    onChange={(e) =>
                      handleItemChange(idx, "currency", e.target.value)
                    }
                  />
                  <textarea
                    className="text-sm text-gray-600 w-full mb-1"
                    value={item.allergies}
                    onChange={(e) =>
                      handleItemChange(idx, "allergies", e.target.value)
                    }
                  />
                  <textarea
                    className="text-sm text-gray-600 w-full mb-1"
                    value={item.allergies_am}
                    onChange={(e) =>
                      handleItemChange(idx, "allergies_am", e.target.value)
                    }
                  />
                  <input
                    type="number"
                    className="w-full mb-1"
                    value={item.preparation_time}
                    onChange={(e) =>
                      handleItemChange(
                        idx,
                        "preparation_time",
                        parseInt(e.target.value)
                      )
                    }
                  />
                  <textarea
                    className="text-sm text-gray-600 w-full mb-1"
                    value={item.how_to_eat}
                    onChange={(e) =>
                      handleItemChange(idx, "how_to_eat", e.target.value)
                    }
                  />
                  <textarea
                    className="text-sm text-gray-600 w-full mb-1"
                    value={item.how_to_eat_am}
                    onChange={(e) =>
                      handleItemChange(idx, "how_to_eat_am", e.target.value)
                    }
                  />
                  <div className="grid grid-cols-4 gap-2 mb-2">
                    <input
                      type="number"
                      placeholder="Calories"
                      value={item.nutritional_info?.calories ?? ""}
                      onChange={(e) =>
                        handleNutritionalChange(
                          idx,
                          "calories",
                          parseInt(e.target.value)
                        )
                      }
                      className="border border-gray-300 rounded p-2"
                    />
                    <input
                      type="number"
                      placeholder="Protein"
                      value={item.nutritional_info?.protein ?? ""}
                      onChange={(e) =>
                        handleNutritionalChange(
                          idx,
                          "protein",
                          parseInt(e.target.value)
                        )
                      }
                      className="border border-gray-300 rounded p-2"
                    />
                    <input
                      type="number"
                      placeholder="Carbs"
                      value={item.nutritional_info?.carbs ?? ""}
                      onChange={(e) =>
                        handleNutritionalChange(
                          idx,
                          "carbs",
                          parseInt(e.target.value)
                        )
                      }
                      className="border border-gray-300 rounded p-2"
                    />
                    <input
                      type="number"
                      placeholder="Fat"
                      value={item.nutritional_info?.fat ?? ""}
                      onChange={(e) =>
                        handleNutritionalChange(
                          idx,
                          "fat",
                          parseInt(e.target.value)
                        )
                      }
                      className="border border-gray-300 rounded p-2"
                    />
                  </div>
                </li>
              ))}
            </ul>
          </div>
        )}
      </div>
    </>
  );
};

export default AddMenuWithOCR;
