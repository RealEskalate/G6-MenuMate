"use client";

import React from "react";
import Image from "next/image";
import { MenuItem } from "./menuApi";

interface MenuItemCardProps {
  item: MenuItem;
}

export default function MenuItemCard({ item }: MenuItemCardProps) {
  return (
    <div className="flex w-[535.25px] h-[110.86px] border border-[var(--color-primary)] rounded-lg">
      {/* Image */}
      <div className="h-[97px] w-[152.43px] relative rounded-lg m-[5px] overflow-hidden">
        {item.image ? (
          <Image
            src={item.image}
            alt={item.name}
            fill
            objectFit="cover"
            className="rounded-lg"
          />
        ) : (
          <div className="bg-gray-200 w-full h-full rounded-lg" />
        )}
      </div>

      {/* Info */}
      <div className="w-[354.9px] h-[87.76px] pt-[10.78px] pr-[12.7px] pb-[23.64px] pl-[11.93px] flex flex-col gap-y-[9.34px]">
        <div className="flex justify-between h-[24px] pt-[10.74px]">
          <p className="font-semibold text-[20px] leading-[23.35px]">{item.name}</p>
          <p className="font-semibold text-[20px] leading-[23.35px]">
            {item.price} {item.currency ?? "ETB"}
          </p>
        </div>

        <div className="h-[20px] w-[330.26px]">
          <p>{item.description}</p>
        </div>
      </div>
    </div>
  );
}
