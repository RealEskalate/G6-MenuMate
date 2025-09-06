import Link from "next/link";
import { Pencil } from "lucide-react";
import Image from "next/image";

export default function MenuItemCard({ id, title, description, price, image }: {
  id: string;
  title: string;
  description: string;
  price: number;
  image: string;
}) {
  return (
    <div className="flex items-start border rounded-lg p-3 relative bg-white">
      <Image 
      width={100}
      height={110}
      src={image} alt={title} className="w-20 h-20 rounded-md object-cover" />
      <div className="ml-3 flex-1">
        <h5 className="font-medium">{title}</h5>
        <p className="text-sm text-gray-600">{description}</p>
        <p className="text-orange-500 font-semibold mt-1">ETB {price}</p>
      </div>
      {/* Link to edit page */}
      <Link href={`/restaurant/dashboard/menu/edit-menu/${id}`}>
        <Pencil className="w-4 h-4 text-gray-500 absolute top-2 right-2 cursor-pointer" />
      </Link>
    </div>
  );
}
