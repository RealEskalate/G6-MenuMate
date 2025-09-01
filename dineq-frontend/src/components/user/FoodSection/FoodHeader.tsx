<<<<<<< HEAD
import { Heart } from "lucide-react";
import Image from "next/image";


interface FoodHeaderProps {
  image: string ;
  title: string;
  price: string;
  onFavorite?: () => void;
=======
"use client";
import { Heart } from "lucide-react";
import Image, { StaticImageData } from "next/image";

interface FoodHeaderProps {
  image: string | StaticImageData;  
  title: string;
  price: string;
  onFavorite: () => void;
>>>>>>> origin/frontend-main
}

export default function FoodHeader({ image, title, price, onFavorite }: FoodHeaderProps) {
  return (
    <div className="rounded-xl shadow-md overflow-hidden bg-white">
<<<<<<< HEAD
      <Image 
      src={image} 
      alt={title} 
      className="w-full h-48 object-cover"
      width={400} 
      height={200} 
       />
=======
      <Image src={image} alt={title} className="w-full h-48 object-cover" />
>>>>>>> origin/frontend-main

      <div className="p-4 flex flex-col gap-2">
        <h2 className="text-lg font-semibold">{title}</h2>
        <p className="text-orange-600 font-bold">{price}</p>
        <button
          onClick={onFavorite}
          className="flex items-center gap-2 text-white bg-orange-500 hover:bg-orange-600 px-3 py-2 rounded-lg w-fit"
        >
          <Heart className="w-4 h-4" /> Add to Favorites
        </button>
      </div>
    </div>
  );
}
