"use client";

export default function FileUpload() {
  return (
    <div className="border-dashed border-2 rounded-lg p-6 text-center text-sm text-gray-500">
      <p>
        Drag and drop your file here, or{" "}
        <span className="text-blue-500 cursor-pointer">click to browse</span>
      </p>
      <p className="mt-1 text-xs">mp3 up to 10MB</p>
    </div>
  );
}
