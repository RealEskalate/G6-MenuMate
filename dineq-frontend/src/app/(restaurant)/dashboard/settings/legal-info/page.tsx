"use client";

export default function LegalInfoSettings() {
  return (
    <div className="flex flex-col gap-6">
      <div>
        <h2 className="text-lg font-semibold mb-4">Legal Info</h2>
        <label className="block text-sm mb-1">Tax ID</label>
        <input
          type="text"
          defaultValue="ET -12-34-54"
          className="w-full border border-gray-300 rounded-lg px-3 py-2"
        />
      </div>

      <div>
        <label className="block text-sm mb-2">Business License</label>
        <div className="flex items-center justify-between border rounded-lg border-gray-300 p-3">
          <span>business-license.pdf (2.3 MB)</span>
          <div className="flex gap-2">
            <button className="text-blue-500">👁</button>
            <button className="text-red-500">🗑</button>
          </div>
        </div>
      </div>

      <div>
        <label className="block text-sm mb-2">Food safety certificate</label>
        <div className="flex items-center justify-between border border-gray-300 rounded-lg p-3">
          <span>Food-safety-certificate.pdf (2.3 MB)</span>
          <div className="flex gap-2">
            <button className="text-blue-500">👁</button>
            <button className="text-red-500">🗑</button>
          </div>
        </div>
      </div>

      <button className="bg-orange-500 text-white px-4 py-2 rounded-lg w-fit">
        Upload files
      </button>
    </div>
  );
}
