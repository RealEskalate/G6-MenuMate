import { Button } from "@/components/ui/button";
import { Heart } from "lucide-react";
import Image, { StaticImageData } from "next/image";


interface FoodHeaderProps {
  image: string | StaticImageData;
  title: string;
  price: string;
  onFavorite?: () => void;
}

export default function FoodHeader({ image, title, price, onFavorite }: FoodHeaderProps) {
  return (
    <div className="rounded-xl  overflow-hidden w-full  bg-white">
      <Image src={image} alt={title}   width={500}  height={200}  className="w-full h-48 object-cover" />

      <div className="p-4 flex justify-between">
        <div className="flex flex-col justify-between items-center mb-2">
        <h2 className="text-lg font-semibold">{title}</h2>
        <p className="text-orange-600 ">{price}</p>
        </div>
        <Button
          onClick={onFavorite}
          
        >
          <Heart className="w-4 h-4" /> Add to Favorites
        </Button>
      </div>
    </div>
  );
}
