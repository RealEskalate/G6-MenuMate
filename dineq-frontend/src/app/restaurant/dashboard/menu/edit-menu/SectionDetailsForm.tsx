export default function SectionDetailsForm({
  sectionName,
  language,
}: {
  sectionName: string;
  language: string;
}) {
  return (
    <div className="border rounded-lg p-4 bg-gray-50">
      <h3 className="font-medium mb-3">Basic Details</h3>
      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block text-sm text-gray-600 mb-1">Section name</label>
          <input
            type="text"
            defaultValue={sectionName}
            className="w-full border rounded px-3 py-2 text-sm"
          />
        </div>
        <div>
          <label className="block text-sm text-gray-600 mb-1">Language</label>
          <select
            defaultValue={language}
            className="w-full border rounded px-3 py-2 text-sm"
          >
            <option value="Amharic">Amharic</option>
            <option value="English">English</option>
          </select>
        </div>
      </div>
      <button className="mt-3 px-3 py-1 text-xs border rounded text-gray-600">
        + Add tags
      </button>
    </div>
  );
}
