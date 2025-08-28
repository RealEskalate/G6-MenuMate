"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { FaCheck } from "react-icons/fa";

const steps = [
  { number: 1, label: "Basic Information", description: "Restaurant details", href: "/register/basic-info" },
  { number: 2, label: "Legal Documents", description: "Upload required files", href: "/register/legal-documents" },
  { number: 3, label: "Review & Submit", description: "Final verification", href: "/register/review" },
];

export default function RegisterSidebar() {
  const pathname = usePathname();
  const activeIndex = steps.findIndex((s) => pathname.startsWith(s.href));

  return (
    <aside className="w-72 h-1/5 bg-white rounded-lg p-6 shadow-sm mr-8">
      <h2 className="font-semibold text-lg mb-4">Registration Progress</h2>
      <ol className="space-y-6">
        {steps.map((step, i) => {
          const isCompleted = i < activeIndex;
          const isActive = i === activeIndex;

          return (
            <li key={step.number} className="flex items-start space-x-3">
              <div
                className={`flex items-center justify-center w-6 h-6 rounded-full text-white text-sm font-bold ${
                  isCompleted
                    ? "bg-green-500"
                    : isActive
                    ? "bg-orange-500"
                    : "bg-gray-300"
                }`}
              >
                {isCompleted ? <FaCheck className="text-xs" /> : step.number}
              </div>
              <div>
                <Link
                  href={step.href}
                  className={isActive ? "text-gray-900 font-medium" : "text-gray-500"}
                >
                  {step.label}
                </Link>
                <p className="text-xs text-gray-400">{step.description}</p>
              </div>
            </li>
          );
        })}
      </ol>

      <div className="mt-8">
        <p className="text-sm text-gray-500 mb-2">Progress</p>
        <div className="w-full bg-gray-200 h-2 rounded">
          <div
            className="bg-orange-500 h-2 rounded"
            style={{ width: `${((activeIndex + 1) / steps.length) * 100}%` }}
          />
        </div>
        <p className="text-xs text-gray-500 mt-1">
          {activeIndex + 1} of {steps.length} steps completed
        </p>
      </div>
    </aside>
  );
}
