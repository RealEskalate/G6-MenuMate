import { ReactNode } from "react";

interface TagProps {
  children: ReactNode;
  color?: "orange" | "green" | "blue" | "gray" | "red";
}

export default function Tag({ children, color = "gray" }: TagProps) {
  const colors: Record<string, string> = {
    orange: "bg-orange-100 text-orange-700 border-orange-300",
    green: "bg-green-100 text-green-700 border-green-300",
    blue: "bg-blue-100 text-blue-700 border-blue-300",
    gray: "bg-gray-100 text-gray-700 border-gray-300",
    red: "bg-red-100 text-red-700 border-red-300",
  };

  return (
    <span
      className={`inline-block px-3 py-1 text-sm font-medium rounded-full border ${colors[color]}`}
    >
      {children}
    </span>
  );
}
