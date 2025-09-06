"use client";

import React from "react";
import clsx from "clsx";

export function Skeleton({ className }: { className?: string }) {
  return (
    <div
      className={clsx(
        "animate-pulse rounded-md bg-white shadow-sm border border-gray-200",
        className
      )}
    />
  );
}
