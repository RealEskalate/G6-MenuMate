export default function IngredientTag({ label, onRemove }: { label: string; onRemove: () => void }) {
  return (
    <span className="px-3 py-1 bg-gray-100 rounded-full text-sm flex items-center">
      {label}
      <button
        onClick={onRemove}
        className="ml-2 text-gray-500 hover:text-red-500"
      >
        ✕
      </button>
    </span>
  );
}
