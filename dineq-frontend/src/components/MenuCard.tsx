// src/components/MenuCard.tsx
import { QrCode, Edit, Trash2 } from "lucide-react";

interface MenuCardProps {
  title: string;
  status: "Published" | "Pending";
  items: number;
  rating: number;
  created: string;
  updated: string;
}

export default function MenuCard({
  title,
  status,
  items,
  rating,
  created,
  updated,
}: MenuCardProps) {
  return (
    <div className="border rounded-2xl shadow-sm p-5 w-80 bg-white flex flex-col gap-3">
      <div className="flex justify-between items-center">
        <h2 className="text-lg font-semibold">{title}</h2>
        <span
          className={`text-xs px-2 py-1 rounded-full ${
            status === "Published"
              ? "bg-orange-100 text-orange-600"
              : "bg-gray-100 text-gray-600"
          }`}
        >
          {status}
        </span>
      </div>
      <p className="text-xs text-gray-500">
        Created {created} · Updated {updated}
      </p>
      <div className="flex flex-wrap gap-3 mt-2">
        <div className="text-sm border rounded px-2 py-1">
          📦 {items} Dishes
        </div>
        <div className="text-sm border rounded px-2 py-1">🌐 Amh · Eng</div>
        <div className="text-sm border rounded px-2 py-1">⭐ {rating}</div>
      </div>
      <div className="flex justify-between items-center mt-4">
        <button className="text-orange-600 border border-orange-600 px-3 py-1 rounded-md flex items-center gap-1">
          <QrCode size={16} /> Manage QR
        </button>
        <button className="bg-orange-500 text-white px-3 py-1 rounded-md flex items-center gap-1">
          <Edit size={16} /> Edit Menu
        </button>
      </div>
    </div>
  );
}
