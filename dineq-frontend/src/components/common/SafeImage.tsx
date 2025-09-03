"use client";

import React, { useState } from "react";
import Image, { ImageProps } from "next/image";

interface SafeImageProps extends Omit<ImageProps, "src"> {
  src: string;
  fallbackSrc?: string;
}

export default function SafeImage({ src, fallbackSrc = "/Background.png", ...rest }: SafeImageProps) {
  const [useFallback, setUseFallback] = useState(false);

  const resolvedSrc = useFallback || !src ? fallbackSrc : src;

  return (
    <Image
      {...rest}
      src={resolvedSrc}
      onError={() => setUseFallback(true)}
    />
  );
}
