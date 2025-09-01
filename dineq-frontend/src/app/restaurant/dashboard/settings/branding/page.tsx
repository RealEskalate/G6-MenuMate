"use client";

export default function ProfileSettings() {
  return (
    <div className="flex flex-col gap-6">
      {/* Branding */}
      <div>
        <h2 className="text-lg font-semibold mb-4">Branding</h2>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm mb-1">Primary color</label>
            <input
              type="text"
              defaultValue="#89643GE"
              className="w-full border border-gray-300 rounded-lg px-3 py-2"
            />
          </div>
          <div>
            <label className="block text-sm mb-1">Accent color</label>
            <input
              type="text"
              defaultValue="#YY3424"
              className="w-full border border-gray-300  rounded-lg px-3 py-2"
            />
          </div>
        </div>
      </div>

      {/* Menu Preferences */}
      <div>
        <h2 className="text-lg font-semibold mb-4">Menu Preferences</h2>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm mb-1">Default currency</label>
            <select className="w-full border border-gray-300  rounded-lg px-3 py-2">
              <option>ETB</option>
              <option>USD</option>
              <option>EUR</option>
            </select>
          </div>
          <div>
            <label className="block text-sm mb-1">Default language</label>
            <select className="w-full border border-gray-300  rounded-lg px-3 py-2">
              <option>English</option>
              <option>Amharic</option>
              <option>French</option>
            </select>
          </div>
          <div>
            <label className="block text-sm mb-1">Default VAT/Service Charge (%)</label>
            <input
              type="text"
              defaultValue="15%"
              className="w-full border border-gray-300 rounded-lg px-3 py-2"
            />
          </div>
        </div>
      </div>
    </div>
  );
}
