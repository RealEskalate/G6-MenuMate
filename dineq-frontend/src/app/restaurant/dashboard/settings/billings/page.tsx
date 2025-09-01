"use client";

export default function BillingSettings() {
  return (
    <div className="flex flex-col gap-6">
      <h2 className="text-lg font-semibold">Billings</h2>

      {/* Current plan & Next invoice */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm mb-1">Current plan</label>
          <input
            type="text"
            value="FREE"
            readOnly
            className="w-full border border-gray-300 rounded-lg px-3 py-2 bg-gray-50"
          />
        </div>
        <div>
          <label className="block text-sm mb-1">Next invoice</label>
          <input
            type="text"
            value="2025-02-09"
            readOnly
            className="w-full border border-gray-300 rounded-lg px-3 py-2 bg-gray-50"
          />
        </div>
      </div>

      {/* Invoice Table */}
      <div className="overflow-x-auto">
        <table className="min-w-full border border-gray-200 rounded-lg text-sm">
          <thead className="bg-gray-50">
            <tr>
              <th scope="col" className="text-left px-4 py-2 border-b border-gray-300">Invoice</th>
              <th scope="col" className="text-left px-4 py-2 border-b border-gray-300">Date</th>
              <th scope="col" className="text-left px-4 py-2 border-b border-gray-300">Amount</th>
            </tr>
          </thead>
          <tbody>
            <tr className="odd:bg-white even:bg-gray-50">
              <th scope="row" className="px-4 py-2 border-b border-gray-300 font-medium">#INV-0012</th>
              <td className="px-4 py-2 border-b border-gray-300">2025-02-09</td>
              <td className="px-4 py-2 border-b border-gray-300">100 ETB</td>
            </tr>
          </tbody>
        </table>
      </div>

      {/* Upgrade button */}
      <button className="bg-orange-500 hover:bg-orange-600 text-white px-4 py-2 rounded-lg flex items-center gap-2 w-fit shadow-sm">
        ⬆️ Upgrade to Premium
      </button>
    </div>
  );
}
